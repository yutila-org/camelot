#include "test_utils.h"

void test_slice_and_string() {
    u8 slice_buffer[100];
    Slice full_slice = SLICE_new(slice_buffer, 100);
    assert(full_slice.ptr == slice_buffer);
    assert(full_slice.len == 100);
    
    Slice sub_slice = SLICE_sub(full_slice, 10, 20);
    assert(sub_slice.ptr == full_slice.ptr + 10);
    assert(sub_slice.len == 20);
    
    sub_slice.ptr[0] = 42;
    assert(slice_buffer[10] == 42);
    
    Slice oob_slice1 = SLICE_sub(full_slice, 150, 10);
    assert(oob_slice1.ptr == nullptr);
    assert(oob_slice1.len == 0);
    
    Slice oob_slice2 = SLICE_sub(full_slice, 95, 10);
    assert(oob_slice2.ptr == nullptr);
    assert(oob_slice2.len == 0);

    TrackingAllocator talloc = {
        .base = { .allocate = tracking_allocate, .deallocate = tracking_free },
        .total_allocated = 0,
        .total_freed = 0
    };
    Allocator* alloc = (Allocator*)&talloc;

    Result str_res = STRING_format(alloc, "Test format %d: %s", 42, "hello");
    assert(str_res.state == OK);
    OwnedString* o_str = (OwnedString*)str_res.payload.val;
    assert(o_str != nullptr);
    assert(o_str->view.len > 0);
    assert(o_str->alloc == alloc);
    
    OWNEDSTRING_deinit(o_str);
    assert(talloc.total_allocated == talloc.total_freed);

    TrackingAllocator failing_talloc = {
        .base = { .allocate = tracking_allocate, .deallocate = tracking_free },
        .total_allocated = 0,
        .total_freed = 0,
        .enable_failure = true,
        .fail_after_n = 0
    };
    Allocator* falloc = (Allocator*)&failing_talloc;
    Result fail_res = STRING_format(falloc, "This should fail %d", 1);
    assert(fail_res.state == ERR);
    assert(fail_res.payload.err_code == ERR_OUT_OF_MEMORY);
    assert(failing_talloc.total_allocated == failing_talloc.total_freed);
}
