#define CAMELOT_ALLOW_UNSAFE
#include <stdio.h>
#include <stdarg.h>
#include "camelot/types/string.h"
#include "camelot/ds/vector.h"

String STRING_new(const char* literal, size_t len) {
    String s = { .ptr = (u8*)literal, .len = len };
    return s;
}

Result STRING_formatVariadic(Allocator* alloc, const char* fmt, va_list args) {
    Result res = { .state = ERR, .payload = { .err_code = ERR_OUT_OF_MEMORY } };
    
    // We need a copy of args because vsnprintf mutates it
    va_list args_copy;
    va_copy(args_copy, args);
    
    // Determine required length (excluding null terminator)
    int req_len = vsnprintf(nullptr, 0, fmt, args_copy);
    va_end(args_copy);
    
    if (req_len < 0) {
        res.payload.err_code = ERR_OUT_OF_BOUNDS; // Formatting error
        return res;
    }
    
    size_t len = (size_t)req_len;
    size_t struct_size = sizeof(OwnedString);
    size_t total_size = struct_size + len + 1; // +1 for null terminator
    
    u8* buffer = (u8*)alloc->allocate(alloc, total_size, 8);
    if (!buffer) {
        return res; // ERR_OUT_OF_MEMORY
    }
    
    OwnedString* owned = (OwnedString*)buffer;
    owned->alloc = alloc;
    owned->view.ptr = buffer + struct_size;
    owned->view.len = len;
    
    vsnprintf((char*)owned->view.ptr, len + 1, fmt, args);
    
    res.state = OK;
    res.payload.val = owned;
    
    return res;
}

Result STRING_format(Allocator* alloc, const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    Result res = STRING_formatVariadic(alloc, fmt, args);
    va_end(args);
    return res;
}

void OWNEDSTRING_deinit(OwnedString* str) {
    if (!str || !str->alloc) return;
    Allocator* alloc = str->alloc;
    if (alloc->deallocate != nullptr) {
        size_t total_size = sizeof(OwnedString) + str->view.len + 1;
        alloc->deallocate(alloc, str, total_size);
    }
}

Result STRING_split(Allocator* alloc, String s, char delim) {
    Result res = { .state = ERR, .payload = { .err_code = ERR_OUT_OF_MEMORY } };
    if (!alloc) return res;

    Vector* vec = (Vector*)alloc->allocate(alloc, sizeof(Vector), 8);
    if (!vec) return res;
    
    *vec = VECTOR_init(alloc, sizeof(String));
    
    size_t start = 0;
    for (size_t i = 0; i <= s.len; i++) {
        if (i == s.len || s.ptr[i] == delim) {
            String sub = { .ptr = s.ptr + start, .len = i - start };
            VECTOR_push(vec, &sub);
            start = i + 1;
        }
    }
    
    res.state = OK;
    res.payload.val = vec;
    return res;
}
