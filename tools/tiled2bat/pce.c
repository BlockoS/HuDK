/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2019 MooZ
 */
#include <stdio.h>
#include <string.h>

#include "pce.h"

int pce_bitmap_to_tile(uint8_t *in, uint8_t *out, int stride) {
    int y;
    uint8_t *line = in;
    for(y=0; y<8; y++, line+=stride, out+=2) {
        int x;
        uint8_t *src = line;
        out[0] = out[1] = out[16] = out[17] = 0;
        for(x=7; x>=0; x--) {
            uint8_t byte = *src++;
            if(byte >= 16) {
                fprintf(stderr, "invalid input. The image must contain at most 16 colors\n");
                return 0;
            }
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
            if(byte >= 16) {
                fprintf(stderr, "invalid input. The image must contain at most 16 colors.\n");
                return 0;
            }
            out[1 ] |= ((byte   ) & 0x01) << x;
            out[33] |= ((byte>>1) & 0x01) << x;
            out[65] |= ((byte>>2) & 0x01) << x;
            out[97] |= ((byte>>3) & 0x01) << x;
        }
        for(x=7; x>=0; x--) {
            uint8_t byte = *src++;
            if(byte >= 16) {
                fprintf(stderr, "invalid input. The image must contain at most 16 colors.\n");
                return 0;
            }
            out[0 ] |= ((byte   ) & 0x01) << x;
            out[32] |= ((byte>>1) & 0x01) << x;
            out[64] |= ((byte>>2) & 0x01) << x;
            out[96] |= ((byte>>3) & 0x01) << x;
        }
    }
    return 1;
}

int pce_image_to_tiles(image_t *img, int bloc_width, int bloc_height, uint8_t *buffer, size_t *size) {
    *size = 0;
    if((img->height & 7) && (img->width & 7)) {
        fprintf(stderr, "input width and height should be a multiple of 8 (%d,%d)\n", img->width, img->height);
        return 0;
    }
    if((bloc_width & 7) || (bloc_height & 7)) {
        fprintf(stderr, "bloc width and height must be a multiple of 8 (%d, %d)\n", bloc_width, bloc_height);
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
        fprintf(stderr, "input width and height should be a multiple of 16 (%d,%d)\n", img->width, img->height);
        return 0;
    }
    
    if((sprite_width & 15) || ((sprite_width != 16) && (sprite_width != 32))) {
        fprintf(stderr, "sprite width must be 16 or 32 (%d)\n", sprite_width);
        return 0;
    }
    
    if((sprite_height & 15) || ((sprite_height != 16) && (sprite_height != 32) && (sprite_height != 64))) {
        fprintf(stderr, "sprite height must be 16, 32 or 64 (%d)\n", sprite_height);
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
