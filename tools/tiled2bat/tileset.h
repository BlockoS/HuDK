/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2021 MooZ
 */
#ifndef HUDK_TOOLS_TILESET_H
#define HUDK_TOOLS_TILESET_H

#include "../utils/image.h"

/// Tileset
typedef struct {
    char *name;             ///< Tileset name.
    int first_gid;          ///< Lowest tile id.

    /// Tile array. They are stored continuously. This means that the offset of the tile `i` is `i*tile_width*tile_count`
    /// and the offset to the next line of this tile is `tile_width*tile_count`.
    uint8_t *tiles;
    int tile_count;         ///< Number of tiles.
    int tile_width;         ///< Tile width (in pixels).
    int tile_height;        ///< Tile height (in pixels).
    
    /// Palette index for each tile.
    /// Note that the palette index is assigned for each tile and not for each 8x8 tiles.
    /// This may change in the future.
    uint8_t *palette_index;
    uint8_t *palette;       ///< 16 color palettes.
    int palette_count;      ///< Number of palettes.
} tileset_t;

/// Create tileset.
int tileset_create(tileset_t *tileset, const char *name, int first_gid, int tile_count, int tile_width, int tile_height);
/// Add the tile stored in the image `img` at position `(x,y)` to index `i in the tileset.
/// The 16 colors subpalette is determined by the color of the tile first pixel. An error occurs if one of the tile pixel color is
/// out of the subpalette bounds.
int tileset_add(tileset_t *tileset, int i, image_t *img, int x, int y);
/// Release any memory allocated for the tileset.
void tileset_destroy(tileset_t *tileset);
/// Initialise tileset.
int tileset_load(tileset_t *tileset, const char *filename, const char *name, int first_gid, int tile_count, int tile_width, int tile_height, int margin, int spacing, int columns);

#endif /* HUDK_TOOLS_TILESET_H */