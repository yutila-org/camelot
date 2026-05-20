#ifndef CAMELOT_ARENA_H
#define CAMELOT_ARENA_H

#include "camelot/types/primitives.h"
#include "camelot/memory/allocator.h"

typedef struct {
    Allocator base;
    u8* buffer;
    size_t capacity;
    size_t offset;
} Arena;

void* ARENA_allocate(Allocator* self, size_t size, size_t align);
void ARENA_reset(Arena* self);

#endif // CAMELOT_ARENA_H
