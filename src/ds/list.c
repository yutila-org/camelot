#define CAMELOT_ALLOW_UNSAFE
#include <string.h>
#include "camelot/ds/list.h"
#include "camelot/types/primitives.h"

List LIST_init(Allocator* alloc, size_t stride) {
    List list = {
        .alloc = alloc,
        .head = nullptr,
        .tail = nullptr,
        .stride = stride
    };
    return list;
}

void LIST_append(List* list, const void* item) {
    if (!list || !item || !list->alloc) return;
    
    size_t node_size = sizeof(LIST_Node) + list->stride;
    LIST_Node* node = (LIST_Node*)list->alloc->allocate(list->alloc, node_size, 8);
    if (!node) return;
    
    node->next = nullptr;
    node->data = (u8*)node + sizeof(LIST_Node);
    memcpy(node->data, item, list->stride);
    
    // O(1) insertion scaling characteristics using tail pointer
    if (list->tail) {
        list->tail->next = node;
        list->tail = node;
    } else {
        list->head = node;
        list->tail = node;
    }
}

void LIST_deinit(List* list) {
    if (!list || !list->alloc || !list->alloc->deallocate) return;
    
    size_t node_size = sizeof(LIST_Node) + list->stride;
    LIST_Node* curr = list->head;
    while (curr) {
        LIST_Node* next = curr->next;
        list->alloc->deallocate(list->alloc, curr, node_size);
        curr = next;
    }
    list->head = nullptr;
    list->tail = nullptr;
}

static void* list_next(Iterator* self) {
    LIST_Iterator* iter = (LIST_Iterator*)self;
    if (!iter || !iter->current) {
        return nullptr;
    }
    void* item = iter->current->data;
    iter->current = iter->current->next;
    return item;
}

void LIST_iteratorInit(LIST_Iterator* self, List* list) {
    if (!self || !list) return;
    self->base.next = list_next;
    self->current = list->head;
}
