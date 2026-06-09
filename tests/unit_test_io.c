#include "test_utils.h"

void test_io() {
    TrackingAllocator talloc = {
        .base = { .allocate = tracking_allocate, .deallocate = tracking_free },
        .total_allocated = 0,
        .total_freed = 0
    };
    Allocator* alloc = (Allocator*)&talloc;

    String test_path = STRING_new("test_io_artifact.txt", 20);
    String test_content = STRING_new("camelot_io_test_data\nline2\nline3", 32);
    
    Result res_write = IO_write(alloc, test_path, test_content);
    assert(res_write.state == OK);
    
    String append_content = STRING_new("\nline4", 6);
    Result res_append = IO_append(alloc, test_path, append_content);
    assert(res_append.state == OK);

    Result res_read = IO_read(alloc, test_path);
    assert(res_read.state == OK);
    OwnedString* read_str = (OwnedString*)res_read.payload.val;
    assert(read_str->view.len == 38);
    
    Result split_res = STRING_split(alloc, read_str->view, '\n');
    assert(split_res.state == OK);
    Vector* lines = (Vector*)split_res.payload.val;
    assert(lines->len == 4);
    
    VECTOR_deinit(lines);
    alloc->deallocate(alloc, lines, sizeof(Vector));
    OWNEDSTRING_deinit(read_str);
    remove("test_io_artifact.txt");
    
    assert(talloc.total_allocated == talloc.total_freed);
}
