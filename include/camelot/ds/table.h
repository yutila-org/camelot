#ifndef CAMELOT_TABLE_H
#define CAMELOT_TABLE_H

#include "camelot/memory/allocator.h"
#include "camelot/types/string.h"
#include "camelot/core/result.h"
#include <stddef.h>

#define CTRL_EMPTY   0x80
#define CTRL_DELETED 0xFE

typedef struct {
    String key;
    void* value;
} TableEntry;

typedef struct {
    Allocator* alloc;
    u8* ctrl;
    TableEntry* slots;
    size_t len;
    size_t cap;
    u64 hash_key[2]; // 128-bit randomized key for SipHash-2-4 HashDoS protection
} Table;

CAMELOT_NODISCARD Result TABLE_init(Allocator* alloc, size_t cap);
CAMELOT_NODISCARD Result TABLE_set(Table* table, String key, void* value);
CAMELOT_NODISCARD Result TABLE_get(Table* table, String key);
void TABLE_delete(Table* table, String key);
void TABLE_deinit(Table* table);

#endif // CAMELOT_TABLE_H
