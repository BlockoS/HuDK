/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2019 MooZ
 */
#include "tilemap.h"

#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "log.h"

void tilemap_destroy(tilemap_t *map) {
    if(map->layer) {
        for(int i=0; i<map->layer_count; i++) {
            if(map->layer[i].name) {
                free(map->layer[i].name);
            }
            if(map->layer[i].data) {
                free(map->layer[i].data);
            }
        }
        free(map->layer);
    }
    if(map->name) {
        free(map->name);
    }
    if(map->tileset) {
        free(map->tileset);
    }
    memset(map, 0, sizeof(tilemap_t));
}

int tilemap_create(tilemap_t *map, const char *name, int width, int height, int tile_width, int tile_height, int tileset_count) {
    memset(map, 0, sizeof(tilemap_t));
    map->name = strdup(name);
    if(map->name == NULL) {
        log_error("failed to set tilemap name: %s", strerror(errno));
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

int tilemap_add_layer(tilemap_t *map, const char *name) {
    int next_layer_count = map->layer_count+1;
    tilemap_layer_t *layers = (tilemap_layer_t*)realloc(map->layer, next_layer_count * sizeof(tilemap_layer_t));
    if(layers == NULL) {
        log_error("failed to add layer %s: %s", name, strerror(errno));
        return 0;
    }
    layers[map->layer_count].name = strdup(name);
    layers[map->layer_count].data = (uint32_t*)malloc(map->width * map->height * sizeof(uint32_t));
    if(layers[map->layer_count].data == NULL) {
        log_error("failed to allocate layer %s data: %s", name, strerror(errno));
        return 0;
    }
    map->layer = layers;
    map->layer_count = next_layer_count;
    return 1;
}
