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
#include <getopt.h>
#include <unistd.h>
#include <libgen.h>

#include <jansson.h>

#include "image.h"
#include "pce.h"
#include "output.h"

// [todo] comments !!!!!
// [todo] vram offset
// [todo] output infos (size, wrap mode, tile size, incbin, palette)
// [todo] 16,32... tile size

typedef struct {
    int start;
    int count;
    char *name;
    char *filename;
} tileset_t;

typedef struct {
    char* name;
    uint16_t* data;
    int width;
    int height;
    int tile_width;
    int tile_height;
    int tileset_count;
    tileset_t* tilesets;
} tilemap_t;

static inline int is_pow2(int x) {
    return ((x != 0) && !(x & (x - 1)));
}

int create_tilemap(tilemap_t* tilemap, int width, int height) {
    tilemap->data = calloc(width*height, sizeof(uint16_t));
    if(!tilemap->data) {
        fprintf(stderr, "unable to allocate %dx%d map: %s\n", width, height, strerror(errno));
        return 0;
    }
    return 1;
}

void delete_tilemap(tilemap_t* tilemap) {
    int i;
    if(tilemap->name) {
        free(tilemap->name);
    }
    if(tilemap->data) {
        free(tilemap->data);
    }
    for(i=0; i<tilemap->tileset_count; i++) {
        if(tilemap->tilesets[i].name) {
            free(tilemap->tilesets[i].name);
        }
        if(tilemap->tilesets[i].filename) {
            free(tilemap->tilesets[i].filename);
        }
    }
    if(tilemap->tilesets) {
        free(tilemap->tilesets);
    }
    memset(tilemap, 0, sizeof(tilemap_t));
}

int read_integer(json_t* node, const char* name, int* value) {
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

int read_string(json_t* node, const char* name, char** value) {
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

int read_tilesets(json_t* node, tilemap_t* tilemap) {
    size_t index;
    json_t *value;
    json_t *array = json_object_get(node, "tilesets");
    if(!json_is_array(array)) {
        fprintf(stderr, "tilesets is not an array.\n");
        return 0;
    }
    
    tilemap->tileset_count = json_array_size(array);
    tilemap->tilesets = calloc(tilemap->tileset_count, sizeof(tileset_t));
    if(!tilemap->tilesets) {
        fprintf(stderr, "unable to allocate tilesets: %s\n",  strerror(errno));
        return 0;
    }
    
    json_array_foreach(array, index, value)
    {
        int t;
        if(!read_string(value, "name", &tilemap->tilesets[index].name)) {
            return 0;
        }
        if(!read_string(value, "image", &tilemap->tilesets[index].filename)) {
            return 0;
        }
        if(!read_integer(value, "firstgid", &tilemap->tilesets[index].start)) {
            return 0;
        }
        if(!read_integer(value, "tilecount", &tilemap->tilesets[index].count)) {
            return 0;
        }
        
        if(!read_integer(value, "tilewidth", &t)) {
            return 0;
        }
        if(tilemap->tile_width != t) {
            fprintf(stderr, "tileset tile width mismatch (%d %d).\n", t, tilemap->tile_width); 
            return 0;
        }
        
        if(!read_integer(value, "tileheight", &t)) {
            return 0;
        }
        if(tilemap->tile_height != t) {
            fprintf(stderr, "tileset tile height mismatch (%d %d).\n", t, tilemap->tile_height); 
            return 0;
        }
    }
    return 1;
}

int read_tilemap_data(json_t* node, tilemap_t* tilemap, uint32_t vram_offset) {
    int index;
    int width, height;
    json_t *layer;
    json_t *data;
    json_t *value;
    json_t *array = json_object_get(node, "layers");
    if(!json_is_array(array)) {
        fprintf(stderr, "layers is not an array.\n");
        return 0;
    }
    if(json_array_size(array) != 1) {
        fprintf(stderr, "layers must contain only 1 element.\n");
        return 0;
    }

    layer = json_array_get(array, 0);
    if(!layer) {
        fprintf(stderr, "failed to get layer #0.\n");
        return 0;
    }
    
    if(!read_string(layer, "name", &tilemap->name)) {
        fprintf(stderr, "failed to get layer name.\n");
        return 0;
    }
    
    if(!read_integer(layer, "width", &width)) {
        fprintf(stderr, "failed to get layer width.\n");
        return 0;
    }
    if(!read_integer(layer, "height", &height)) {
        fprintf(stderr, "failed to get layer height.\n");
        return 0;
    }

    if((tilemap->width != width) && (tilemap->height != height)) {
        fprintf(stderr, "data dimensions mismatch (expected: %dx%d, layer: %dx%d).\n", tilemap->width, tilemap->height, width, height);
        return 0;
    }

    data = json_object_get(layer, "data");
    if(!data) {
        fprintf(stderr, "failed to get layer data.\n");
        return 0;
    }
    
    uint16_t tile_offset = vram_offset >> 4;

    json_array_foreach(data, index, value)
    {
        int i, t;
        if(!json_is_integer(value)) {
            return 0;
        }
        i =0;
        t = json_integer_value(value);
        if(t) {
            for(i=0; i<tilemap->tileset_count; i++) {
                if((t >= tilemap->tilesets[i].start) && 
                   (t <  tilemap->tilesets[i].start + tilemap->tilesets[i].count)) {
                    break;
                }
            }
            if(i >= tilemap->tileset_count) {
                fprintf(stderr, "invalid tilemap data: %d.\n", t);
                return 0; 
            }
        }
        // [todo] i : tileset id, each tileset share the same palette.
        // [todo] data = BAT, BAT[y][x] = (palette_index << 12) | (vram_offset >> 4) 
        tilemap->data[index] = (i << 12) | ((t-1) + tile_offset);
    }
    return 1;
}

int read_tilemap(tilemap_t* tilemap, const char* filename, uint32_t vram_offset) {
    int ret;
    json_t *root;
    json_error_t error;
    
    memset(tilemap, 0, sizeof(tilemap_t));
    
    root = json_load_file(filename, 0, &error);
    if(!root) {
        fprintf(stderr, "%s:%d:%d %s\n", filename, error.line, error.column, error.text);
        return 0;
    }
    
    ret =        read_integer(root, "width",      &tilemap->width);
    ret = ret && read_integer(root, "height",     &tilemap->height);
    ret = ret && read_integer(root, "tilewidth",  &tilemap->tile_width);
    if(ret && (tilemap->tile_width & 0x07)) {
        fprintf(stderr, "tile width (%d) must be a multiple of 8.\n", tilemap->tile_width); 
        ret = 0;
    }
    ret = ret && read_integer(root, "tileheight", &tilemap->tile_height);
    if(ret && (tilemap->tile_width & 0x07)) {
        fprintf(stderr, "tile height (%d) must be a multiple of 8.\n", tilemap->tile_height); 
        ret = 0;
    }
    ret = ret && create_tilemap(tilemap, tilemap->width, tilemap->height);    
    ret = ret && read_tilesets(root, tilemap);
    ret = ret && read_tilemap_data(root, tilemap, vram_offset);
    json_decref(root);
    
    if(!ret) { delete_tilemap(tilemap); }
    return ret;
}

int output_tilemap(tilemap_t* tilemap) {
    int ret = 1;
    char filename[256];
    FILE *out;
    size_t n;
    size_t total = tilemap->width * tilemap->height;
    
    snprintf(filename, 256, "%s.bin", tilemap->name);
    
    out = fopen(filename, "wb");
    if(out == NULL) {
        fprintf(stderr, "failed to open %s: %s\n", filename, strerror(errno));
        return 0;
    }

    n = fwrite(tilemap->data, sizeof(uint16_t), total, out);
    if(n != total) {
        fprintf(stderr, "failed to write map to %s: %s\n", filename, strerror(errno));
        ret = 0;
    } 
    fclose(out);
    return ret;
}

int output_tilesets(tilemap_t* tilemap) {
    int i;
    int ret = 1;
    size_t  size = 0;
    uint8_t *buffer = NULL;
    
    for(i=0; ret && (i<tilemap->tileset_count); i++) {
        image_t img = {};
        if(!tilemap->tilesets[i].filename) {
            fprintf(stderr, "missing filename for layer #%d\n", i);
            return 0;
        }
        ret = image_load_png(&img, tilemap->tilesets[i].filename);
        if(!ret) {
            fprintf(stderr, "failed to load %s\n", tilemap->tilesets[i].filename);
        }
        else if((img.bytes_per_pixel != 1) || (img.color_count > 16)) {
            fprintf(stderr, "%s: invalid image color depth (expected 16 colors indexed image)\n", tilemap->tilesets[i].filename);
            ret = 0;
        }
        else {
            char filename[256];
            snprintf(filename, 256, "%s_%04d.tiles", tilemap->tilesets[i].name, i);
            
            buffer = realloc(buffer, img.width * img.height * 4);
            ret = pce_image_to_tiles(&img, tilemap->tile_width, tilemap->tile_height, buffer, &size);
            if(ret) {
                FILE *out = fopen(filename, "wb");
                if(!out) {
                    fprintf(stderr, "failed to open %s: %s\n", filename, strerror(errno));
                    ret = 0;
                }
                else {
                    ret = output_raw(out, buffer, size);
                    if(!ret) {
                        fprintf(stderr, "failed to write %s\n", filename);
                    }
                    fclose(out);
                }
            }
            if(ret) {
                uint8_t rgb_333[32];
                snprintf(filename, 256, "%s_%04d.pal", tilemap->tilesets[i].name, i);
                FILE *out = fopen(filename, "wb");
                if(!out) {
                    fprintf(stderr, "failed to open %s: %s\n", filename, strerror(errno));
                    ret = 0;
                }
                else {
                    pce_color_convert(img.palette, rgb_333, img.color_count);
                    ret = output_raw(out, rgb_333, 32);
                    if(!ret) {
                        fprintf(stderr, "failed to write %s\n", filename);
                    }
                    fclose(out);
                }
            }
        }
        image_destroy(&img);
    }
    free(buffer);
    return ret;
}

void usage() {
    fprintf(stderr, "Usage: tiled2map [options] file.json\n"
                    "Convert filed json file to PC Engine compatible map.\n"
                    "  -v, --tile_vram hex\tStart offset in VRAM where to store tilesets\n");
}

int main(int argc, char* const argv[]) {
    const struct option long_options[] = {
        {"tile_vram", required_argument, 0, 'v'},
        {0, 0, 0, 0}
    };
    const char options[] = "v:";
    
    int ret;
    char *path[2];
    char *directory;
    char *filename;
    
    tilemap_t tilemap;

    uint32_t vram_offset = 0xffffffff;
    
    for(;;) {
        int c;
        int option_index = 0;
        char *endptr;
        
        c = getopt_long(argc, argv, options, long_options, &option_index);
        if(c == -1) {
            break;
        }
        
        switch(c) {
            case 'v':
                errno = 0;
                vram_offset = (uint32_t)strtoul(optarg, &endptr, 16);
                if(errno || (vram_offset > 0xffff) || (*endptr != '\0')) {
                    fprintf(stderr, "invalid argument for vram offset.\n");
                    usage();
                    return EXIT_FAILURE;
                }
                break;
            default:
                usage();
                return EXIT_FAILURE;
        }
    }

    if(vram_offset == 0xffffffff) {
        fprintf(stderr, "missing vram offset.\n");
        usage();
        return EXIT_FAILURE;
    }
    
    if(optind == argc) {
        usage();
        return EXIT_FAILURE;
    }
    
    // Extract path and filename from input json file.
    path[0] = strdup(argv[optind]);
    path[1] = strdup(argv[optind]);

    directory = dirname (path[0]);
    filename  = basename(path[1]);

    // The path of the json file is now the current working directory. 
    chdir(directory);

    free(path[0]);
    
    ret =        read_tilemap(&tilemap, filename, vram_offset);
    ret = ret && output_tilemap(&tilemap);
    ret = ret && output_tilesets(&tilemap);
    // [todo] description
    
    delete_tilemap(&tilemap);
    free(path[1]);
    return ret ? EXIT_SUCCESS : EXIT_FAILURE;
}
