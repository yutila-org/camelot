#include "unity.h"

extern void test_memory_types_size(void);
extern void test_memory_arena_allocate(void);
extern void test_memory_result_types(void);

extern void test_slice_operations(void);
extern void test_string_format(void);

extern void test_ds_vector(void);
extern void test_ds_list(void);
extern void test_ds_table(void);
extern void test_ds_table_teardown(void);

extern void test_io_read_write_append(void);

extern void test_integration_pipeline_full(void);

void setUp(void) {}
void tearDown(void) {}

int main(void) {
    UNITY_BEGIN();
    
    RUN_TEST(test_memory_types_size);
    RUN_TEST(test_memory_arena_allocate);
    RUN_TEST(test_memory_result_types);
    
    RUN_TEST(test_slice_operations);
    RUN_TEST(test_string_format);
    
    RUN_TEST(test_ds_vector);
    RUN_TEST(test_ds_list);
    RUN_TEST(test_ds_table);
    RUN_TEST(test_ds_table_teardown);
    
    RUN_TEST(test_io_read_write_append);
    
    RUN_TEST(test_integration_pipeline_full);
    
    return UNITY_END();
}
