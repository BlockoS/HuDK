/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2020 MooZ
 */
#ifndef HUDK_TOOLS_BUFFER_H
#define HUDK_TOOLS_BUFFER_H

#include <stdint.h>

typedef struct {
    uint8_t *data;
    int size;
    int capacity;
} buffer_t;

void buffer_init(buffer_t *b);
int buffer_resize(buffer_t *b, int size);
void buffer_delete(buffer_t *b);

#endif // HUDK_TOOLS_BUFFER_H
