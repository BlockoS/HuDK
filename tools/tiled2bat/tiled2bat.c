/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2021 MooZ
 */
#include <errno.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include <argparse/argparse.h>

#include <cwalk.h>

#include "../utils/log.h"
#include "../utils/image.h"
#include "../utils/pce.h"
#include "../utils/output.h"
#include "tileset.h"
#include "tilemap.h"
#include "json.h"
#include "xml.h"

enum OutputLanguage {
    OutputASM = 0,
    OutputC,
    OutputLanguageCount
};

static int tileset_encode_palettes(tileset_t *tileset, FILE *out) {
    int ret = 1;
    size_t len = (size_t)tileset->palette_count * 2 * 16;
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

static int tilemap_encode(tilemap_t *map, int vram_base, int palette_start, int lang) {
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

    for(int i=0; i<map->layer_count; i++) {
        size_t map_filename_len = strlen(map->layer[i].name); 
        char *map_filename = (char*)malloc(map_filename_len+5);
        if(map_filename == NULL) {
            log_error("failed to allocate filename for layer %s: %s", map->layer[i].name, strerror(errno));
            return 0;
        }
        snprintf(map_filename, len, "%s.map", map->layer[i].name);
        out = fopen(map_filename, "wb");
        if(out == NULL) {
            log_error("failed to open %s: %s", map_filename, strerror(errno));
            free(map_filename);
            return 0;
        }

        len = map->width * map->height;
        for(size_t j=0; j<len; j++) {
            uint8_t id = (map->layer[i].data[j] & 0xff);
            fwrite(&id, 1, 1, out);
        }
        fclose(out);
        free(map_filename);
    }

    snprintf(filename, len, "%s.idx", map->name);
    out = fopen(filename, "wb");
    if(out == NULL) {
        log_error("failed to open %s: %s", filename, strerror(errno));
        free(filename);
        return 0;
    }
    for(size_t i=0, n=0; i<map->tileset_count; i++) {
        for(size_t j=0; j<map->tileset[i].tile_count; j++) {
            uint8_t id = (uint8_t)(n + map->tileset[i].palette_index[j]) << 4;
            fwrite(&id, 1, 1, out);
        }
        n += map->tileset[i].palette_count;
    }
    fclose(out);

    snprintf(filename, len, "%s.bin", map->name);
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

    if(lang == OutputASM) {
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
    } 
    else {
        snprintf(filename, len, "%s.h", map->name);
        out = fopen(filename, "wb");
        if(out == NULL) {
            log_error("failed to open %s: %s", filename, strerror(errno));
            free(filename);
            return 0;
        }

        fprintf(out, "#define %s_width %d\n", map->name, map->width);
        fprintf(out, "#define %s_height %d\n", map->name, map->height);
        fprintf(out, "#define %s_tile_width %d\n", map->name, map->tile_width);
        fprintf(out, "#define %s_tile_height %d\n", map->name, map->tile_height);
        fprintf(out, "#define %s_tile_vram 0x%04x\n", map->name, vram_base);
        fprintf(out, "#define %s_tile_pal %d\n", map->name, palette_start);

        fclose(out);
    }

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
    int write_tilemap = 0;
    int lang = OutputASM;
    const char *lang_str = NULL;
    struct argparse_option options[] = {
        OPT_HELP(),
        OPT_INTEGER('b', "base", &tile_vram_base, "tiles VRAM address", NULL, 0, 0),
        OPT_INTEGER('p', "pal", &palette_start, "first palette index", NULL, 0, 0),
        OPT_STRING('l', "lang", &lang_str, "output langage (\"c\" or \"asm\")", NULL, 0, 0),
        OPT_BOOLEAN('w', "write", &write_tilemap, "write optimized tilemap", NULL, 0, 0),
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

    if(lang_str != NULL) {
        if(strcmp(lang_str, "c") == 0) {
            lang = OutputC;
        }
        else if(strcmp(lang_str, "asm") == 0) {
            lang = OutputASM;
        }
        else {
            fprintf(stderr, "[error] invalid language: %s\n", lang_str);
            argparse_usage(&argparse);
            return EXIT_FAILURE;
        }
    }

    tilemap_t map = {0};

    ret = cwk_path_get_extension(argv[0], &extension, &len);
    if(!ret) {
        log_error("failed to retrieve file extension %s", argv[0]);
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
            ret = tilemap_compress(&map);
            if(ret) {
                ret = tilemap_encode(&map, tile_vram_base, palette_start, lang);
                if(!ret) {
                    log_error("failed to encode tilemap");
                }
            }
            else {
                log_error("failed to optimize tilemap");
            }
            if(ret && write_tilemap) {
                ret = json_write_tilemap(&map);
                if(!ret) {
                    log_error("failed to write optimized tilemap");
                }
            }
        }
    }

    tilemap_destroy(&map);
    return ret ? EXIT_SUCCESS : EXIT_FAILURE;
}
