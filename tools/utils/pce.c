/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2020 MooZ
 */
#include <stdio.h>
#include <string.h>

#include "pce.h"

#include "log.h"

int pce_bitmap_to_tile(uint8_t *in, uint8_t *out, int stride) {
    int y;
    uint8_t *line = in;
    for(y=0; y<8; y++, line+=stride, out+=2) {
        int x;
        uint8_t *src = line;
        out[0] = out[1] = out[16] = out[17] = 0;
        for(x=7; x>=0; x--) {
            uint8_t byte = *src++;
            out[ 0] |= ((byte   ) & 0x01) << x;
            out[ 1] |= ((byte>>1) & 0x01) << x;
            out[16] |= ((byte>>2) & 0x01) << x;
            out[17] |= ((byte>>3) & 0x01) << x;
        }
    }
    return 1;   
}

int pce_bitmap_to_sprite(uint8_t *in, uint8_t *out, int stride) {
    int x, y;
	memset(out, 0, 128);
	uint8_t *line = in;
    for(y=0; y<16; y++, line+=stride, out+=2) {
        uint8_t *src = line;
        for(x=7; x>=0; x--) {
            uint8_t byte = *src++;
            out[1 ] |= ((byte   ) & 0x01) << x;
            out[33] |= ((byte>>1) & 0x01) << x;
            out[65] |= ((byte>>2) & 0x01) << x;
            out[97] |= ((byte>>3) & 0x01) << x;
        }
        for(x=7; x>=0; x--) {
            uint8_t byte = *src++;
            out[0 ] |= ((byte   ) & 0x01) << x;
            out[32] |= ((byte>>1) & 0x01) << x;
            out[64] |= ((byte>>2) & 0x01) << x;
            out[96] |= ((byte>>3) & 0x01) << x;
        }
    }
    return 1;
}

static inline int pce_bitmap_to_palette(uint8_t *out, uint8_t *in, int stride, int w, int h) {
    int y;
    uint8_t pal = in[0] >> 4;
    uint8_t *line = in;
    *out = 0xff;
    for(y=0; y<h; y++, line+=stride) {
        int x;
        uint8_t *src = line;
        for(x=0; x<w; x++) {
            uint8_t p = (*src++) >> 4;
            if(pal != p) {
                log_error("invalid palette index %d (expected: %d) %d", p, pal, in[x]);
                return 0;
            }
        }
    }
    *out = pal;
    return 1;   
}

int pce_bitmap_to_tile_palette(uint8_t *out, uint8_t *in, int stride) {
    return pce_bitmap_to_palette(out, in, stride, 8, 8);
}

int pce_bitmap_to_sprite_palette(uint8_t *out, uint8_t *in, int stride){
    return pce_bitmap_to_palette(out, in, stride, 16, 16);
}

int pce_image_to_tiles(image_t *img, int bloc_width, int bloc_height, uint8_t *buffer, size_t *size) {
    *size = 0;
    if((img->height & 7) && (img->width & 7)) {
        log_error("input width and height should be a multiple of 8 (%d,%d)", img->width, img->height);
        return 0;
    }
    if((bloc_width & 7) || (bloc_height & 7)) {
        log_error("bloc width and height must be a multiple of 8 (%d, %d)", bloc_width, bloc_height);
        return 0;
    }
    
    int ret = 1;
    uint8_t *out = buffer;

    int stride = img->width*8;

    uint8_t *bloc_line = img->data;
    int bloc_stride = img->width * bloc_height;
    int by;
    for(by=0; ret && (by<img->height); by+=bloc_height, bloc_line+=bloc_stride) {
        uint8_t *bloc_ptr = bloc_line;
        int bx;
        for(bx=0; ret && (bx<img->width); bx+=bloc_width, bloc_ptr+=bloc_width) {
            uint8_t *line = bloc_ptr;   
            int j;
            for(j=0; ret && (j<bloc_height); j+=8, line+=stride) {
                int i;
                uint8_t *in = line;
                for(i=0; ret && (i<bloc_width); i+=8, out+=32, in+=8) {
                    ret = pce_bitmap_to_tile(in, out, img->width);
                }
            }
        }
    }

    *size = out - buffer;
    return 1;
}

int pce_image_to_sprites(image_t *img, int sprite_width, int sprite_height, uint8_t *buffer, size_t *size) {
    *size = 0;
    
    if((img->height & 15) && (img->width & 15)) {
        log_error("input width and height should be a multiple of 16 (%d,%d)", img->width, img->height);
        return 0;
    }
    
    if((sprite_width & 15) || ((sprite_width != 16) && (sprite_width != 32))) {
        log_error("sprite width must be 16 or 32 (%d)", sprite_width);
        return 0;
    }
    
    if((sprite_height & 15) || ((sprite_height != 16) && (sprite_height != 32) && (sprite_height != 64))) {
        log_error("sprite height must be 16, 32 or 64 (%d)", sprite_height);
        return 0;
    }
    
    int ret = 1;
    uint8_t *out = buffer;

    int stride = img->width*16;
    int sprite_stride = img->width * sprite_height;

    uint8_t *sprite_line = img->data;
    int sy;
    for(sy=0; ret && (sy<img->height); sy+=sprite_height, sprite_line+=sprite_stride) {
        uint8_t *sprite_ptr = sprite_line;
        int sx;
        for(sx=0; ret && (sx<img->width); sx+=sprite_width, sprite_ptr+=sprite_width) {
            uint8_t *line = sprite_ptr;
            int j;
            for(j=0; ret && (j<sprite_height); j+=16, line+=stride) {
                int i;
                uint8_t *in = line;
                for(i=0; ret && (i<sprite_width); i+=16, out+=128, in+=16) {
                    ret = pce_bitmap_to_sprite(in, out, img->width);
                }
            }
        }
    }

    *size = out - buffer;
    return ret;
}

void pce_color_convert(uint8_t *in, uint8_t *out, int color_count) {
    int i;
    for(i=0; i<color_count; i++, in+=3) {
        *out++ = ((in[1] << 1) & 0xc0) | ((in[0] >> 2) & 0x38) | (in[2] >> 5);
        *out++ = ((in[1] >> 7) & 0x01);
    }
}
