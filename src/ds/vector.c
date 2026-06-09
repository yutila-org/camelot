#define CAMELOT_ALLOW_UNSAFE
#include <string.h>
#include "camelot/ds/vector.h"
#include "camelot/types/primitives.h"

Vector VECTOR_init(Allocator* alloc, size_t stride) {
    Vector arr = {
        .alloc = alloc,
        .data = nullptr,
        .len = 0,
        .cap = 0,
        .stride = stride
    };
    return arr;
}

void VECTOR_push(Vector* arr, const void* item) {
    if (!arr || !item || !arr->alloc) return;

    if (arr->len >= arr->cap) {
        size_t new_cap = arr->cap == 0 ? 4 : arr->cap + (arr->cap >> 1); // 1.5x expansion
        void* new_data = arr->alloc->allocate(arr->alloc, new_cap * arr->stride, 8);
        if (!new_data) return; // Silent return on OOM as signature is void
        
        if (arr->data) {
            memcpy(new_data, arr->data, arr->len * arr->stride);
            if (arr->alloc->deallocate != nullptr) {
                arr->alloc->deallocate(arr->alloc, arr->data, arr->cap * arr->stride);
            }
        }
        arr->data = new_data;
        arr->cap = new_cap;
    }
    
    memcpy((u8*)arr->data + (arr->len * arr->stride), item, arr->stride);
    arr->len++;
}

void VECTOR_deinit(Vector* arr) {
    if (!arr || !arr->alloc) return;
    
    if (arr->data != nullptr && arr->alloc->deallocate != nullptr) {
        arr->alloc->deallocate(arr->alloc, arr->data, arr->cap * arr->stride);
    }
    arr->data = nullptr;
    arr->len = 0;
    arr->cap = 0;
}

static void* vector_next(Iterator* self) {
    VECTOR_Iterator* iter = (VECTOR_Iterator*)self;
    if (!iter || !iter->arr || iter->index >= iter->arr->len) {
        return nullptr;
    }
    void* item = (u8*)iter->arr->data + (iter->index * iter->arr->stride);
    iter->index++;
    return item;
}

void VECTOR_iteratorInit(VECTOR_Iterator* self, Vector* arr) {
    if (!self || !arr) return;
    self->base.next = vector_next;
    self->arr = arr;
    self->index = 0;
}
