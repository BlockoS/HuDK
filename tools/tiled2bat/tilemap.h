/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2019 MooZ
 */
#ifndef HUDK_TOOLS_TILEMAP_H
#define HUDK_TOOLS_TILEMAP_H

#include <stdint.h>
#include "tileset.h"

typedef struct {
    char *name;
    uint8_t *data;
    int width;
    int height;
    int tile_width;
    int tile_height;
    int tileset_count;
    tileset_t *tileset;
} tilemap_t;

int tilemap_create(tilemap_t *map, char *name, int width, int height, int tile_width, int tile_height, int tileset_count);
void tilemap_destroy(tilemap_t *map);

#endif /* HUDK_TOOLS_TILEMAP_H */
