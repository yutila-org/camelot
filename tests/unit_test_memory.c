#include "test_utils.h"

void test_memory_types_size(void) {
    TEST_ASSERT_EQUAL(1, sizeof(u8));
    TEST_ASSERT_EQUAL(2, sizeof(u16));
    TEST_ASSERT_EQUAL(4, sizeof(u32));
    TEST_ASSERT_EQUAL(8, sizeof(u64));
    TEST_ASSERT_EQUAL(1, sizeof(i8));
    TEST_ASSERT_EQUAL(2, sizeof(i16));
    TEST_ASSERT_EQUAL(4, sizeof(i32));
    TEST_ASSERT_EQUAL(8, sizeof(i64));
    TEST_ASSERT_EQUAL(4, sizeof(f32));
    TEST_ASSERT_EQUAL(8, sizeof(f64));
    TEST_ASSERT_EQUAL(1, sizeof(bool));
}

void test_memory_arena_allocate(void) {
    u8 backing_buffer[1024];
    Arena arena = {
        .base = { .allocate = ARENA_allocate, .deallocate = nullptr },
        .buffer = backing_buffer,
        .capacity = 1024,
        .offset = 0
    };

    Allocator* alloc = (Allocator*)&arena;
    void* ptr1 = alloc->allocate(alloc, 16, 8);
    void* ptr2 = alloc->allocate(alloc, 16, 8);

    TEST_ASSERT_NOT_NULL(ptr1);
    TEST_ASSERT_NOT_NULL(ptr2);
    TEST_ASSERT_EQUAL_PTR((u8*)ptr1 + 16, ptr2);

    ARENA_reset(&arena);
    TEST_ASSERT_EQUAL(0, arena.offset);
}

void test_memory_result_types(void) {
    Result res = { .state = OK, .payload = { .val = nullptr } };
    TEST_ASSERT_EQUAL(OK, res.state);
    TEST_ASSERT_NULL(res.payload.val);

    Result res_err = { .state = ERR, .payload = { .err_code = ERR_OUT_OF_MEMORY } };
    TEST_ASSERT_EQUAL(ERR, res_err.state);
    TEST_ASSERT_EQUAL(ERR_OUT_OF_MEMORY, res_err.payload.err_code);

    Result res_nil = { .state = NIL, .payload = { .val = nullptr } };
    TEST_ASSERT_EQUAL(NIL, res_nil.state);
    
    Result res_pun = {
        .state = ERR,
        .payload = { .val = (void*)0xFFFFFFFFFFFFFFFFULL }
    };
    res_pun.payload.err_code = ERR_FILE_ERROR;
    TEST_ASSERT_EQUAL(ERR_FILE_ERROR, res_pun.payload.err_code);
}
