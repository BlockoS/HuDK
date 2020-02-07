/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2020 MooZ
 */
#ifndef HUDK_TOOLS_TILESET_H
#define HUDK_TOOLS_TILESET_H

#include "../utils/image.h"

typedef struct {
    char *name;
    uint8_t *tiles;
    int tile_count;
    int tile_width;
    int tile_height;
    uint8_t *palette_index;
    uint8_t *palette;
    int palette_count;
} tileset_t;

int tileset_create(tileset_t *tileset, const char *name, int tile_count, int tile_width, int tile_height);

int tileset_add(tileset_t *tileset, int i, image_t *img, int x, int y);

void tileset_destroy(tileset_t *tileset);

int tileset_load(tileset_t *tileset, const char *name, const char *filename, int tile_count, int tile_width, int tile_height, int margin, int spacing, int columns);

#endif /* HUDK_TOOLS_TILESET_H */