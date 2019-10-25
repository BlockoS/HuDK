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

#include <libgen.h> // [todo] posix :/

#include <jansson.h>

#include <argparse/argparse.h>

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

        if(tileset_create(&map->tileset[index], tile_count, tile_width, tile_height)) {
            int ret;
            image_t img;

            size_t path_len = strlen(path);
            size_t filename_len = strlen(image_filename);
            char *filename = (char*)malloc(path_len + filename_len + 2);

            strncpy(filename, path, path_len);
            filename[path_len] = '/';
            strncpy(filename+path_len+1, image_filename, filename_len);

            ret = image_load_png(&img, filename);
            free(filename);
            if(ret) {
                int i = 0;
                for(int y=margin; y<img.height; y+=spacing+tile_height) {
                    for(int x=margin, c=0; (x<img.width) && (c<columns); x+=spacing+tile_width, i++, c++) {
                        if(!tileset_add(&map->tileset[index], i, &img, x, y)) {
                            // [todo]
                        }
                    }
                }
            }
            else {
                // [todo]
            }
            image_destroy(&img);
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
    char *source_path;
    char *name;
    int width;
    int height;
    int tile_width;
    int tile_height;
    int tileset_count;

    root = json_load_file(filename, 0, &error);
    if(!root) {
        log_error("%s:%d:%d %s", filename, error.line, error.column, error.text);
        return 0;
    }

    path = realpath(filename, NULL);
    if(path == NULL) {
        // [todo]
        return 0;
    }

    source_path = dirname(path);

    if(!read_integer(root, "width", &width)) {
        log_error("faile to get tilemap width");
        // [todo]
    }
    if(!read_integer(root, "height", &height)) {
        log_error("faile to get tilemap height");
        // [todo]
    }
    if(!read_integer(root, "tilewidth", &tile_width)) {
        log_error("faile to get tile width");
        // [todo]
    }
    if(!read_integer(root, "tileheight", &tile_height)) {
        log_error("faile to get tile height");
        // [todo]
    }
    
    if(tile_width & 0x07) {
        log_error("tile width (%d) must be a multiple of 8", tile_width); 
        // [todo]
    }
    if(tile_height & 0x07) {
        log_error("tile height (%d) must be a multiple of 8", tile_height); 
        // [todo]
    }

    array = json_object_get(root, "layers");
    if(!json_is_array(array)) {
        log_error("layers is not an array");
        // [todo]
    }
    if(json_array_size(array) != 1) {
        log_error("layers must contain only 1 element");
        // [todo]
    }
    layer = json_array_get(array, 0);
    if(!layer) {
        log_error("failed to get layer #0");
        // [todo]
    }

    if(!read_string(layer, "name", &name)) {
        log_error("failed to get layer name");
        // [todo]
    }

    tileset = json_object_get(root, "tilesets");
    if(!json_is_array(tileset)) {
        // [todo]
    }
    tileset_count = json_array_size(tileset);

    if(!tilemap_create(map, name, width, height, tile_width, tile_height, tileset_count)) {
        // [todo]
    }

    if(!tilemap_read_data(map, layer)) {
        // [todo]
    }

    if(!tilemap_read_tilesets(map, source_path, tileset)) {
        // [todo]
    }
    
    free(path);
    json_decref(root);

    return 1;    
}

#if 0
static int tileset_encode(tileset_t *tileset) {
    int ret;

    image_t img = {
        tileset->tiles,
        width,
        height,
        1,
        NULL,
        0
    };
    pce_image_to_tiles(&img, tileset->tile_width, tileset->tile_height, out, size);

    return ret;
}
#endif
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
        return 0;
    }

    tilemap_t map = {0};

    if(tilemap_read(&map, argv[0])) {
        ret = EXIT_SUCCESS;
    }
    
    // [todo] convert
#if 0
    for(int i=0; i<map.tileset_count; i++) {
        char filename[256];
        FILE *out;
        sprintf(filename, "%04d.pgm", i);
        out = fopen(filename, "wb");
        fprintf(out, "P5\n%d %d\n15\n", map.tileset[i].tile_count * map.tileset[i].tile_width, map.tileset[i].tile_height);
        fwrite(map.tileset[i].tiles, 1, map.tileset[i].tile_count * map.tileset[i].tile_width * map.tileset[i].tile_height, out);
        fclose(out);
    }
#endif
    tilemap_destroy(&map);
    return ret;
}
