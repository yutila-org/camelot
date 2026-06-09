#ifndef CAMELOT_IO_H
#define CAMELOT_IO_H

#include "camelot/memory/allocator.h"
#include "camelot/types/string.h"
#include "camelot/core/result.h"

CAMELOT_NODISCARD Result IO_read(Allocator* alloc, String path);
CAMELOT_NODISCARD Result IO_write(Allocator* alloc, String path, Slice data);
CAMELOT_NODISCARD Result IO_append(Allocator* alloc, String path, Slice data);

#endif // CAMELOT_IO_H
