/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2020 MooZ
 */
#include "image.h"

#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <png.h>
#include <zlib.h>

#include "log.h"

int image_create(image_t* img, int width, int height, int bpp, int color_count) {
    img->width  = width;
    img->height = height;
    img->bytes_per_pixel = bpp;
    
    img->color_count = color_count;
    
    img->data = (uint8_t*)malloc(width*height*bpp*sizeof(uint8_t));
    if(img->data == NULL) {
        return 0;
    }
    
    if(color_count) {
        img->palette = (uint8_t*)malloc(color_count*3*sizeof(uint8_t));
        if(img->palette == NULL) {
            free(img->data);
            img->data = NULL;
            return 0;
        }
    }
    else {
        img->palette = NULL;
    }
    return 1;
}

void image_destroy(image_t* img) {
    if(img->data != NULL) {
        free(img->data);
    }
    if(img->palette != NULL) {
        free(img->palette);
    }
    memset(img, 0, sizeof(image_t));
}

/* PNG */
int image_load_png(image_t *dest, const char* filename) {
    int ret;
    png_image image;
    
    memset(dest, 0, sizeof(image_t));
    
    memset(&image, 0, sizeof(png_image));    
    image.version = PNG_IMAGE_VERSION;
    
    ret = png_image_begin_read_from_file(&image, filename);
    if(!ret) {
        log_error("read error: %s %s", filename, image.message);        
    }

    if(ret) {
        dest->width  = image.width;
        dest->height = image.height;
        dest->bytes_per_pixel = PNG_IMAGE_PIXEL_COMPONENT_SIZE(image.format);
        dest->data = (uint8_t*)malloc(PNG_IMAGE_SIZE(image));
        if(dest->data == NULL) {
            log_error("unable to allocate buffer: %s", strerror(errno));
            ret = 0;
        }
    }
    
    if(ret && image.colormap_entries) {
        dest->color_count = image.colormap_entries;
        dest->palette = (uint8_t*)malloc(PNG_IMAGE_COLORMAP_SIZE(image));
        if(dest->palette == NULL) {
            log_error("unable to allocate buffer: %s", strerror(errno));
            ret = 0;
        }
    }

    if(ret) {
        ret = png_image_finish_read(&image, NULL, dest->data, 0, dest->palette);
        if(ret == 0) {
            log_error("read error: %s", image.message);
        }
    }
    
    if(!ret) {
        image_destroy(dest);
    }
    return ret;
}

/* PCX */
static inline uint16_t pcx_get16(const uint8_t *x) {
    return (x[1]<<8) | x[0];
}

typedef union {
    struct {
        uint8_t manufacturer;
        uint8_t version;
        uint8_t encoding;
        uint8_t bitsperpixel;
        uint8_t xmin[2],  ymin[2];
        uint8_t xmax[2],  ymax[2];
        uint8_t hDpi[2],  vDpi[2];
        uint8_t colormap[48];
        uint8_t reserved;
        uint8_t nplanes;
        uint8_t bitsPerLine[2];
        uint8_t paletteInfo[2];
        uint8_t hscreenSize[2], vscreenSize[2];
        uint8_t filler[54];
    } info;
    uint8_t raw[128];
}pcx_header_t;

static int pcx_read_header(FILE* input, image_t* dest) {
    pcx_header_t header;
    size_t nread;
    nread = fread(header.raw, 1, 128, input);
    if(nread != 128) {
        log_error("failed to read PCX header: %s", strerror(errno));    
        return 0;
    }
    
    dest->bytes_per_pixel = header.info.nplanes;
    if((dest->bytes_per_pixel != 3) && (dest->bytes_per_pixel != 1)) {
        log_error("invalid bytes per pixel");
        return 0;
    }

    dest->width  = pcx_get16(header.info.xmax) - pcx_get16(header.info.xmin) + 1;
    dest->height = pcx_get16(header.info.ymax) - pcx_get16(header.info.ymin) + 1;
    return 1;
}

static int pcx_read_data(FILE* input, image_t* dest) {
    uint8_t *row, *out;
    uint8_t byte;

    size_t nread;

    int x, y, component;

    for(y=0; y<dest->height; y++) {
        row = dest->data + y * dest->width * dest->bytes_per_pixel;
        for(component=0; component<dest->bytes_per_pixel; component++) {
            for(x=0, out=row; x<dest->width; ) {
                nread = fread(&byte, 1, 1, input);
                if(nread != 1) {
                    log_error("read error: %s", strerror(errno));
                    return 0;
                }
                
                /* Check for RLE encoding. */
                if((byte & 0xC0) == 0xC0) {
                    uint8_t count, data;
                    nread = fread(&data, 1, 1, input);
                    if(nread != 1) {
                        log_error("read error: %s", strerror(errno));
                        return 0;
                    }

                    for(count=byte&0x3f; count && (x<dest->width); count--) {
                       *out = data;
                       out += dest->bytes_per_pixel;
                       x++;
                    }
                   
                    if(count && (x >= dest->width)) {
                        log_error("read aborted: malformed PCX data!");
                        return 0;
                    }
                }
                else {
                    *out = byte;
                    out += dest->bytes_per_pixel;
                    x++;
                }
            }
            row++;
        }
    }
    return 1;
}

static int pcx_read_palette(FILE* input, image_t* dest) {
    uint8_t dummy;
    size_t nread;
    
    fseek(input, SEEK_END, -769);
    nread = fread(&dummy, 1, 1, input);
    if(nread != 1) {
        log_error("read error: %s", strerror(errno));
        return 0;
    }
    if(dummy != 0x0C) {
        return 1;
    }
    
    dest->color_count = 256;
    dest->palette = (uint8_t*)malloc(dest->color_count*3*sizeof(uint8_t));
    if(dest->palette == NULL) {
        log_error("failed to allocate palette: %s", strerror(errno));
        return 0;
    }
    
    nread = fread(dest->palette, 1, 3*dest->color_count, input);
    if(nread != 3*dest->color_count) {
        log_error("read error: %s", strerror(errno));
        return 0;
    }
    return 1;
}

int image_load_pcx(image_t* dest, const char* filename) {
    FILE* input;
    int ret = 0;
    
    input = fopen(filename, "rb");
    if(input == NULL) {
        log_error("unable to open file %s: %s", filename, strerror(errno));
        return 0;
    }
    
    if(!(ret = pcx_read_header(input, dest))) {
        log_error("failed to read pcx header from %s", filename);
    }
    
    if(ret) {
        dest->data = (uint8_t*)malloc(dest->width * dest->height * dest->bytes_per_pixel * sizeof(uint8_t));
        if(dest->data != NULL) {
            log_error("failed to allocate image buffer: %s", strerror(errno));
            ret = 0;
        }
    }

    if(ret) {
		ret = pcx_read_data(input, dest);
        if(!ret) {
            log_error("failed to read pcx data from %s", filename);
        }
    }

    if(ret) {
        if(dest->bytes_per_pixel == 1) {
			ret = pcx_read_palette(input, dest);
            if(!ret) {
                log_error("failed to read pcx palette from %s", filename);
            }
        }
        else {
            dest->palette = NULL;
            dest->color_count = 0;
        }
    }
        
    if(!ret) {
        image_destroy(dest);
    }

    fclose(input);
    return ret;
}
