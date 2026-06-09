#define CAMELOT_ALLOW_UNSAFE
#include <stdio.h>
#include <string.h>
#include "camelot/ds/table.h"

#define ROTL(x, b) (u64)(((x) << (b)) | ((x) >> (64 - (b))))
#define SIPROUND do { \
    v0 += v1; v1 = ROTL(v1, 13); v1 ^= v0; v0 = ROTL(v0, 32); \
    v2 += v3; v3 = ROTL(v3, 16); v3 ^= v2; \
    v0 += v3; v3 = ROTL(v3, 21); v3 ^= v0; \
    v2 += v1; v1 = ROTL(v1, 17); v1 ^= v2; v2 = ROTL(v2, 32); \
} while(0)

static u64 siphash24(const u8* in, size_t inlen, const u64 k[2]) {
    u64 v0 = 0x736f6d6570736575ULL ^ k[0];
    u64 v1 = 0x646f72616e646f6dULL ^ k[1];
    u64 v2 = 0x6c7967656e657261ULL ^ k[0];
    u64 v3 = 0x7465646279746573ULL ^ k[1];
    u64 b = ((u64)inlen) << 56;
    
    const u8* end = in + (inlen & ~7);
    for (; in != end; in += 8) {
        u64 m; memcpy(&m, in, 8);
        v3 ^= m;
        SIPROUND; SIPROUND;
        v0 ^= m;
    }
    
    u64 t = 0;
    switch (inlen & 7) {
        case 7: t |= ((u64)end[6]) << 48; // fallthrough
        case 6: t |= ((u64)end[5]) << 40; // fallthrough
        case 5: t |= ((u64)end[4]) << 32; // fallthrough
        case 4: t |= ((u64)end[3]) << 24; // fallthrough
        case 3: t |= ((u64)end[2]) << 16; // fallthrough
        case 2: t |= ((u64)end[1]) << 8;  // fallthrough
        case 1: t |= ((u64)end[0]);       // fallthrough
        case 0: break;
    }
    b |= t;
    v3 ^= b;
    SIPROUND; SIPROUND;
    v0 ^= b;
    v2 ^= 0xff;
    SIPROUND; SIPROUND; SIPROUND; SIPROUND;
    
    return v0 ^ v1 ^ v2 ^ v3;
}

static void init_random_key(u64 key[2]) {
    FILE* f = fopen("/dev/urandom", "rb");
    if (f) {
        if (fread(key, sizeof(u64), 2, f) != 2) {
            key[0] = 0x1234567890ABCDEF;
            key[1] = 0xFEDCBA0987654321;
        }
        fclose(f);
    } else {
        key[0] = 0x1234567890ABCDEF;
        key[1] = 0xFEDCBA0987654321;
    }
}

static size_t next_pow2(size_t n) {
    if (n < 8) return 8;
    size_t p = 1;
    while (p < n) p <<= 1;
    return p;
}

Result TABLE_init(Allocator* alloc, size_t cap) {
    Result res = { .state = ERR, .payload = { .err_code = ERR_OUT_OF_MEMORY } };
    if (!alloc) return res;
    
    cap = next_pow2(cap);
    size_t total_size = cap * sizeof(u8) + cap * sizeof(TableEntry);
    
    u8* ctrl = nullptr;
    Table* t = nullptr;
    
    ctrl = (u8*)alloc->allocate(alloc, total_size, 8);
    if (!ctrl) goto defer;
    
    memset(ctrl, CTRL_EMPTY, cap);
    
    t = (Table*)alloc->allocate(alloc, sizeof(Table), 8);
    if (!t) goto defer;
    
    t->alloc = alloc;
    t->ctrl = ctrl;
    t->slots = (TableEntry*)(ctrl + cap);
    t->len = 0;
    t->cap = cap;
    init_random_key(t->hash_key);
    
    res.state = OK;
    res.payload.val = t;
    
defer:
    if (res.state != OK) {
        if (ctrl && alloc->deallocate) alloc->deallocate(alloc, ctrl, total_size);
        if (t && alloc->deallocate) alloc->deallocate(alloc, t, sizeof(Table));
    }
    return res;
}

static Result table_resize(Table* t, size_t new_cap) {
    Result res = { .state = ERR, .payload = { .err_code = ERR_OUT_OF_MEMORY } };
    size_t total_size = new_cap * sizeof(u8) + new_cap * sizeof(TableEntry);
    u8* new_ctrl = (u8*)t->alloc->allocate(t->alloc, total_size, 8);
    if (!new_ctrl) return res;
    
    memset(new_ctrl, CTRL_EMPTY, new_cap);
    TableEntry* new_slots = (TableEntry*)(new_ctrl + new_cap);
    
    size_t mask = new_cap - 1;
    for (size_t i = 0; i < t->cap; i++) {
        if (t->ctrl[i] < CTRL_EMPTY) { // Valid occupied slot
            u64 hash = siphash24(t->slots[i].key.ptr, t->slots[i].key.len, t->hash_key);
            u8 h7 = hash & 0x7F;
            size_t idx = hash & mask;
            for (size_t j = 0; j < new_cap; j++) {
                size_t probe = (idx + j) & mask;
                if (new_ctrl[probe] == CTRL_EMPTY) {
                    new_ctrl[probe] = h7;
                    new_slots[probe] = t->slots[i];
                    break;
                }
            }
        }
    }
    
    if (t->alloc->deallocate) {
        size_t old_size = t->cap * sizeof(u8) + t->cap * sizeof(TableEntry);
        t->alloc->deallocate(t->alloc, t->ctrl, old_size);
    }
    
    t->ctrl = new_ctrl;
    t->slots = new_slots;
    t->cap = new_cap;
    res.state = OK;
    return res;
}

Result TABLE_set(Table* t, String key, void* value) {
    Result res = { .state = ERR, .payload = { .err_code = ERR_OUT_OF_MEMORY } };
    if (!t) return res;
    
    if (t->len * 4 >= t->cap * 3) { // 75% load factor
        Result r = table_resize(t, t->cap * 2);
        if (r.state != OK) return r;
    }
    
    u64 hash = siphash24(key.ptr, key.len, t->hash_key);
    u8 h7 = hash & 0x7F;
    size_t mask = t->cap - 1;
    size_t idx = hash & mask;
    
    size_t tombstone_idx = (size_t)-1;
    
    for (size_t i = 0; i < t->cap; i++) {
        size_t probe = (idx + i) & mask;
        u8 ctrl = t->ctrl[probe];
        
        if (ctrl == CTRL_EMPTY) {
            size_t insert_idx = (tombstone_idx != (size_t)-1) ? tombstone_idx : probe;
            t->ctrl[insert_idx] = h7;
            t->slots[insert_idx].key = key;
            t->slots[insert_idx].value = value;
            t->len++;
            res.state = OK;
            res.payload.val = nullptr;
            return res;
        }
        
        if (ctrl == CTRL_DELETED) {
            if (tombstone_idx == (size_t)-1) tombstone_idx = probe;
            continue;
        }
        
        if (ctrl == h7) {
            if (t->slots[probe].key.len == key.len && memcmp(t->slots[probe].key.ptr, key.ptr, key.len) == 0) {
                t->slots[probe].value = value; // update existing key
                res.state = OK;
                res.payload.val = nullptr;
                return res;
            }
        }
    }
    return res;
}

Result TABLE_get(Table* t, String key) {
    Result res = { .state = NIL, .payload = { .val = nullptr } };
    if (!t || t->len == 0) return res;
    
    u64 hash = siphash24(key.ptr, key.len, t->hash_key);
    u8 h7 = hash & 0x7F;
    size_t mask = t->cap - 1;
    size_t idx = hash & mask;
    
    for (size_t i = 0; i < t->cap; i++) {
        size_t probe = (idx + i) & mask;
        u8 ctrl = t->ctrl[probe];
        if (ctrl == CTRL_EMPTY) {
            return res; // NIL
        }
        if (ctrl == h7) {
            if (t->slots[probe].key.len == key.len && memcmp(t->slots[probe].key.ptr, key.ptr, key.len) == 0) {
                res.state = OK;
                res.payload.val = t->slots[probe].value;
                return res;
            }
        }
    }
    return res;
}

void TABLE_delete(Table* t, String key) {
    if (!t || t->len == 0) return;
    
    u64 hash = siphash24(key.ptr, key.len, t->hash_key);
    u8 h7 = hash & 0x7F;
    size_t mask = t->cap - 1;
    size_t idx = hash & mask;
    
    for (size_t i = 0; i < t->cap; i++) {
        size_t probe = (idx + i) & mask;
        u8 ctrl = t->ctrl[probe];
        if (ctrl == CTRL_EMPTY) return;
        if (ctrl == h7) {
            if (t->slots[probe].key.len == key.len && memcmp(t->slots[probe].key.ptr, key.ptr, key.len) == 0) {
                t->ctrl[probe] = CTRL_DELETED;
                t->len--;
                return;
            }
        }
    }
}

void TABLE_deinit(Table* t) {
    if (!t || !t->alloc) return;
    if (t->ctrl && t->alloc->deallocate) {
        size_t total_size = t->cap * sizeof(u8) + t->cap * sizeof(TableEntry);
        t->alloc->deallocate(t->alloc, t->ctrl, total_size);
    }
    if (t->alloc->deallocate) {
        t->alloc->deallocate(t->alloc, t, sizeof(Table));
    }
}
