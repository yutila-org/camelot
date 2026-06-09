#include "test_utils.h"

void test_ds() {
    TrackingAllocator talloc = {
        .base = { .allocate = tracking_allocate, .deallocate = tracking_free },
        .total_allocated = 0,
        .total_freed = 0
    };
    Allocator* alloc = (Allocator*)&talloc;

    // Vector tests
    Vector vec = VECTOR_init(alloc, sizeof(u32));
    assert(vec.len == 0);
    assert(vec.cap == 0);
    
    for (u32 i = 0; i < 10; i++) {
        VECTOR_push(&vec, &i);
    }
    
    assert(vec.len == 10);
    assert(vec.cap >= 10);
    
    VECTOR_Iterator viter;
    VECTOR_iteratorInit(&viter, &vec);
    u32 count = 0;
    while (true) {
        void* item = viter.base.next((Iterator*)&viter);
        if (!item) break;
        assert(*(u32*)item == count);
        count++;
    }
    assert(count == 10);
    
    VECTOR_deinit(&vec);
    assert(talloc.total_allocated == talloc.total_freed);

    // List tests
    List list = LIST_init(alloc, sizeof(u32));
    assert(list.head == nullptr);
    assert(list.tail == nullptr);

    for (u32 i = 0; i < 5; i++) {
        LIST_append(&list, &i);
    }
    
    LIST_Iterator liter;
    LIST_iteratorInit(&liter, &list);
    count = 0;
    while (true) {
        void* item = liter.base.next((Iterator*)&liter);
        if (!item) break;
        assert(*(u32*)item == count);
        count++;
    }
    assert(count == 5);
    
    LIST_deinit(&list);
    assert(talloc.total_allocated == talloc.total_freed);

    // Table tests
    Result res_tab = TABLE_init(alloc, 8);
    assert(res_tab.state == OK);
    Table* t = (Table*)res_tab.payload.val;
    
    String k1 = STRING_new("excalibur", 9);
    u32 v1 = 9000;
    Result s1 = TABLE_set(t, k1, &v1);
    assert(s1.state == OK);
    
    Result g1 = TABLE_get(t, k1);
    assert(g1.state == OK);
    assert(*(u32*)g1.payload.val == 9000);
    
    String k_missing = STRING_new("missing", 7);
    Result gm = TABLE_get(t, k_missing);
    assert(gm.state == NIL);
    
    TABLE_delete(t, k1);
    Result g1_del = TABLE_get(t, k1);
    assert(g1_del.state == NIL);
    
    TABLE_deinit(t);
    assert(talloc.total_allocated == talloc.total_freed);

    // Table teardown tests
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
            assert(fail_res.state == ERR);
            assert(falloc.total_allocated == falloc.total_freed);
        } else {
            assert(fail_res.state == OK);
            Table* ft = (Table*)fail_res.payload.val;
            TABLE_deinit(ft);
            assert(falloc.total_allocated == falloc.total_freed);
        }
    }
}
