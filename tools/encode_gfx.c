/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2019 MooZ
 */
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include <argparse/argparse.h>
#include <jansson.h>
#include <cwalk.h>

#include "utils/log.h"
#include "utils/image.h"

typedef struct {
    char *name;
    int x, y;
    int w, h;
} object_t;

typedef struct {
    object_t *sprites;
    int sprite_count;
    object_t *tiles;
    int tile_count;
} asset_t;

static void asset_reset(asset_t *out) {
    out->sprites = out->tiles = NULL;
    out->sprite_count = out->tile_count = 0;
}

static void asset_destroy(asset_t *out) {
    int i;
    if(!out->sprites) {
        for(i=0; i<out->sprite_count; i++) {
            free(out->sprites[i].name);
        }
        free(out->sprites);
        out->sprites = NULL;
        out->sprite_count = 0;
    }
    if(!out->tiles) {
        for(i=0; i<out->tile_count; i++) {
            free(out->tiles[i].name);
        }
        free(out->tiles);
        out->tiles = NULL;
        out->tile_count = 0;
    }
}

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

int read_object(json_t *object, object_t *out) {
    const char *name;
    if(!json_read_string(object, "name", &name)) {
        log_error("failed to get object name");
        return 0;
    }
    out->name = strdup(name);
    if(!json_read_integer(object, "x", &out->x)) {
        log_error("failed to get object x coordinate");
        return 0;
    }
    if(!json_read_integer(object, "y", &out->y)) {
        log_error("failed to get object y coordinate");
        return 0;
    }
    if(!json_read_integer(object, "w", &out->w)) {
        log_error("failed to get object width");
        return 0;
    }
    if(!json_read_integer(object, "h", &out->h)) {
        log_error("failed to get object height");
        return 0;
    }
    return 1;
}

static int read_object_list(json_t *root, const char *name, object_t **objects, int *count) {
    json_t *node;
    json_t *value;
    size_t index;

    *objects = NULL;
    *count = 0;

    node = json_object_get(root, name);
    if(!node) {
        return 1;
    }

    *count = json_array_size(node);
    if(!*count) {
        return 1;
    }

    *objects = (object_t*)malloc(*count * sizeof(object_t));
    if(*objects == NULL) {
        log_error("failed to allocate objects: %s", strerror(errno));
        *count = 0;
        return 0;
    }

    json_array_foreach(node, index, value) {
        if(!json_is_object(value)) {
            log_error("invalid object at index %d", index);
            return 0;
        }
        if(!read_object(value, *objects + index)) {
            log_error("failed to read object at index %d", index);
            return 0;
        }
    }

    return 1;
}

static int parse_configuration(const char *filename, asset_t *out) {
    json_error_t error;
    json_t *root;
    int ret = 1;

    asset_reset(out);
    root = json_load_file(filename, 0, &error);
    if(!root) {
        log_error("%s:%d:%d %s", filename, error.line, error.column, error.text);
        return 0;
    }
    if(!read_object_list(root, "sprites", &(out->sprites), &(out->sprite_count))) {
        ret = 0;
    }
    if(!read_object_list(root, "tiles", &(out->tiles), &(out->tile_count))) {
        ret = 0;
    }
    if(!ret) {
        asset_destroy(out);
    }
    json_decref(root);
    return ret;
}

static int find_closest_8(int in) {
    return (in + 7) & ~7;
}

static int validate_tiles_size(int w_in, int h_in, int *w_out, int *h_out) {
    *w_out = find_closest_8(w_in);
    *h_out = find_closest_8(h_in);
    if((w_in != *w_out) || (h_in != *h_out)) {
        log_warn("Tile area dimensions were adjusted from (%d,%d) to (%d,%d).", w_in, h_in, *w_out, *h_out);
    }
    return 1;
}

static int validate_sprite_size(int w_in, int h_in, int *w_out, int *h_out) {
    if(w_in <= 16) {
        *w_out = 16;
    }
    else if(w_in <= 32) {
        *w_out = 32;
    }
    else {
        log_error("Invalid input width (%d, max: 32)!", w_in);
        return 0;
    }
    if(h_in <= 16) {
        *h_out = 16;
    }
    else if(h_in <= 32) {
        *h_out = 32;
    }
    else if(h_in <= 64) {
        *h_out = 64;
    }
    else {
        log_error("Invalid input height (%d, max: 64)", h_in);
        return 0;
    }
    if((w_in != *w_out) || (h_in != *h_out)) {
        log_warn("Sprite dimensions were adjusted from (%d,%d) to (%d,%d).", w_in, h_in, *w_out, *h_out);
    }
    return 1;
}

struct {
    int (*validate_size)(int w_in, int h_in, int *w_out, int *h_out);
    int (*todo)();
} encoders[2] = {
    { validate_tiles_size, NULL },
    { validate_sprite_size, NULL },
};

static int extract(const image_t *source, const object_t *object, int type) {
    int x, y, w, h;
    x = object->x;
    y = object->y;
    
    if(!encoders[type].validate_size(object->w, object->h, &w, &h)) {
    }
    
    if(x >= source->width) {
        log_error("%s x (%d) coordinate out of image bound (%d)", object->name, x, source->width);
        return 0;
    }
    if(x < 0) {
        log_error("%s x (%d) coordinate clamped to 0", object->name, x);
        x = 0; 
    }
    if(y >= source->height) {
        log_error("%s y (%d) coordinate out of image bound (%d)", object->name, y, source->height);
        return 0;
    }
    if(y < 0) {
        log_error("%s y (%d) coordinate clamped to 0", object->name, y);
        y = 0;
    }
    if((x+w) > source->width) {
        log_warn("%s width (%d) clamped to %d", object->name, w, source->width - x);
        w = source->width - x;
    }
    if(w <= 0) {
        log_error("%s width (%d) is too small", object->name, w);
        return 0;
    }
    if((y+h) > source->height) {
        log_warn("%s height (%d) clamped to %d", object->name, h, source->height - y);
        h = source->height - y;
    }
    if(h <= 0) {
        log_error("%s height (%d) is too small", object->name, h);
        return 0;
    }

    // [todo] encode

    return 1;
}

int main(int argc, const char** argv) {
    static const char *const usages[] = {
        "encode_gfx",
        NULL
    };

    struct argparse_option options[] = {
        OPT_HELP(),
        // [todo] assembly file output
        OPT_END(),
    };

    struct argparse argparse;

    argparse_init(&argparse, options, usages, 0);
    argparse_describe(&argparse, "\nencode_gfx : <configuration> <image> <out>", "  ");
    argc = argparse_parse(&argparse, argc, argv);
    if(!argc) {
        argparse_usage(&argparse);
        return EXIT_FAILURE;
    }

    // [todo] check argument count

    int ret = EXIT_FAILURE;

    asset_t assets = {0};
    if(parse_configuration(argv[0], &assets)) { 
        image_t img = {0};
        if(image_load_png(&img, argv[1])) {
            for(int i=0; i<assets.tile_count; i++) {
                if(!extract(&img, &assets.tiles[i], 0)) {
                    // [todo]
                }
                // [todo] write tiles + info in asm file
            }
            for(int i=0; i<assets.sprite_count; i++) {
                if(!extract(&img, &assets.sprites[i], 1)) {
                    // [todo]
                }
                // [todo] write sprites + info in asm file
            }
            ret = EXIT_SUCCESS;
        }
        image_destroy(&img);
    }    
    asset_destroy(&assets);

    return ret;
}
