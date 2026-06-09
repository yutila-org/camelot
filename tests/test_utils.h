#ifndef TEST_UTILS_H
#define TEST_UTILS_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "camelot/camelot.h"
#include "unity.h"

typedef struct {
    Allocator base;
    size_t total_allocated;
    size_t total_freed;
    bool enable_failure;
    int fail_after_n;
} TrackingAllocator;

void* tracking_allocate(Allocator* self, size_t size, size_t align);
void tracking_free(Allocator* self, void* ptr, size_t size);

#endif
