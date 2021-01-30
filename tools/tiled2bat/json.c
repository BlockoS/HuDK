/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2021 MooZ
 */
#include "json.h"

#include <errno.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include <jansson.h>
#include <cwalk.h>

#include "../utils/log.h"
#include "../utils/image.h"
#include "../utils/pce.h"
#include "../utils/utils.h"
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
    *value = (int)json_integer_value(object);
    return 1;
}

static int json_read_string(json_t* node, const char* name, const char** value) {
    json_t *object = json_object_get(node, name);
    if(!object) {
        return 0;
    }
    if(!json_is_string(object)) {
        return 0;
    }
    *value = json_string_value(object);
    return 1;
}

static int json_read_tilesets(tilemap_t *map, char *path, json_t* node) {
    size_t index;
    json_t *value;

    json_array_foreach(node, index, value) {
        int first_gid, tile_count, tile_width, tile_height, columns, margin, spacing;
        const char *name = NULL, *image_filename = NULL;
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

        char *filename = path_join(path, image_filename);
        if(filename == NULL) {
            return 0;
        }
        
        int ret = tileset_load(&map->tileset[index], name, filename, first_gid, tile_count, tile_width, tile_height, margin, spacing, columns);
        free(filename);
        if(!ret) {
            return 0;
        }
    }
    return 1;
}

static int json_read_tilemap_data(tilemap_t *map, json_t* layer) {
    int index, width, height;
    const char *name = NULL;
    json_t *data;
    json_t *value;

    if(!json_read_string(layer, "name", &name)) {
            log_error("failed to get layer name");
            return 0;
    }

    int layer_index = map->layer_count;
    if(!tilemap_add_layer(map, name)) {
        return 0;
    }

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
        map->layer[layer_index].data[index] = (uint32_t)json_integer_value(value);
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
    const char *name;
    int width;
    int height;
    int tile_width;
    int tile_height;
    int tileset_count;
    size_t index, len;
    char *map_name;

    root = json_load_file(filename, 0, &error);
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

    tileset = json_object_get(root, "tilesets");
    if(!json_is_array(tileset)) {
        log_error("failed to get tilesets");
        return 0;
    }
    tileset_count = json_array_size(tileset);

    map_name = basename_no_ext(filename);
    if(!tilemap_create(map, map_name, width, height, tile_width, tile_height, tileset_count)) {
        log_error("failed to create tileset %s", map_name);
        free(map_name);
        return 0;
    }
    free(map_name);

    array = json_object_get(root, "layers");
    if(!json_is_array(array)) {
        log_error("layers is not an array");
        return 0;
    }

    json_array_foreach(array, index, layer) {
        if(!json_read_string(layer, "name", &name)) {
            log_error("failed to get layer name");
            return 0;
        }

        if(!json_read_tilemap_data(map, layer)) {
            log_error("failed read tilemap %s", name);
            return 0;
        }
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

int json_write_tilemap(tilemap_t *map) {
    int ret;
    
    json_t *root = json_object();

    json_object_set(root, "type", json_string("map"));
    json_object_set(root, "version", json_real(1.2));
    json_object_set(root, "tiledversion", json_string("1.2.4"));
    json_object_set(root, "infinite", json_false());
    json_object_set(root, "orientation", json_string("orthogonal"));
    json_object_set(root, "renderorder", json_string("right-down"));
    json_object_set(root, "nextobjectid", json_integer(1));

    json_object_set(root, "width", json_integer(map->width));
    json_object_set(root, "height", json_integer(map->height));

    json_object_set(root, "tilewidth", json_integer(map->tile_width));
    json_object_set(root, "tileheight", json_integer(map->tile_height));
 
    json_object_set(root, "nextlayerid", json_integer(map->layer_count+1));
 
    // layers
    json_t *layers = json_array();
    for(int i=0; i<map->layer_count; i++) {
        json_t *layer = json_object();

        json_object_set(layer, "id", json_integer(i+1));
        json_object_set(layer, "name", json_string(map->layer[i].name));
        json_object_set(layer, "type", json_string("tilelayer"));
        json_object_set(layer, "visible", json_true());
        json_object_set(layer, "width", json_integer(map->width));
        json_object_set(layer, "height", json_integer(map->height));
        json_object_set(layer, "x", json_integer(0));
        json_object_set(layer, "y", json_integer(0));
        json_object_set(layer, "opacity", json_integer(1));

        json_t *data = json_array();
        for(int j=0; j<map->width*map->height; j++) {
             json_array_append_new(data, json_integer(1 + map->layer[i].data[j]));
        }
        json_object_set(layer, "data", data);

        json_array_append_new(layers, layer);
    }
    json_object_set(root, "layers", layers);

    // tilesets
    json_t *tilesets = json_array();
    for(int i=0; i<map->tileset_count; i++) {
        char image_filename[64];

        json_t *tileset = json_object();

        json_object_set(tileset, "name", json_string(map->tileset[i].name));
        json_object_set(tileset, "firstgid", json_integer(1+map->tileset[i].first_gid));
        json_object_set(tileset, "margin", json_integer(0));
        json_object_set(tileset, "spacing", json_integer(0));
        json_object_set(tileset, "transparentcolor", json_string("#ff00ff"));
        json_object_set(tileset, "tilewidth", json_integer(map->tileset[i].tile_width));
        json_object_set(tileset, "tileheight", json_integer(map->tileset[i].tile_height));
        json_object_set(tileset, "tilecount", json_integer(map->tileset[i].tile_count));
        json_object_set(tileset, "imagewidth", json_integer(map->tileset[i].tile_width * map->tileset[i].tile_count));
        json_object_set(tileset, "imageheight", json_integer(map->tileset[i].tile_height));
        json_object_set(tileset, "columns", json_integer(map->tileset[i].tile_count > 8 ? 8 : map->tileset[i].tile_count));
       
        snprintf(image_filename, 64, "tileset_%04d.png", i);
        json_object_set(tileset, "image", json_string(image_filename));
       
        json_array_append_new(tilesets, tileset);

        tileset_write(map->tileset + i, image_filename);
    }
    json_object_set(root, "tilesets", tilesets);

    size_t len = strlen(map->name) + 6;
    char *filename = (char*)malloc(len);
    snprintf(filename, len, "%s.json", map->name);

    ret = json_dump_file(root, filename, 0);
    json_decref(root);
    
    free(filename);

    return ret;
}
