#include "test_utils.h"

void test_integration_pipeline_full(void) {
    TrackingAllocator talloc = {
        .base = { .allocate = tracking_allocate, .deallocate = tracking_free },
        .total_allocated = 0,
        .total_freed = 0
    };
    Allocator* alloc = (Allocator*)&talloc;

    String test_path = STRING_new("integration_test_file.tmp", 25);
    String data = STRING_new("excalibur\nlancelot\nmerlin\ngawain", 32);
    
    Result wr = IO_write(alloc, test_path, data);
    TEST_ASSERT_EQUAL(OK, wr.state);
    
    Result rr = IO_read(alloc, test_path);
    TEST_ASSERT_EQUAL(OK, rr.state);
    OwnedString* file_data = (OwnedString*)rr.payload.val;
    
    Result sr = STRING_split(alloc, file_data->view, '\n');
    TEST_ASSERT_EQUAL(OK, sr.state);
    Vector* lines = (Vector*)sr.payload.val;
    
    Result tr = TABLE_init(alloc, 16);
    TEST_ASSERT_EQUAL(OK, tr.state);
    Table* table = (Table*)tr.payload.val;
    
    u32 power_levels[] = { 9000, 8500, 10000, 8000 };
    
    for (size_t i = 0; i < lines->len; i++) {
        String* line = (String*)((u8*)lines->data + (i * lines->stride));
        Result set_r = TABLE_set(table, *line, &power_levels[i]);
        TEST_ASSERT_EQUAL(OK, set_r.state);
    }
    
    // Verify pipeline
    String search_key = STRING_new("merlin", 6);
    Result get_r = TABLE_get(table, search_key);
    TEST_ASSERT_EQUAL(OK, get_r.state);
    TEST_ASSERT_EQUAL(10000, *(u32*)get_r.payload.val);
    
    // Teardown
    TABLE_deinit(table);
    VECTOR_deinit(lines);
    alloc->deallocate(alloc, lines, sizeof(Vector));
    OWNEDSTRING_deinit(file_data);
    remove("integration_test_file.tmp");
    
    TEST_ASSERT_EQUAL(talloc.total_allocated, talloc.total_freed);
}
