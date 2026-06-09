// camelot/safety.h — Compile-time function banning
#ifndef CAMELOT_SAFETY_H
#define CAMELOT_SAFETY_H

#ifndef ALLOW_UNSAFE
  #if defined(__GNUC__) || defined(__clang__)
    // FATAL BANS: Always banned across the entire codebase
    #pragma GCC poison strcpy strcat strncpy strncat
    #pragma GCC poison gets sprintf vsprintf
    #pragma GCC poison atoi atol atoll atof
    #pragma GCC poison scanf fscanf sscanf
    #pragma GCC poison malloc free calloc realloc

    // CONDITIONAL BANS: Allowed internally only if explicitly requested
    #ifndef CAMELOT_ALLOW_UNSAFE
        #pragma GCC poison memcpy memmove memset
    #endif
  #elif defined(_MSC_VER)
    // MSVC: no #pragma poison equivalent.
    // Enforcement delegated to /W4 + static analysis (SAL annotations).
  #endif
#endif // ALLOW_UNSAFE

#endif // CAMELOT_SAFETY_H
