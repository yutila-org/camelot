#include "test_utils.h"

void test_pipeline() {
    TrackingAllocator talloc = {
        .base = { .allocate = tracking_allocate, .deallocate = tracking_free },
        .total_allocated = 0,
        .total_freed = 0
    };
    Allocator* alloc = (Allocator*)&talloc;

    String test_path = STRING_new("integration_test_file.tmp", 25);
    String data = STRING_new("excalibur\nlancelot\nmerlin\ngawain", 32);
    
    Result wr = IO_write(alloc, test_path, data);
    assert(wr.state == OK);
    
    Result rr = IO_read(alloc, test_path);
    assert(rr.state == OK);
    OwnedString* file_data = (OwnedString*)rr.payload.val;
    
    Result sr = STRING_split(alloc, file_data->view, '\n');
    assert(sr.state == OK);
    Vector* lines = (Vector*)sr.payload.val;
    
    Result tr = TABLE_init(alloc, 16);
    assert(tr.state == OK);
    Table* table = (Table*)tr.payload.val;
    
    u32 power_levels[] = { 9000, 8500, 10000, 8000 };
    
    for (size_t i = 0; i < lines->len; i++) {
        String* line = (String*)((u8*)lines->data + (i * lines->stride));
        Result set_r = TABLE_set(table, *line, &power_levels[i]);
        assert(set_r.state == OK);
    }
    
    // Verify pipeline
    String search_key = STRING_new("merlin", 6);
    Result get_r = TABLE_get(table, search_key);
    assert(get_r.state == OK);
    assert(*(u32*)get_r.payload.val == 10000);
    
    // Teardown
    TABLE_deinit(table);
    VECTOR_deinit(lines);
    alloc->deallocate(alloc, lines, sizeof(Vector));
    OWNEDSTRING_deinit(file_data);
    remove("integration_test_file.tmp");
    
    assert(talloc.total_allocated == talloc.total_freed);
}
