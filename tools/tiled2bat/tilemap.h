/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2020 MooZ
 */
#ifndef HUDK_TOOLS_TILEMAP_H
#define HUDK_TOOLS_TILEMAP_H

#include <stdint.h>
#include "tileset.h"

typedef struct {
    char *name;
    int *data;
} tilemap_layer_t;

typedef struct {
    char *name;
    tilemap_layer_t *layer;
    int layer_count;
    int width;
    int height;
    int tile_width;
    int tile_height;
    int tileset_count;
    tileset_t *tileset;
} tilemap_t;

int tilemap_create(tilemap_t *map, const char *name, int width, int height, int tile_width, int tile_height, int tileset_count);
int tilemap_add_layer(tilemap_t *map, const char *name);
void tilemap_destroy(tilemap_t *map);
int tilemap_compress(tilemap_t *map);

#endif /* HUDK_TOOLS_TILEMAP_H */
