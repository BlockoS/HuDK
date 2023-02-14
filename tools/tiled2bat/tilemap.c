/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2021 MooZ
 */
#include "tilemap.h"

#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "../utils/log.h"

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
        for(int i=0; i<map->tileset_count; i++) {
            tileset_destroy(map->tileset+i);
        }
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
    layers[map->layer_count].data = (int*)malloc(map->width * map->height * sizeof(int));
    if(layers[map->layer_count].data == NULL) {
        log_error("failed to allocate layer %s data: %s", name, strerror(errno));
        return 0;
    }
    map->layer = layers;
    map->layer_count = next_layer_count;
    return 1;
}

int tilemap_compress(tilemap_t *map) {
    int *id, *dict;
    int *first, *last;
    int total, max_id;
    int i;

    last = (int*)malloc(2 * map->tileset_count * sizeof(int));
    if(last == NULL) {
        log_error("failed to allocate aux buffer.");
        return 0;
    }
    memset(last, 0, map->tileset_count * sizeof(int));

    max_id = 0;
    first = last + map->tileset_count;
    for(i=0, total=0; i<map->tileset_count; i++) {
        int n = map->tileset[i].first_gid + map->tileset[i].tile_count;
        if(n > max_id) {
            max_id = n;
        }

        first[i] = total;
        total += map->tileset[i].tile_count;
    }

    id = (int*)malloc((max_id + total) * sizeof(int));
    if(id == NULL) {
        log_error("failed to allocate id buffer.");
        free(last);
        return 0;
    }
    dict = id + total;
    for(i=0; i<max_id; i++) {
        dict[i] = -1;
    }

    int tiles_used = 0;
    for(i=0; i<map->layer_count; i++) {
        int y;
        for(y=0; y<map->height; y++) {
            int x;
            for(x=0; x<map->width; x++) {
                int tile_id = map->layer[i].data[x + (y * map->width)];
                int tileset_id;
                for(tileset_id=0; tileset_id<map->tileset_count; tileset_id++) {
                    tileset_t *tileset = map->tileset + tileset_id;
                    if((tile_id >= tileset->first_gid) && (tile_id < (tileset->first_gid + tileset->tile_count))) {
                        break;
                    }
                }
                if(tileset_id >= map->tileset_count) {
                    log_error("invalid tile id %d.", tile_id);
                    continue;
                }

                if(dict[tile_id] < 0) {
                    int index = first[tileset_id] + last[tileset_id]; 
                    id[index] = tile_id;
                    dict[tile_id] = index;
                    last[tileset_id]++;
                    tiles_used++;
                }
            }
        }
    }

    int start = 0;
    for(i=0; i<map->tileset_count; i++) {
       int j=0;
        for(j=first[i]; j<(first[i]+last[i]); j++) {
            int k = id[j];
            dict[k] += start - first[i];
        }
        start += last[i];
    }

    // recreate tileset
    start = 0;
    for(i=0; i<map->tileset_count; i++) {
        int j;
        tileset_t tileset;
        tileset_create(&tileset, map->tileset[i].name, start, last[i], map->tileset[i].tile_width, map->tileset[i].tile_height);
        start += last[i];
        
        int dst_stride = tileset.tile_width * tileset.tile_count;
        int src_stride = map->tileset[i].tile_width * map->tileset[i].tile_count;
        for(j=0; j<tileset.tile_count; j++) {
            int k = id[j+first[i]] - map->tileset[i].first_gid;
            uint8_t *dst_ptr = tileset.tiles + j * tileset.tile_width;
            uint8_t *src_ptr = map->tileset[i].tiles + k * map->tileset[i].tile_width;
            int x, y;
            for(y=0; y<tileset.tile_height; y++) {
                for(x=0; x<tileset.tile_width; x++) {
                    dst_ptr[x + (y*dst_stride)] = src_ptr[x + (y*src_stride)];
                }
            }
        }

        tileset.palette_count = 0;
        int *palette_dict = (int*)malloc(2 * map->tileset[i].palette_count * sizeof(int));
        int *palette_id = palette_dict + map->tileset[i].palette_count;
        for(j=0; j<map->tileset[i].palette_count; j++) {
            palette_dict[j] = -1;
        }
        for(j=0; j<tileset.tile_count; j++) {
            int k = id[j+first[i]] - map->tileset[i].first_gid;
            int l = map->tileset[i].palette_index[k];
            
            if(palette_dict[l] < 0) {
                palette_dict[l] = tileset.palette_count;
                palette_id[tileset.palette_count] = l;
                tileset.palette_count++;
            }

            tileset.palette_index[j] = palette_dict[l];
        }

        tileset.palette = (uint8_t*)malloc(tileset.palette_count*3*16);
        for(j=0; j<tileset.palette_count; j++) {
            int dst = j*3*16;
            int src = palette_id[j]*3*16;
            memcpy(tileset.palette+dst, map->tileset[i].palette+src, 3*16);
        }
        free(palette_dict);
 
        tileset_destroy(&map->tileset[i]);
       
        memcpy(&map->tileset[i], &tileset, sizeof(tileset_t));
    }

    // recreate tilemap
    for(i=0; i<map->layer_count; i++) {
        int y;
        for(y=0; y<map->height; y++) {
            int x;
            for(x=0; x<map->width; x++) {
                int tile_id = map->layer[i].data[x + (y * map->width)];
                map->layer[i].data[x + (y * map->width)] = dict[tile_id];
            }
        }
    }

    free(last);
    free(id);

    return 1;
}
