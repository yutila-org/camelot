#ifndef CAMELOT_SAFETY_H
#define CAMELOT_SAFETY_H

#ifndef ALLOW_UNSAFE
  #if defined(__GNUC__) || defined(__clang__)
    #pragma GCC poison strcpy strcat strncpy strncat
  #elif defined(_MSC_VER)
    // MSVC: no #pragma poison equivalent.
    // Enforcement delegated to /W4 + static analysis (SAL annotations).
  #endif
#endif // ALLOW_UNSAFE

#endif // CAMELOT_SAFETY_H
