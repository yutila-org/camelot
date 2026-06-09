#ifndef CAMELOT_SLICE_H
#define CAMELOT_SLICE_H

#include "camelot/types/primitives.h"
#include <stddef.h>

typedef struct {
    u8* ptr;
    size_t len;
} Slice;

Slice SLICE_new(u8* buffer, size_t len);
Slice SLICE_sub(Slice s, size_t offset, size_t len);

#endif // CAMELOT_SLICE_H
