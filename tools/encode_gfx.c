/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2020 MooZ
 */
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>

#include <argparse/argparse.h>
#include <jansson.h>
#include <cwalk.h>

#include "utils/log.h"
#include "utils/image.h"
#include "utils/pce.h"
#include "utils/buffer.h"
#include "utils/output.h"

#ifndef PATH_MAX
#define PATH_MAX 256
#endif

// [todo] comments
// [todo] sprites: cut and encode in multiple objects if the size is not 16x16, 16x32, 32x16, 32x32 or 32x64
// [todo] asm output

// Graphical object.
typedef struct {
    char *name;                 // Graphical object filename.
    int x, y;                   // Position in pixels.
    int w, h;                   // Size in either 16 pixels units (for sprites) or 8 pixels units (for tiles).
    int append;                 // Append to file?
} object_t;

// Palette
typedef struct {
    char *name;                 // Palette output filename.
    int start;                  // Subpalette index.
    int count;                  // ?imber of palettes to extract.
    int append;                 // Append to file?
} palette_t;

// List of supported object types.
enum ObjectType {
    Tiles = 0,
    Sprites,
    TilePalettes,
    SpritePalettes,
    ObjectTypeCount
};

// Object name (as defined in the configuration file).
static const char* g_objectTypeName[ObjectTypeCount] = {
    "tile",
    "sprite",
    "tilepal",
    "spritepal"
};

// Extracted objects and palettes (as defined in the configuration file).
typedef struct {
    object_t *objects[ObjectTypeCount];
    int object_count[ObjectTypeCount];
    palette_t *palettes;
    int palette_count;
} asset_t;

static void asset_reset(asset_t *out) {
    for(int i=0; i<ObjectTypeCount; i++) {
        out->objects[i] = NULL;
        out->object_count[i] = 0;
    }
    out->palettes = NULL;
    out->palette_count = 0;
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
    if(out->palettes) {
        for(int i=0; i<out->palette_count; i++) {
            free(out->palettes[i].name);
        }
        free(out->palettes);
        out->palettes = NULL;
    }
    out->palette_count = 0;
}

//--------------------------------------------------------------------------------------
// JSON parsing
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

static int json_read_boolean(json_t* node, const char* name, int* value) {
    json_t *object = json_object_get(node, name);
    if(!object) {
        return 0;
    }
    if(!json_is_boolean(object)) {
        return 0;
    }
    *value = json_boolean_value(object);
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
    if(!json_read_boolean(object, "append", &out->append)) {
        // append = false by default.
        out->append = 0;
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

int read_palette(json_t *object, palette_t *out) {
    const char *name;
    if(!json_read_string(object, "name", &name)) {
        log_error("failed to get palette name");
        return 0;
    }
    out->name = strdup(name);
    if(!json_read_integer(object, "start", &out->start)) {
        log_error("failed to get sub-palette index");
        return 0;
    }
    if(!json_read_integer(object, "count", &out->count)) {
        log_error("failed to get sub-palette count");
        return 0;
    }
    if(!json_read_boolean(object, "append", &out->append)) {
        // append = false by default.
        out->append = 0;
    }
    return 1;
}

static int read_palette_list(json_t *root, const char *name, palette_t **palettes, int *count) {
    json_t *node;
    json_t *value;
    size_t index;

    *palettes = NULL;
    *count = 0;

    node = json_object_get(root, name);
    if(!node) {
        return 1;
    }

    *count = json_array_size(node);
    if(!*count) {
        return 1;
    }

    *palettes = (palette_t*)malloc(*count * sizeof(palette_t));
    if(*palettes == NULL) {
        log_error("failed to allocate palettes: %s", strerror(errno));
        *count = 0;
        return 0;
    }

    json_array_foreach(node, index, value) {
        if(!json_is_object(value)) {
            log_error("invalid palette at index %d", index);
            return 0;
        }
        if(!read_palette(value, *palettes + index)) {
            log_error("failed to read palette at index %d", index);
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
    if(ret) {
        ret = read_palette_list(root, "palette", &out->palettes, &out->palette_count);
    }
    if(!ret) {
        asset_destroy(out);
    }
    json_decref(root);
    return ret;
}

//--------------------------------------------------------------------------------------
// Encoding
static struct {
    int bloc_size;
    int stride;
    int (*encode)(uint8_t*, uint8_t*, int);
} g_encoder[] = {
    { 8, 32, pce_bitmap_to_tile },
    { 16, 128, pce_bitmap_to_sprite },
    { 8, 32, pce_bitmap_to_tile_palette },
    { 16, 128, pce_bitmap_to_sprite_palette }
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

static int extract_palette(const image_t *source, palette_t *palette, buffer_t *destination) {
    if(!buffer_resize(destination, 16*palette->count*2)) {
        log_error("failed to resize work buffer");
        return 0;
    }
    int start = 16*palette->start;
    memset(destination->data, 0, 16*palette->count*2);
    if(start >= source->color_count) {
        log_error("image palette only contains %d colors (%d)", source->color_count);
        return 0;
    }
    int end = start + 16*palette->count;
    int last = (end <= source->color_count) ? end : source->color_count;
    if(end > source->color_count) {
        log_warn("image palette only contains %d colors", source->color_count);
    }
    pce_color_convert(&source->palette[start*3], destination->data, last-start);
    return 1;
}

// [todo] output functions (binary + asm declaration)
static int output(const char *prefix_path, const char *filename, const buffer_t *buffer, int append) {
    char *path = (char*)calloc(PATH_MAX, 1);
    size_t path_len = PATH_MAX;
    size_t ret;

    ret = cwk_path_join(prefix_path, filename, path, path_len);
    if(ret >= path_len) {
        path_len = ret+1;
        path = (char*)realloc(path, ret+1);
        cwk_path_join(prefix_path, filename, path, path_len);
    }

    ret = 0;
    FILE *out = fopen(path, append ? "ab" : "wb");
    if(out) {
        ret = output_raw(out, buffer->data, buffer->size);
        fclose(out);
    }
    else {
        log_error("failed to open %s: %s", path, strerror(errno));
    } 
    free(path);
    return ret;
}

int main(int argc, const char** argv) {
    static const char *const usages[] = {
        "encode_gfx",
        NULL
    };

    const char *output_directory = ".";
    struct argparse_option options[] = {
        OPT_HELP(),
        OPT_STRING('o', "output-directory", &output_directory, "output directory", NULL, 0, 0),
        OPT_END(),
    };

    struct argparse argparse;

    argparse_init(&argparse, options, usages, 0);
    argparse_describe(&argparse, "\nencode_gfx -o/--output-directory <out> <configuration.json> <image>", " ");
    argc = argparse_parse(&argparse, argc, argv);
    if(!argc) {
        argparse_usage(&argparse);
        return EXIT_FAILURE;
    }

    struct stat sb;
    if (stat(output_directory, &sb) || ((sb.st_mode & S_IFMT) != S_IFDIR)) {
        log_error("Invalid output directory");
        return EXIT_FAILURE;
    }

    int ret = EXIT_FAILURE;

    asset_t assets = {0};
    if(parse_configuration(argv[0], &assets)) { 
        image_t img = {0};
        if(image_load_png(&img, argv[1])) {
            buffer_t buf;
            buffer_init(&buf);

            int ok = 1;
            for(int j=0; ok && (j<ObjectTypeCount); j++) {
                for(int i=0; ok && (i<assets.object_count[j]); i++) {
                    if(extract(&img, &assets.objects[j][i], j, &buf)) {
                        ok = output(output_directory, assets.objects[j][i].name, &buf, assets.objects[j][i].append);
                    }
                }
            }

            for(int i=0; ok && (i<assets.palette_count); i++) {
                if(extract_palette(&img, &assets.palettes[i], &buf)) {
                    ok = output(output_directory, assets.palettes[i].name, &buf, assets.palettes[i].append);
                }
            }
            buffer_delete(&buf);
            ret = ok ? EXIT_SUCCESS : EXIT_FAILURE;
        }
        image_destroy(&img);
    }    
    asset_destroy(&assets);

    return ret;
}
