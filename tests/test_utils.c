#define CAMELOT_ALLOW_UNSAFE
#include "test_utils.h"

#define POOL_SIZE (10 * 1024 * 1024)
static u8 global_test_heap[POOL_SIZE];
static size_t global_heap_offset = 0;

void* tracking_allocate(Allocator* self, size_t size, size_t align) {
    TrackingAllocator* track = (TrackingAllocator*)self;
    if (track->enable_failure) {
        if (track->fail_after_n <= 0) return nullptr;
        track->fail_after_n--;
    }
    
    size_t remainder = global_heap_offset % align;
    if (remainder != 0) {
        global_heap_offset += (align - remainder);
    }
    
    if (global_heap_offset + size > POOL_SIZE) {
        return nullptr;
    }
    
    void* ptr = &global_test_heap[global_heap_offset];
    global_heap_offset += size;
    
    track->total_allocated += size;
    return ptr;
}

void tracking_free(Allocator* self, void* ptr, size_t size) {
    (void)ptr;
    TrackingAllocator* track = (TrackingAllocator*)self;
    track->total_freed += size;
}
