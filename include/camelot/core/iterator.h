#ifndef CAMELOT_ITERATOR_H
#define CAMELOT_ITERATOR_H

typedef struct Iterator Iterator;

struct Iterator {
    void* (*next)(Iterator* self);
};

#endif // CAMELOT_ITERATOR_H
