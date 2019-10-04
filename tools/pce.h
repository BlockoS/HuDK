/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2019 MooZ
 */
#ifndef HUDK_TOOLS_PCE_H
#define HUDK_TOOLS_PCE_H

#include <stdint.h>
#include "image.h"

int pce_bitmap_to_tile(uint8_t *out, uint8_t *in, int stride);
int pce_bitmap_to_sprite(uint8_t *out, uint8_t *in, int stride);

int pce_image_to_tiles(image_t *img, int bloc_width, int bloc_height, uint8_t *buffer, size_t *size);
int pce_image_to_sprites(image_t *img, int sprite_width, int sprite_height, uint8_t *buffer, size_t *size);

void pce_color_convert(uint8_t *in, uint8_t *out, int color_count);

#endif /* HUDK_TOOLS_PCE_H */
