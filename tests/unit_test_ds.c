#include "test_utils.h"

void test_ds_vector(void) {
    TrackingAllocator talloc = {
        .base = { .allocate = tracking_allocate, .deallocate = tracking_free },
        .total_allocated = 0,
        .total_freed = 0
    };
    Allocator* alloc = (Allocator*)&talloc;

    Vector vec = VECTOR_init(alloc, sizeof(u32));
    TEST_ASSERT_EQUAL(0, vec.len);
    TEST_ASSERT_EQUAL(0, vec.cap);
    
    for (u32 i = 0; i < 10; i++) {
        VECTOR_push(&vec, &i);
    }
    
    TEST_ASSERT_EQUAL(10, vec.len);
    TEST_ASSERT(vec.cap >= 10);
    
    VECTOR_Iterator viter;
    VECTOR_iteratorInit(&viter, &vec);
    u32 count = 0;
    while (true) {
        void* item = viter.base.next((Iterator*)&viter);
        if (!item) break;
        TEST_ASSERT_EQUAL(count, *(u32*)item);
        count++;
    }
    TEST_ASSERT_EQUAL(10, count);
    
    VECTOR_deinit(&vec);
    TEST_ASSERT_EQUAL(talloc.total_allocated, talloc.total_freed);
}

void test_ds_list(void) {
    TrackingAllocator talloc = {
        .base = { .allocate = tracking_allocate, .deallocate = tracking_free },
        .total_allocated = 0,
        .total_freed = 0
    };
    Allocator* alloc = (Allocator*)&talloc;

    List list = LIST_init(alloc, sizeof(u32));
    TEST_ASSERT_NULL(list.head);
    TEST_ASSERT_NULL(list.tail);

    for (u32 i = 0; i < 5; i++) {
        LIST_append(&list, &i);
    }
    
    LIST_Iterator liter;
    LIST_iteratorInit(&liter, &list);
    u32 count = 0;
    while (true) {
        void* item = liter.base.next((Iterator*)&liter);
        if (!item) break;
        TEST_ASSERT_EQUAL(count, *(u32*)item);
        count++;
    }
    TEST_ASSERT_EQUAL(5, count);
    
    LIST_deinit(&list);
    TEST_ASSERT_EQUAL(talloc.total_allocated, talloc.total_freed);
}

void test_ds_table(void) {
    TrackingAllocator talloc = {
        .base = { .allocate = tracking_allocate, .deallocate = tracking_free },
        .total_allocated = 0,
        .total_freed = 0
    };
    Allocator* alloc = (Allocator*)&talloc;

    Result res_tab = TABLE_init(alloc, 8);
    TEST_ASSERT_EQUAL(OK, res_tab.state);
    Table* t = (Table*)res_tab.payload.val;
    
    String k1 = STRING_new("excalibur", 9);
    u32 v1 = 9000;
    Result s1 = TABLE_set(t, k1, &v1);
    TEST_ASSERT_EQUAL(OK, s1.state);
    
    Result g1 = TABLE_get(t, k1);
    TEST_ASSERT_EQUAL(OK, g1.state);
    TEST_ASSERT_EQUAL(9000, *(u32*)g1.payload.val);
    
    String k_missing = STRING_new("missing", 7);
    Result gm = TABLE_get(t, k_missing);
    TEST_ASSERT_EQUAL(NIL, gm.state);
    
    TABLE_delete(t, k1);
    Result g1_del = TABLE_get(t, k1);
    TEST_ASSERT_EQUAL(NIL, g1_del.state);
    
    TABLE_deinit(t);
    TEST_ASSERT_EQUAL(talloc.total_allocated, talloc.total_freed);
}

void test_ds_table_teardown(void) {
    for (int fail_at = 0; fail_at <= 2; fail_at++) {
        TrackingAllocator falloc = {
            .base = { .allocate = tracking_allocate, .deallocate = tracking_free },
            .total_allocated = 0,
            .total_freed = 0,
            .enable_failure = true,
            .fail_after_n = fail_at
        };
        Allocator* fa = (Allocator*)&falloc;
        Result fail_res = TABLE_init(fa, 8);
        if (fail_at < 2) {
            TEST_ASSERT_EQUAL(ERR, fail_res.state);
            TEST_ASSERT_EQUAL(falloc.total_allocated, falloc.total_freed);
        } else {
            TEST_ASSERT_EQUAL(OK, fail_res.state);
            Table* ft = (Table*)fail_res.payload.val;
            TABLE_deinit(ft);
            TEST_ASSERT_EQUAL(falloc.total_allocated, falloc.total_freed);
        }
    }
}
