#include "camelot/memory/arena.h"

void* ARENA_allocate(Allocator* self, size_t size, size_t align) {
    Arena* arena = (Arena*)self;
    size_t current_ptr = (size_t)(arena->buffer + arena->offset);
    size_t offset = (current_ptr + (align - 1)) & ~(align - 1);
    offset -= (size_t)arena->buffer;
    
    if (offset + size <= arena->capacity) {
        void* ptr = &arena->buffer[offset];
        arena->offset = offset + size;
        return ptr;
    }
    return nullptr;
}

void ARENA_reset(Arena* self) {
    self->offset = 0;
}
