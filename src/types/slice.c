#include "camelot/types/slice.h"

Slice SLICE_new(u8* buffer, size_t len) {
    Slice s = { .ptr = buffer, .len = len };
    return s;
}

Slice SLICE_sub(Slice s, size_t offset, size_t len) {
    // Bounds check to prevent out-of-bounds reads
    if (s.ptr == nullptr || offset > s.len || (offset + len) > s.len || (offset + len) < offset) {
        Slice empty = { .ptr = nullptr, .len = 0 };
        return empty;
    }
    
    // Zero-copy substring
    Slice sub = { .ptr = s.ptr + offset, .len = len };
    return sub;
}
