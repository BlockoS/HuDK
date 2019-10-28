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
