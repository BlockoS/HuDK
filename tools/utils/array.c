/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2019 MooZ
 */

#include "array.h"

#include <stdlib.h>
#include <string.h>

void array_init(array_t *t, int element_size) {
    t->data = NULL;
    t->capacity = 0;
    t->count = 0;
    t->element_size = element_size;
}

int array_resize(array_t *t, int count) {
    if(count <= t->capacity) {
        t->count = count;
        return 1;
    }
    int capacity = count;
    uint8_t *data = (uint8_t*)realloc(t->data, capacity * t->element_size);
    if(data == NULL) {
        return 0;
    }
    t->data = data;
    t->capacity = capacity;
    t->count = count;
    return 1;
}

int array_push(array_t *t, const uint8_t *element) {
    if((t->count+1) >= t->capacity) {
        int capacity = t->capacity ? (t->capacity * 2) : 2;
        uint8_t *data = (uint8_t*)realloc(t->data, capacity * t->element_size);
        if(data == NULL) {
            return 0;
        }
        t->data = data;
        t->capacity = capacity;
    }
    memcpy(t->data + (t->count * t->element_size), element, t->element_size);
    ++t->count;
    return 1;
}

int array_pop(array_t *t, uint8_t *element) {
    if(!t->count) {
        return 0;
    }
    t->count--;
    memcpy(element, t->data + (t->count * t->element_size), t->element_size);
    return 1;
}

int array_at(array_t *t, int index, uint8_t *element) {
    if(index >= t->count) {
        return 0;
    }
    memcpy(element, t->data + (index * t->element_size), t->element_size);
    return 1;
}

void array_delete(array_t *t) {
    if(t->data) {
        free(t->data);
    }
    t->data = NULL;
    t->capacity = 0;
    t->count = 0;
    t->element_size = 0;
}
