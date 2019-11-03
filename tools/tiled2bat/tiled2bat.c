/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2019 MooZ
 */
#include <errno.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include <argparse/argparse.h>

#include <cwalk.h>

#include "log.h"
#include "image.h"
#include "pce.h"
#include "output.h"
#include "tileset.h"
#include "tilemap.h"
#include "json.h"
#include "xml.h"

static int tileset_write_palette(tileset_t *tileset, uint8_t *palette, int count) {
    int ret = 1;
    FILE *out;
    size_t nwritten;
    size_t len = strlen(tileset->name) + 5;
    char *filename = (char*)malloc(len);
    if(filename == NULL) {
        log_error("failed to allocate filename: %s", strerror(errno));
        return 0;
    }

    snprintf(filename, len, "%s.pal", tileset->name);
    out = fopen(filename, "wb");
    if(out == NULL) {
        log_error("failed to open %s: %s", filename, strerror(errno));
        ret = 0;
    }

    len = count * 2 * 16;
    nwritten = fwrite(palette, 1, len, out);
    if(nwritten != len) {
        log_error("failed to write %s: %s", filename, strerror(errno));
        ret = 0;
    }
    fclose(out);

    free(filename);
    return ret;
}

static int tileset_write_bin(tileset_t *tileset, uint8_t *buffer, size_t size) {
    int ret = 1;
    FILE *out;
    size_t nwritten;
    size_t len = strlen(tileset->name) + 5;
    char *filename = (char*)malloc(len);
    if(filename == NULL) {
        log_error("failed to allocate filename: %s", strerror(errno));
        return 0;
    }

    snprintf(filename, len, "%s.bin", tileset->name);
    out = fopen(filename, "wb");
    if(out == NULL) {
        log_error("failed to open %s: %s", filename, strerror(errno));
        free(filename);
        return 0;
    }
    free(filename);

    nwritten = fwrite(buffer, 1, size, out);
    if(nwritten != size) {
        log_error("failed to write %s: %s", filename, strerror(errno));
        ret = 0;
    }
    fclose(out);
    return ret;
}

static int tileset_encode(tileset_t *tileset) {
    int ret;
    size_t size;
    uint8_t *buffer;

    image_t img = {
        tileset->tiles,
        tileset->tile_width * tileset->tile_count,
        tileset->tile_height,
        1,
        NULL,
        0
    };

    if(tileset->palette_count > 16) {
        log_error("invalid palette count: %d (max: 16)", tileset->palette_count);
        return 0;
    }

    size = (int)(img.width * img.height / 8) * 4;
    buffer = (uint8_t*)malloc(size);
    if(buffer == NULL) {
        log_error("failed to allocate buffer: %s", strerror(errno));
        return 0;
    }

    ret = pce_image_to_tiles(&img, tileset->tile_width, tileset->tile_height, buffer, &size);
    if(ret) {
        ret = tileset_write_bin(tileset, buffer, size);
    }
    free(buffer);

    if(!ret) {
        return 0;
    }

    buffer = (uint8_t*)malloc(tileset->palette_count * 16 * 2);
    if(buffer == NULL) {
        log_error("failed to allocate buffer: %s", strerror(errno));
        return 0;
    }
    pce_color_convert(tileset->palette, buffer, tileset->palette_count);
    ret = tileset_write_palette(tileset, buffer, tileset->palette_count);
    free(buffer);

    return ret;
}

static int tilemap_encode(tilemap_t *map, int vram_base) {
    FILE *out;
    size_t len = strlen(map->name) + 5;
    char *filename = (char*)malloc(len);
    if(filename == NULL) {
        log_error("failed to allocate filename: %s", strerror(errno));
        return 0;
    }

    snprintf(filename, len, "%s.bin", map->name);
    out = fopen(filename, "wb");
    if(out == NULL) {
        log_error("failed to open %s: %s", filename, strerror(errno));
        free(filename);
        return 0;
    }
    free(filename);

    len = map->width*map->height;
    for(size_t i=0; i<len; i++) {
        unsigned int tile_id;
        size_t j;
        size_t start, end;
        uint8_t data[2];
        uint16_t id = map->data[i];
        uint8_t palette = 0; // [todo] palette start
        uint16_t vram_addr = vram_base;
        size_t stride = 0;
        end = 0;
        for(j=0; j<map->tileset_count; j++) {
            start = end;
            end += map->tileset[j].tile_count;
            tile_id = id-start;
            stride = map->tileset[j].tile_width * map->tileset[j].tile_height / 2;
            palette = map->tileset[j].palette_index[tile_id];
            if((id >= start) && (id < end)) {
                vram_addr += (tile_id * stride);
                break;
            }
            vram_addr += stride * map->tileset[j].tile_count;
            palette += map->tileset[j].palette_count;
        }

        data[0] = (vram_addr >> 4) & 0xff;
        data[1] = ((vram_addr >> 12) & 0x0f) | (palette << 4);
        fwrite(data, 1, 2, out);    
    }
    fclose(out);
    return 1;
}

int main(int argc, const char **argv) {
    int ret = EXIT_FAILURE;

    static const char *const usages[] = {
        "tiled2bat [options] <in>",
        NULL
    };

    // [todo] add palette start

    int tile_vram_base = -1;
    struct argparse_option options[] = {
        OPT_HELP(),
        OPT_INTEGER('b', "base", &tile_vram_base, "tiles VRAM address", NULL, 0, 0),
        OPT_END(),
    };

    struct argparse argparse;
    const char *extension;
    size_t len;

    argparse_init(&argparse, options, usages, 0);
    argparse_describe(&argparse, "\nTiled2bat : Convert Tiled json to PC Engine", "  ");
    argc = argparse_parse(&argparse, argc, argv);
    if((!argc) || (tile_vram_base < 0)) {
        argparse_usage(&argparse);
        return EXIT_FAILURE;
    }

    tilemap_t map = {0};

    ret = cwk_path_get_extension(argv[0], &extension, &len);
    if(!ret) {
        log_warn("failed to retrieve file extension %s", argv[0]);
    }
    
    if(ret) {
        if(!strncmp(extension, ".json", len)) {
            ret = json_read_tilemap(&map, argv[0]);
        }
        else if(!strncmp(extension, ".tmx", len)) {
            ret = xml_read_tilemap(&map, argv[0]);
        }
        else {
            ret = 0;
            log_warn("unknown extension %s", extension);
        }

        // [todo] write tilesets and palette in a single file
        for(int i = 0; ret && (i < map.tileset_count); i++) {
            ret = tileset_encode(&map.tileset[i]);
        }

        tilemap_encode(&map, tile_vram_base);
    }

    tilemap_destroy(&map);
    return ret ? EXIT_SUCCESS : EXIT_FAILURE;
}
