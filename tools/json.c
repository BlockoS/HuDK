/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2019 MooZ
 */
#include "json.h"

#include <errno.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include <jansson.h>
#include <cwalk.h>

#include "log.h"
#include "image.h"
#include "pce.h"
#include "output.h"
#include "tilemap.h"
#include "tileset.h"

static int json_read_integer(json_t* node, const char* name, int* value) {
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

static int json_read_string(json_t* node, const char* name, char** value) {
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

static int json_read_tilesets(tilemap_t *map, char *path, json_t* node) {
    size_t index;
    json_t *value;

    json_array_foreach(node, index, value) {
        int first_gid, tile_count, tile_width, tile_height, columns, margin, spacing;
        char *name = NULL, *image_filename = NULL;
        if(!json_read_string(value, "name", &name)) {
            log_error("failed to get tileset name");
            return 0;
        }
        if(!json_read_string(value, "image", &image_filename)) {
            log_error("failed to get tileset image");
            return 0;
        }
        if(!json_read_integer(value, "firstgid", &first_gid)) {
            log_error("failed to get tileset first tile id");
            return 0;
        }
        if(!json_read_integer(value, "tilecount", &tile_count)) {
            log_error("failed to get tile count");
            return 0;
        }        
        if(!json_read_integer(value, "tilewidth", &tile_width)) {
            log_error("failed to get tile width");
            return 0;
        }
        if(!json_read_integer(value, "tileheight", &tile_height)) {
            log_error("failed to get tile height");
            return 0;
        }
        if(!json_read_integer(value, "spacing", &spacing)) {
            log_error("failed to get tileset spacing");
            return 0;
        }
        if(!json_read_integer(value, "margin", &margin)) {
            log_error("failed to get tileset margin");
            return 0;
        }
        if(!json_read_integer(value, "columns", &columns)) {
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

static int json_read_tilemap_data(tilemap_t *map, json_t* layer) {
    int index, width, height;
    json_t *data;
    json_t *value;

    if(!json_read_integer(layer, "width", &width)) {
        log_error("failed to get layer width");
        return 0;
    }
    if(!json_read_integer(layer, "height", &height)) {
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

int json_read_tilemap(tilemap_t *map, const char *filename) {
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

    if(!json_read_integer(root, "width", &width)) {
        log_error("faile to get tilemap width");
        return 0;
    }
    if(!json_read_integer(root, "height", &height)) {
        log_error("faile to get tilemap height");
        return 0;
    }
    if(!json_read_integer(root, "tilewidth", &tile_width)) {
        log_error("faile to get tile width");
        return 0;
    }
    if(!json_read_integer(root, "tileheight", &tile_height)) {
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

    if(!json_read_string(layer, "name", &name)) {
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

    if(!json_read_tilemap_data(map, layer)) {
        log_error("failed read tilemap %s", name);
        return 0;
    }

    path = strdup(filename);
    cwk_path_get_dirname(path, &len);
    path[len] = '\0';

    int ret = 1;
    if(!json_read_tilesets(map, path, tileset)) {
        log_error("failed to read tileset %s", path);
        ret = 0;
    }
    
    free(path);
    json_decref(root);

    return ret; 
}
