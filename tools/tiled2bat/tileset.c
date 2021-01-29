/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2021 MooZ
 */
#include "tileset.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <cwalk.h>

#include "../utils/log.h"

int tileset_create(tileset_t *tileset, const char *name, int first_gid, int tile_count, int tile_width, int tile_height) {
    memset(tileset, 0, sizeof(tileset_t));
    
    tileset->first_gid = first_gid;

    tileset->tile_count = tile_count;
    tileset->tile_width = tile_width;
    tileset->tile_height = tile_height;
    
    tileset->palette_index = (uint8_t*)malloc(tile_count * sizeof(uint8_t));
    tileset->tiles = (uint8_t*)malloc(tile_count * tile_width * tile_height * sizeof(uint8_t));
    tileset->name = strdup(name);
    
    if(!(tileset->palette_index && tileset->tiles && tileset->name)) {
        tileset_destroy(tileset);
        return 0;
    }
    return 1;
}

int tileset_add(tileset_t *tileset, int tile_index, image_t *img, int x, int y) {
    int i, j, stride;
    int palette_index;
    uint8_t *ptr;

    if((tile_index >= tileset->tile_count) || ((x+tileset->tile_width) > img->width) || ((y+tileset->tile_height) > img->height) ||
       (x<0) || (y<0)){
        log_error("invalid parameter. %d %d %d %d %d %d", tile_index, tileset->tile_count, x, y, img->width, img->height);
        return 0;
    }

    // check that tile colors fits into a single palette.
    palette_index = img->data[x + (y * img->width)] / 16;
    if(palette_index >= 16) {
        log_error("invalid palette index: %d (max 16).", palette_index);
        return 0;
    }
    for(j=0; (j<tileset->tile_height) && ((y+j)<img->height); j++) {
        for(i=0; (i<tileset->tile_width) && ((x+i)<img->width); i++) {
            int col = img->data[x+i + ((y+j) * img->width)];
            int index = col /16;
            if(palette_index != index) {
                log_error("tile (%d,%d) color is out of palette bounds.", x+i, y+j);
                return 0;
            }
        }
    }
    // set tile palette index and copy the associated palette.
    tileset->palette_index[tile_index] = (uint8_t)palette_index;
    
    if(palette_index >= tileset->palette_count) {
        uint8_t *tmp = (uint8_t*)realloc(tileset->palette, ((int)palette_index+1)*3*16);
        if(tmp == NULL) {
            log_error("failed to resize palette.");
            return 0;
        }
        tileset->palette = tmp;
        tileset->palette_count = palette_index + 1;
    }
    for(i=palette_index*16, j=0; (j<16) && (i<img->color_count); j++, i++) {
        tileset->palette[3*i  ] = img->palette[3*i  ];
        tileset->palette[3*i+1] = img->palette[3*i+1];
        tileset->palette[3*i+2] = img->palette[3*i+2];
    }

    // copy bitmaps.
    stride = tileset->tile_width * tileset->tile_count;
    ptr = tileset->tiles + tile_index * tileset->tile_width;
    for(j=0; j<tileset->tile_height; j++) {
        for(i=0; i<tileset->tile_width; i++) {
            ptr[i + (j*stride)] = (uint8_t)((int)img->data[x+i + (y+j)*img->width] - (palette_index*16));
        }
    }
    return 1;
}

void tileset_destroy(tileset_t *tileset) {
    if(tileset->name) {
        free(tileset->name);
    }
    if(tileset->tiles) {
        free(tileset->tiles);
    }
    if(tileset->palette_index) {
        free(tileset->palette_index);
    }
    if(tileset->palette) {
        free(tileset->palette);
    }
    memset(tileset, 0, sizeof(tileset_t));
}

int tileset_load(tileset_t *tileset, const char *name, const char *filename, int first_gid, int tile_count, int tile_width, int tile_height, int margin, int spacing, int columns) {
    if(!tileset_create(tileset, name, first_gid, tile_count, tile_width, tile_height)) {
        return 0;
    }

    int ret, i=0;
    image_t img;
    ret = image_load_png(&img, filename);
    if(!ret) {
        log_error("failed to load image %s", filename);
    }
    for(int y=margin; ret && (y<img.height); y+=spacing+tile_height) {
        for(int x=margin, c=0; ret && (x<img.width) && (c<columns); x+=spacing+tile_width, i++, c++) {
            if(!tileset_add(tileset, i, &img, x, y)) {
                log_error("failed to add tile %d", i);
                ret = 0;
            }
        }
    }
    image_destroy(&img);
    return ret;
}