/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2019 MooZ
 */

#include "buffer.h"

#include <stdlib.h>
#include <string.h>


void buffer_init(buffer_t *b) {
    b->data = NULL;
    b->size = 0;
    b->capacity = 0;
}

int buffer_resize(buffer_t *b, int size) {
    if(size > b->capacity) {
        uint8_t *data = (uint8_t*)realloc(b->data, size);
        if(data == NULL) {
            return 0;
        }
        b->capacity = size;
        b->data = data;
    }
    b->size = size;
    return 1;
}

void buffer_delete(buffer_t *b) {
    if(b->data) {
        free(b->data);
    }
    b->data = NULL;
    b->capacity = 0;
    b->size = 0;
}
