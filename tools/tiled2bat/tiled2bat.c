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

static int tileset_encode_palettes(tileset_t *tileset, FILE *out) {
    int ret = 1;
    size_t len = tileset->palette_count * 2 * 16;
    uint8_t *buffer = (uint8_t*)malloc(len);
    if(buffer == NULL) {
        log_error("failed to allocate buffer: %s", strerror(errno));
        return 0;
    }

    pce_color_convert(tileset->palette, buffer, tileset->palette_count*16);
    
    size_t nwritten = fwrite(buffer, 1, len, out);
    if(nwritten != len) {
        log_error("failed to write tilesette %s palette: %s", tileset->name, strerror(errno));
        ret = 0;
    }
    free(buffer);
    return ret;
}

static int tileset_encode_tiles(tileset_t *tileset, FILE *out) {
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
        size_t nwritten = fwrite(buffer, 1, size, out);
        if(nwritten != size) {
            log_error("failed to write %s: %s", tileset->name, strerror(errno));
            ret = 0;
        }
    }
    free(buffer);
    return ret;
}

static int tilemap_encode(tilemap_t *map, int vram_base, int palette_start) {
    for(size_t i=0, n=0; i<map->tileset_count; i++) {
        n += map->tileset[i].palette_count;
        if(n > 16) {
            log_error("too many palettes in tileset (max: 16)");
            return 0;
        }
    }

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

    len = map->width*map->height;
    for(size_t i=0; i<len; i++) {
        uint8_t id = map->data[i] - 1;
        fwrite(&id, 1, 1, out);
    }
    fclose(out);

    snprintf(filename, len, "%s_tilepal.bin", map->name);
    out = fopen(filename, "wb");
    if(out == NULL) {
        log_error("failed to open %s: %s", filename, strerror(errno));
        free(filename);
        return 0;
    }
    for(size_t i=0, n=0; i<map->tileset_count; i++) {
        for(size_t j=0; j<map->tileset[i].tile_count; j++) {
            uint8_t id = (n + map->tileset[i].palette_index[j]) << 4;
            fwrite(&id, 1, 1, out);
        }
        n += map->tileset[i].palette_count;
    }
    fclose(out);

    snprintf(filename, len, "%s.tiles", map->name);
    out = fopen(filename, "wb");
    if(out == NULL) {
        log_error("failed to open %s: %s", filename, strerror(errno));
        return 0;
    }
    for(size_t i=0; i<map->tileset_count; i++) {
        if(!tileset_encode_tiles(&map->tileset[i], out)) {
            fclose(out);
            return 0;
        }
    }
    fclose(out);

    snprintf(filename, len, "%s.pal", map->name);
    out = fopen(filename, "wb");
    if(out == NULL) {
        log_error("failed to open %s: %s", filename, strerror(errno));
        return 0;
    }
    for(size_t i=0; i<map->tileset_count; i++) {
        if(!tileset_encode_palettes(&map->tileset[i], out)) {
            fclose(out);
            return 0;
        }
    }
    fclose(out);

    snprintf(filename, len, "%s.inc", map->name);
    out = fopen(filename, "wb");
    if(out == NULL) {
        log_error("failed to open %s: %s", filename, strerror(errno));
        free(filename);
        return 0;
    }

    fprintf(out, "%s_width = %d\n", map->name, map->width);
    fprintf(out, "%s_height = %d\n", map->name, map->height);
    fprintf(out, "%s_tile_width = %d\n", map->name, map->tile_width);
    fprintf(out, "%s_tile_height = %d\n", map->name, map->tile_height);
    fprintf(out, "%s_tile_vram = $%04x\n", map->name, vram_base);
    fprintf(out, "%s_tile_pal = %d\n", map->name, palette_start);

    fclose(out);
    free(filename);

    return 1;
}

int main(int argc, const char **argv) {
    int ret = EXIT_FAILURE;

    static const char *const usages[] = {
        "tiled2bat [options] <in>",
        NULL
    };

    int tile_vram_base = 0;
    int palette_start = 0;
    struct argparse_option options[] = {
        OPT_HELP(),
        OPT_INTEGER('b', "base", &tile_vram_base, "tiles VRAM address", NULL, 0, 0),
        OPT_INTEGER('p', "pal", &palette_start, "first palette index", NULL, 0, 0),
        OPT_END(),
    };

    struct argparse argparse;
    const char *extension;
    size_t len;

    argparse_init(&argparse, options, usages, 0);
    argparse_describe(&argparse, "\nTiled2bat : Convert Tiled json to PC Engine", "  ");
    argc = argparse_parse(&argparse, argc, argv);
    if(!argc) {
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

        if(ret) {
            tilemap_encode(&map, tile_vram_base, palette_start);
        }
    }

    tilemap_destroy(&map);
    return ret ? EXIT_SUCCESS : EXIT_FAILURE;
}
