#ifndef CAMELOT_RESULT_H
#define CAMELOT_RESULT_H

#include "camelot/types/primitives.h"

#define DOMAIN_CAMELOT 0x00010000
#define DOMAIN_APP     0x00020000

#define ERR_OUT_OF_MEMORY (DOMAIN_CAMELOT | 0x0001)
#define ERR_FILE_ERROR    (DOMAIN_CAMELOT | 0x0002)
#define ERR_OUT_OF_BOUNDS (DOMAIN_CAMELOT | 0x0003)

typedef enum {
    OK,
    NIL,
    ERR
} State;

#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 202311L
#define CAMELOT_NODISCARD [[nodiscard]]
#elif defined(__GNUC__) || defined(__clang__)
#define CAMELOT_NODISCARD __attribute__((warn_unused_result))
#else
#define CAMELOT_NODISCARD
#endif

typedef struct CAMELOT_NODISCARD {
    State state;
    union {
        void* val;
        u32 err_code;
    } payload;
} Result;

#endif // CAMELOT_RESULT_H
