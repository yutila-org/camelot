#include "test_utils.h"

void test_slice_operations(void) {
    u8 slice_buffer[100];
    Slice full_slice = SLICE_new(slice_buffer, 100);
    TEST_ASSERT_EQUAL_PTR(slice_buffer, full_slice.ptr);
    TEST_ASSERT_EQUAL(100, full_slice.len);
    
    Slice sub_slice = SLICE_sub(full_slice, 10, 20);
    TEST_ASSERT_EQUAL_PTR(full_slice.ptr + 10, sub_slice.ptr);
    TEST_ASSERT_EQUAL(20, sub_slice.len);
    
    sub_slice.ptr[0] = 42;
    TEST_ASSERT_EQUAL(42, slice_buffer[10]);
    
    Slice oob_slice1 = SLICE_sub(full_slice, 150, 10);
    TEST_ASSERT_NULL(oob_slice1.ptr);
    TEST_ASSERT_EQUAL(0, oob_slice1.len);
    
    Slice oob_slice2 = SLICE_sub(full_slice, 95, 10);
    TEST_ASSERT_NULL(oob_slice2.ptr);
    TEST_ASSERT_EQUAL(0, oob_slice2.len);
}

void test_string_format(void) {
    TrackingAllocator talloc = {
        .base = { .allocate = tracking_allocate, .deallocate = tracking_free },
        .total_allocated = 0,
        .total_freed = 0
    };
    Allocator* alloc = (Allocator*)&talloc;

    Result str_res = STRING_format(alloc, "Test format %d: %s", 42, "hello");
    TEST_ASSERT_EQUAL(OK, str_res.state);
    OwnedString* o_str = (OwnedString*)str_res.payload.val;
    TEST_ASSERT_NOT_NULL(o_str);
    TEST_ASSERT(o_str->view.len > 0);
    TEST_ASSERT_EQUAL_PTR(alloc, o_str->alloc);
    
    OWNEDSTRING_deinit(o_str);
    TEST_ASSERT_EQUAL(talloc.total_allocated, talloc.total_freed);

    TrackingAllocator failing_talloc = {
        .base = { .allocate = tracking_allocate, .deallocate = tracking_free },
        .total_allocated = 0,
        .total_freed = 0,
        .enable_failure = true,
        .fail_after_n = 0
    };
    Allocator* falloc = (Allocator*)&failing_talloc;
    Result fail_res = STRING_format(falloc, "This should fail %d", 1);
    TEST_ASSERT_EQUAL(ERR, fail_res.state);
    TEST_ASSERT_EQUAL(ERR_OUT_OF_MEMORY, fail_res.payload.err_code);
    TEST_ASSERT_EQUAL(failing_talloc.total_allocated, failing_talloc.total_freed);
}
