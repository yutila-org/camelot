#include "test_utils.h"

void test_memory() {
    static_assert(sizeof(u8) == 1, "u8 must be 1 byte");
    static_assert(sizeof(u16) == 2, "u16 must be 2 bytes");
    static_assert(sizeof(u32) == 4, "u32 must be 4 bytes");
    static_assert(sizeof(u64) == 8, "u64 must be 8 bytes");
    static_assert(sizeof(i8) == 1, "i8 must be 1 byte");
    static_assert(sizeof(i16) == 2, "i16 must be 2 bytes");
    static_assert(sizeof(i32) == 4, "i32 must be 4 bytes");
    static_assert(sizeof(i64) == 8, "i64 must be 8 bytes");
    static_assert(sizeof(f32) == 4, "f32 must be 4 bytes");
    static_assert(sizeof(f64) == 8, "f64 must be 8 bytes");
    static_assert(sizeof(bool) == 1, "bool must be 1 byte");

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

    assert(ptr1 != nullptr);
    assert(ptr2 != nullptr);
    assert((u8*)ptr2 == (u8*)ptr1 + 16);

    ARENA_reset(&arena);
    assert(arena.offset == 0);

    Result res = { .state = OK, .payload.val = nullptr };
    assert(res.state == OK);
    assert(res.payload.val == nullptr);

    Result res_err = { .state = ERR, .payload.err_code = ERR_OUT_OF_MEMORY };
    assert(res_err.state == ERR);
    assert(res_err.payload.err_code == ERR_OUT_OF_MEMORY);

    Result res_nil = { .state = NIL, .payload.val = nullptr };
    assert(res_nil.state == NIL);
    
    Result res_pun;
    res_pun.state = ERR;
    res_pun.payload.val = (void*)0xFFFFFFFFFFFFFFFFULL;
    res_pun.payload.err_code = ERR_FILE_ERROR;
    assert(res_pun.payload.err_code == ERR_FILE_ERROR);
}
