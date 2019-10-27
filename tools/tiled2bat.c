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

#include <jansson.h>

#include <argparse/argparse.h>

#include <cwalk.h>

#include "log.h"
#include "image.h"
#include "pce.h"
#include "output.h"
#include "tileset.h"

// [todo] comments !!!!!
// [todo] output infos (size, wrap mode, tile size, incbin, palette)
typedef struct {
    char *name;
    uint8_t *data;
    int width;
    int height;
    int tile_width;
    int tile_height;
    int tileset_count;
    tileset_t *tileset;
} tilemap_t;

void tilemap_destroy(tilemap_t *map) {
    if(map->data) {
        free(map->data);
    }
    if(map->name) {
        free(map->name);
    }
    if(map->tileset) {
        free(map->tileset);
    }
    memset(map, 0, sizeof(tilemap_t));
}

int tilemap_create(tilemap_t *map, char *name, int width, int height, int tile_width, int tile_height, int tileset_count) {
    memset(map, 0, sizeof(tilemap_t));
    map->name = strdup(name);
    if(map->name == NULL) {
        log_error("failed to set tilemap name: %s", strerror(errno));
        return 0;
    }
    map->data = (uint8_t*)malloc(width * height * sizeof(uint8_t));
    if(map->data == NULL) {
        log_error("failed to allocate tilemap data: %s", strerror(errno));
        tilemap_destroy(map);
        return 0;
    }
    map->tileset = (tileset_t*)malloc(tileset_count * sizeof(tileset_t));
    if(map->tileset == NULL) {
        log_error("failed to allocate tilesets: %s", strerror(errno));
        tilemap_destroy(map);
        return 0;
    }
    
    map->tileset_count = tileset_count;

    map->width = width;
    map->height = height;
    map->tile_width = tile_width;
    map->tile_height = tile_height;

    return 1;   
}

// [todo] convert function to pce friendly format

static int read_integer(json_t* node, const char* name, int* value) {
    json_t *object = json_object_get(node, name);
    if(!object) {
        return 0;
    }
    if(!json_is_integer(object)) {
        return 0;
    }
    *value = json_integer_value(object);
    return 1;
}

static int read_string(json_t* node, const char* name, char** value) {
    json_t *object = json_object_get(node, name);
    if(!object) {
        return 0;
    }
    if(!json_is_string(object)) {
        return 0;
    }
    *value = strdup(json_string_value(object));
    return 1;
}

int tilemap_read_tilesets(tilemap_t *map, char *path, json_t* node) {
    size_t index;
    json_t *value;

    json_array_foreach(node, index, value) {
        int first_gid, tile_count, tile_width, tile_height, columns, margin, spacing;
        char *name = NULL, *image_filename = NULL;
        if(!read_string(value, "name", &name)) {
            log_error("failed to get tileset name");
            return 0;
        }
        if(!read_string(value, "image", &image_filename)) {
            log_error("failed to get tileset image");
            return 0;
        }
        if(!read_integer(value, "firstgid", &first_gid)) {
            log_error("failed to get tileset first tile id");
            return 0;
        }
        if(!read_integer(value, "tilecount", &tile_count)) {
            log_error("failed to get tile count");
            return 0;
        }        
        if(!read_integer(value, "tilewidth", &tile_width)) {
            log_error("failed to get tile width");
            return 0;
        }
        if(!read_integer(value, "tileheight", &tile_height)) {
            log_error("failed to get tile height");
            return 0;
        }
        if(!read_integer(value, "spacing", &spacing)) {
            log_error("failed to get tileset spacing");
            return 0;
        }
        if(!read_integer(value, "margin", &margin)) {
            log_error("failed to get tileset margin");
            return 0;
        }
        if(!read_integer(value, "columns", &columns)) {
            log_error("failed to get tileset column count");
            return 0;
        }

        if(tileset_create(&map->tileset[index], name, tile_count, tile_width, tile_height)) {
            int ret;
            image_t img;
            size_t filename_len = strlen(path) + strlen(image_filename) + 2;
            char *filename = (char*)malloc(filename_len);

            size_t len = cwk_path_join(path, image_filename, filename, filename_len);
            if(len != filename_len) {
                filename = (char*)realloc(filename, len+1);
                if(cwk_path_join(path, image_filename, filename, len+1) != len) {
                    // [todo]
                }
            }
            ret = image_load_png(&img, filename);
            if(ret) {
                int i = 0;
                for(int y=margin; ret && (y<img.height); y+=spacing+tile_height) {
                    for(int x=margin, c=0; ret && (x<img.width) && (c<columns); x+=spacing+tile_width, i++, c++) {
                        if(!tileset_add(&map->tileset[index], i, &img, x, y)) {
                            log_error("failed to add tile %d", i);
                            ret = 0;
                        }
                    }
                }
            }
            else {
                log_error("failed to load %s", filename);
            }
            image_destroy(&img);
            free(filename);
        }
    }
    return 1;
}

int tilemap_read_data(tilemap_t *map, json_t* layer) {
    int index, width, height;
    json_t *data;
    json_t *value;

    if(!read_integer(layer, "width", &width)) {
        log_error("failed to get layer width");
        return 0;
    }
    if(!read_integer(layer, "height", &height)) {
        log_error("failed to get layer height");
        return 0;
    }

    if((map->width != width) && (map->height != height)) {
        log_error("data dimensions mismatch (expected: %dx%d, layer: %dx%d)", map->width, map->height, width, height);
        return 0;
    }

    data = json_object_get(layer, "data");
    if(!data) {
        log_error("failed to get layer data");
        return 0;
    }

    json_array_foreach(data, index, value) {
        if(!json_is_integer(value)) {
            log_error("invalid tile value at index %d", index);
            return 0;
        }
        map->data[index] = json_integer_value(value);
    }
    return 1;
}

int tilemap_read(tilemap_t *map, const char *filename) {
    json_error_t error;

    json_t *root;
    json_t *array;
    json_t *layer;
    json_t *tileset;

    char *path;
    char *name;
    int width;
    int height;
    int tile_width;
    int tile_height;
    int tileset_count;
    size_t len;

    root = json_load_file(filename, 0, &error); // [todo] move out of tilemap_read
    if(!root) {
        log_error("%s:%d:%d %s", filename, error.line, error.column, error.text);
        return 0;
    }

    if(!read_integer(root, "width", &width)) {
        log_error("faile to get tilemap width");
        return 0;
    }
    if(!read_integer(root, "height", &height)) {
        log_error("faile to get tilemap height");
        return 0;
    }
    if(!read_integer(root, "tilewidth", &tile_width)) {
        log_error("faile to get tile width");
        return 0;
    }
    if(!read_integer(root, "tileheight", &tile_height)) {
        log_error("faile to get tile height");
        return 0;
    }
    
    if(tile_width & 0x07) {
        log_error("tile width (%d) must be a multiple of 8", tile_width); 
        return 0;
    }
    if(tile_height & 0x07) {
        log_error("tile height (%d) must be a multiple of 8", tile_height); 
        return 0;
    }

    array = json_object_get(root, "layers");
    if(!json_is_array(array)) {
        log_error("layers is not an array");
        return 0;
    }
    if(json_array_size(array) != 1) {
        log_error("layers must contain only 1 element");
        return 0;
    }
    layer = json_array_get(array, 0);
    if(!layer) {
        log_error("failed to get layer #0");
        return 0;
    }

    if(!read_string(layer, "name", &name)) {
        log_error("failed to get layer name");
        return 0;
    }

    tileset = json_object_get(root, "tilesets");
    if(!json_is_array(tileset)) {
        log_error("failed to get tilesets");
        return 0;
    }
    tileset_count = json_array_size(tileset);

    if(!tilemap_create(map, name, width, height, tile_width, tile_height, tileset_count)) {
        log_error("failed to create tileset %s", name);
        tilemap_destroy(map);
        return 0;
    }

    if(!tilemap_read_data(map, layer)) {
        log_error("failed read tilemap %s", name);
        return 0;
    }

    path = strdup(filename);
    cwk_path_get_dirname(path, &len);
    path[len] = '\0';

    int ret = 1;
    if(!tilemap_read_tilesets(map, path, tileset)) {
        log_error("failed to read tileset %s", path);
        ret = 0;
    }
    
    free(path);
    json_decref(root);

    return ret; 
}

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

int main(int argc, const char **argv) {
    int ret = EXIT_FAILURE;

    static const char *const usages[] = {
        "tiled2bat [options] <in>",
        NULL
    };

    struct argparse_option options[] = {
        OPT_HELP(),
        // [todo]
        OPT_END(),
    };

    struct argparse argparse;

    argparse_init(&argparse, options, usages, 0);
    argparse_describe(&argparse, "\nTiled2bat : Convert Tiled json to PC Engine", "  ");
    argc = argparse_parse(&argparse, argc, argv);
    if(!argc) {
        argparse_usage(&argparse);
        return EXIT_FAILURE;
    }

    tilemap_t map = {0};

    ret = tilemap_read(&map, argv[0]);
    
    // [todo] convert
    for(int i = 0; ret && (i < map.tileset_count); i++) {
        ret = tileset_encode(&map.tileset[i]);
    }

    tilemap_destroy(&map);
    return ret ? EXIT_SUCCESS : EXIT_FAILURE;
}
