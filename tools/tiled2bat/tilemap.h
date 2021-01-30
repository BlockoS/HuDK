/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2021 MooZ
 */
#ifndef HUDK_TOOLS_TILEMAP_H
#define HUDK_TOOLS_TILEMAP_H

#include <stdint.h>
#include "tileset.h"

/// Tilemap layer.
typedef struct {
    char *name;                 ///< Layer name.
    int *data;                  ///< Layer tile indices.
} tilemap_layer_t;

/// Tilemap.
typedef struct {
    char *name;                 ///< Tilemap name.
    tilemap_layer_t *layer;     ///< Tilemap layers.
    int layer_count;            ///< Number of tilemap layers.
    int width;                  ///< Number of tile columns.
    int height;                 ///< Number of tile rows.
    int tile_width;             ///< Tile width.
    int tile_height;            ///< Tile height.
    int tileset_count;          ///< Number of tilesets.
    tileset_t *tileset;         ///< Tilesets.
} tilemap_t;

/// Create tilemap.
int tilemap_create(tilemap_t *map, const char *name, int width, int height, int tile_width, int tile_height, int tileset_count);
/// Add layer to tilemap.
int tilemap_add_layer(tilemap_t *map, const char *name);
/// Destroy tilemap.
void tilemap_destroy(tilemap_t *map);
/// Remove unused tiles from tilemap.
int tilemap_compress(tilemap_t *map);

#endif /* HUDK_TOOLS_TILEMAP_H */
