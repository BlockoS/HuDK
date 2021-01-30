/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2020 MooZ
 */
#ifndef HUDK_TOOLS_IMAGE_H
#define HUDK_TOOLS_IMAGE_H

#include <stdint.h>

typedef struct {
    uint8_t *data;
    int width;
    int height;
    int bytes_per_pixel;
    
    uint8_t *palette;
    int color_count;
} image_t;

int image_create(image_t* img, int width, int height, int bpp, int color_count);

void image_destroy(image_t* img);

int image_load_png(image_t* dest, const char* filename);

int image_load_pcx(image_t* dest, const char* filename);

int image_write_png(image_t* src, const char* filename);

#endif /* HUDK_TOOLS_IMAGE_H */