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
#include "utils/pce.h"
#include "utils/buffer.h"

typedef struct {
    char *name;
    int x, y;
    int w, h;
} object_t;

enum ObjectType {
    Tiles = 0,
    Sprites,
    ObjectTypeCount
};

static const char* g_objectTypeName[ObjectTypeCount] = {
    "tiles",
    "sprites"
};

typedef struct {
    object_t *objects[ObjectTypeCount];
    int object_count[ObjectTypeCount];

    // [todo] palettes
} asset_t;

static void asset_reset(asset_t *out) {
    for(int i=0; i<ObjectTypeCount; i++) {
        out->objects[i] = NULL;
        out->object_count[i] = 0;
    }
}

static void asset_destroy(asset_t *out) {
    for(int j=0; j<ObjectTypeCount; j++) {
        if(!out->objects[j]) {
            for(int i=0; i<out->object_count[j]; i++) {
                free(out->objects[j][i].name);
            }
            free(out->objects[j]);
            out->objects[j] = NULL;
            out->object_count[j] = 0;
        }
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
    for(int j=0; j<ObjectTypeCount; j++) {
        if(!read_object_list(root, g_objectTypeName[j], &out->objects[j], &out->object_count[j])) {
            ret = 0;
        }
    }
    if(!ret) {
        asset_destroy(out);
    }
    json_decref(root);
    return ret;
}

static struct {
    int bloc_size;
    int stride;
    int (*encode)(uint8_t*, uint8_t*, int);
} g_encoder[] = {
    { 8, 32, pce_bitmap_to_tile },
    { 16, 128, pce_bitmap_to_sprite }
};

static int extract(const image_t *source, const object_t *object, int type, buffer_t *destination) {
    int x, y, w, h;
    int bloc_size;
    
    bloc_size = g_encoder[type].bloc_size;
    
    x = object->x;
    y = object->y;
    w = object->w;
    h = object->h;

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
    if((x+(w*bloc_size)) > source->width) {
        log_warn("%s width (%d) out of image bound (%d)", object->name, w*bloc_size, source->width);
    }
    if(w <= 0) {
        log_error("%s width (%d) is too small", object->name, w);
        return 0;
    }
    if((y+(h*bloc_size)) > source->height) {
        log_warn("%s height (%d) out of image bound (%d)", object->name, h*bloc_size, source->height);
    }
    if(h <= 0) {
        log_error("%s height (%d) is too small", object->name, h);
        return 0;
    }

    if(!buffer_resize(destination, w*h*g_encoder[type].stride)) {
        log_error("failed to resize work buffer");
        return 0;
    }

    uint8_t *out = destination->data;
    for(int j=0; j<h; j++) {
        int sy = y + (j*bloc_size);
        for(int i=0; i<w; i++, out+=g_encoder[type].stride) {
            int sx = x + (i*bloc_size);
            uint8_t *in = &source->data[sx + (sy*source->width)];
            if(!g_encoder[type].encode(in, out, source->width)) {
                log_error("failed to encode block (%d,%d) of %s", i, j, object->name);
                return 0;
            }
        }
    }

    return 1;
}

// [todo] output functions (binary + asm declaration)

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
            buffer_t buf;
            buffer_init(&buf);

            for(int j=0; j<ObjectTypeCount; j++) {
                for(int i=0; i<assets.object_count[j]; i++) {
                    if(extract(&img, &assets.objects[j][i], j, &buf)) {
                        FILE *out = fopen(assets.objects[j][i].name, "wb");
                        fwrite(buf.data, 1, buf.size, out);
                        fclose(out);
                    }
                }
            }
            buffer_delete(&buf);
            ret = EXIT_SUCCESS;
        }
        image_destroy(&img);
    }    
    asset_destroy(&assets);

    return ret;
}
