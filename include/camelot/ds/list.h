#ifndef CAMELOT_LIST_H
#define CAMELOT_LIST_H

#include "camelot/memory/allocator.h"
#include "camelot/core/iterator.h"
#include <stddef.h>

typedef struct LIST_Node LIST_Node;
struct LIST_Node {
    LIST_Node* next;
    void* data;
};

typedef struct {
    Allocator* alloc;
    LIST_Node* head;
    LIST_Node* tail;
    size_t stride;
} List;

List LIST_init(Allocator* alloc, size_t stride);
void LIST_append(List* list, const void* item);
void LIST_deinit(List* list);

typedef struct {
    Iterator base;
    LIST_Node* current;
} LIST_Iterator;

void LIST_iteratorInit(LIST_Iterator* self, List* list);

#endif // CAMELOT_LIST_H
