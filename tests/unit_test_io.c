#include "test_utils.h"

void test_io_read_write_append(void) {
    TrackingAllocator talloc = {
        .base = { .allocate = tracking_allocate, .deallocate = tracking_free },
        .total_allocated = 0,
        .total_freed = 0
    };
    Allocator* alloc = (Allocator*)&talloc;

    String test_path = STRING_new("test_io_artifact.txt", 20);
    String test_content = STRING_new("camelot_io_test_data\nline2\nline3", 32);
    
    Result res_write = IO_write(alloc, test_path, test_content);
    TEST_ASSERT_EQUAL(OK, res_write.state);
    
    String append_content = STRING_new("\nline4", 6);
    Result res_append = IO_append(alloc, test_path, append_content);
    TEST_ASSERT_EQUAL(OK, res_append.state);

    Result res_read = IO_read(alloc, test_path);
    TEST_ASSERT_EQUAL(OK, res_read.state);
    OwnedString* read_str = (OwnedString*)res_read.payload.val;
    TEST_ASSERT_EQUAL(38, read_str->view.len);
    
    Result split_res = STRING_split(alloc, read_str->view, '\n');
    TEST_ASSERT_EQUAL(OK, split_res.state);
    Vector* lines = (Vector*)split_res.payload.val;
    TEST_ASSERT_EQUAL(4, lines->len);
    
    VECTOR_deinit(lines);
    alloc->deallocate(alloc, lines, sizeof(Vector));
    OWNEDSTRING_deinit(read_str);
    remove("test_io_artifact.txt");
    
    TEST_ASSERT_EQUAL(talloc.total_allocated, talloc.total_freed);
}
