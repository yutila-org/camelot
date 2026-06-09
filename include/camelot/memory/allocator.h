#ifndef CAMELOT_ALLOCATOR_H
#define CAMELOT_ALLOCATOR_H

#include "camelot/safety.h"
#include <stddef.h>

typedef struct Allocator Allocator;

struct Allocator {
    void* (*allocate)(Allocator* self, size_t size, size_t align);
    void  (*deallocate)(Allocator* self, void* ptr, size_t size);
};

#endif // CAMELOT_ALLOCATOR_H
