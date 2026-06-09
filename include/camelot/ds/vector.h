#ifndef CAMELOT_VECTOR_H
#define CAMELOT_VECTOR_H

#include "camelot/memory/allocator.h"
#include "camelot/core/iterator.h"
#include <stddef.h>

typedef struct {
    Allocator* alloc;
    void* data;
    size_t len;
    size_t cap;
    size_t stride;
} Vector;

Vector VECTOR_init(Allocator* alloc, size_t stride);
void VECTOR_push(Vector* arr, const void* item);
void VECTOR_deinit(Vector* arr);

typedef struct {
    Iterator base;
    Vector* arr;
    size_t index;
} VECTOR_Iterator;

void VECTOR_iteratorInit(VECTOR_Iterator* self, Vector* arr);

#endif // CAMELOT_VECTOR_H
