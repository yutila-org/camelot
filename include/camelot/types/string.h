#ifndef CAMELOT_STRING_H
#define CAMELOT_STRING_H

#include "camelot/types/slice.h"
#include "camelot/memory/allocator.h"
#include "camelot/core/result.h"
#include <stdarg.h>

typedef Slice String;

String STRING_new(const char* literal, size_t len);

typedef struct {
    Allocator* alloc;
    String view;
} OwnedString;

CAMELOT_NODISCARD Result STRING_format(Allocator* alloc, const char* fmt, ...);
CAMELOT_NODISCARD Result STRING_formatVariadic(Allocator* alloc, const char* fmt, va_list args);
void OWNEDSTRING_deinit(OwnedString* str);

// Splits a string by a delimiter into a Vector of String slices (zero-copy)
// Returns Result containing Vector*. Must be freed via VECTOR_deinit and the Vector pointer itself freed.
CAMELOT_NODISCARD Result STRING_split(Allocator* alloc, String s, char delim);

#endif // CAMELOT_STRING_H
