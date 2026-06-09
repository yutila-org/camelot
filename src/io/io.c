#define CAMELOT_ALLOW_UNSAFE
#include <stdio.h>
#include <string.h>
#include "camelot/io/io.h"

// Helper to safely convert String (Slice) to null-terminated C string for POSIX boundaries
static Result c_str(Allocator* alloc, String s, char** out) {
    Result res = { .state = ERR, .payload = { .err_code = ERR_OUT_OF_MEMORY } };
    *out = (char*)alloc->allocate(alloc, s.len + 1, 1);
    if (!*out) return res;
    if (s.len > 0 && s.ptr) {
        memcpy(*out, s.ptr, s.len);
    }
    (*out)[s.len] = '\0';
    res.state = OK;
    return res;
}

Result IO_read(Allocator* alloc, String path) {
    Result res = { .state = ERR, .payload = { .err_code = ERR_FILE_ERROR } };
    if (!alloc) return res;
    
    char* cpath = nullptr;
    Result path_res = c_str(alloc, path, &cpath);
    if (path_res.state != OK) return path_res;
    
    OwnedString* owned = nullptr;
    FILE* f = fopen(cpath, "rb");
    if (!f) goto defer;
    
    // Cursor-less chunk reading
    size_t cap = 1024;
    size_t len = 0;
    u8* buffer = (u8*)alloc->allocate(alloc, cap, 8);
    if (!buffer) {
        res.payload.err_code = ERR_OUT_OF_MEMORY;
        goto defer;
    }
    
    while (true) {
        if (len + 1024 > cap) {
            size_t new_cap = cap * 2;
            u8* new_buf = (u8*)alloc->allocate(alloc, new_cap, 8);
            if (!new_buf) {
                if (alloc->deallocate) alloc->deallocate(alloc, buffer, cap);
                res.payload.err_code = ERR_OUT_OF_MEMORY;
                goto defer;
            }
            memcpy(new_buf, buffer, len);
            if (alloc->deallocate) alloc->deallocate(alloc, buffer, cap);
            buffer = new_buf;
            cap = new_cap;
        }
        
        size_t bytes = fread(buffer + len, 1, 1024, f);
        len += bytes;
        if (bytes < 1024) {
            if (ferror(f)) {
                if (alloc->deallocate) alloc->deallocate(alloc, buffer, cap);
                goto defer;
            }
            break; // EOF reached
        }
    }
    
    // Now package it cleanly into an OwnedString allocation to shrink to exact size
    size_t struct_size = sizeof(OwnedString);
    size_t total_size = struct_size + len + 1;
    
    u8* final_buf = (u8*)alloc->allocate(alloc, total_size, 8);
    if (!final_buf) {
        if (alloc->deallocate) alloc->deallocate(alloc, buffer, cap);
        res.payload.err_code = ERR_OUT_OF_MEMORY;
        goto defer;
    }
    
    owned = (OwnedString*)final_buf;
    owned->alloc = alloc;
    owned->view.ptr = final_buf + struct_size;
    owned->view.len = len;
    
    memcpy(owned->view.ptr, buffer, len);
    owned->view.ptr[len] = '\0';
    if (alloc->deallocate) alloc->deallocate(alloc, buffer, cap); // free temporary chunk buffer
    
    res.state = OK;
    res.payload.val = owned;
    
defer: // Centralized teardown leveraging Explicit Deferral pattern
    if (f) fclose(f);
    if (cpath && alloc->deallocate) alloc->deallocate(alloc, cpath, path.len + 1);
    return res;
}

Result IO_write(Allocator* alloc, String path, Slice data) {
    Result res = { .state = ERR, .payload = { .err_code = ERR_FILE_ERROR } };
    if (!alloc) return res;
    
    char* cpath = nullptr;
    Result path_res = c_str(alloc, path, &cpath);
    if (path_res.state != OK) return path_res;
    
    FILE* f = fopen(cpath, "wb");
    if (!f) goto defer;
    
    if (data.len > 0 && data.ptr != nullptr) {
        if (fwrite(data.ptr, 1, data.len, f) != data.len) {
            goto defer;
        }
    }
    
    res.state = OK;
    res.payload.val = nullptr;
    
defer:
    if (f) fclose(f);
    if (cpath && alloc->deallocate) alloc->deallocate(alloc, cpath, path.len + 1);
    return res;
}

Result IO_append(Allocator* alloc, String path, Slice data) {
    Result res = { .state = ERR, .payload = { .err_code = ERR_FILE_ERROR } };
    if (!alloc) return res;
    
    char* cpath = nullptr;
    Result path_res = c_str(alloc, path, &cpath);
    if (path_res.state != OK) return path_res;
    
    FILE* f = fopen(cpath, "ab");
    if (!f) goto defer;
    
    if (data.len > 0 && data.ptr != nullptr) {
        if (fwrite(data.ptr, 1, data.len, f) != data.len) {
            goto defer;
        }
    }
    
    res.state = OK;
    res.payload.val = nullptr;
    
defer:
    if (f) fclose(f);
    if (cpath && alloc->deallocate) alloc->deallocate(alloc, cpath, path.len + 1);
    return res;
}
