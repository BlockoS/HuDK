/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2019 MooZ
 */
#ifndef HUDK_TOOLS_ARRAY_H
#define HUDK_TOOLS_ARRAY_H

#include <stdint.h>

typedef struct {
    uint8_t *data;
    int capacity;
    int count;
    int element_size;
} array_t;

void array_init(array_t *t, int element_size);
int array_resize(array_t *t, int count);
int array_push(array_t *t, const uint8_t *element);
int array_pop(array_t *t, uint8_t *element);
int array_at(array_t *t, int index, uint8_t *element);
void array_delete(array_t *t);

#endif // HUDK_TOOLS_ARRAY_H
