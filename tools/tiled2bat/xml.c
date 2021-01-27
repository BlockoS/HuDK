/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2020 MooZ
 */
#include "xml.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

#include <mxml.h>
#include <cwalk.h>

#include "../utils/base64.h"
#include "../utils/log.h"
#include "../utils/utils.h"

static int xml_read_attr_int(mxml_node_t *node, const char *attr, int *i) {
    const char *name = mxmlGetElement(node);
    const char *value;
    value = mxmlElementGetAttr(node, attr);
    if(value == NULL) {
        log_error("failed to get %s %s", name, attr);
        return 0;
    }
    *i = (int)strtoul(value, NULL, 10);
    if(errno) {
        log_error("invalid %s %s value", name, attr);
        return 0;
    }
    return 1;
}

static int xml_read_tilesets(tilemap_t *map, char *path, mxml_node_t* node) {
    size_t i;
    mxml_node_t *tileset_node, *image_node;
    for(i = 0, tileset_node = mxmlFindElement(node, node, "tileset", NULL, NULL, MXML_DESCEND);
        tileset_node;
        i++, tileset_node = mxmlFindElement(tileset_node, node, "tileset", NULL, NULL, MXML_NO_DESCEND)) {
        int first_gid, tile_count, tile_width, tile_height, columns, margin, spacing;
        const char *source, *name;
        if(!xml_read_attr_int(tileset_node, "firstgid", &first_gid)) {
            return 0;
        }
        if(!xml_read_attr_int(tileset_node, "tilecount", &tile_count)) {
            return 0;
        }
        if(!xml_read_attr_int(tileset_node, "tilewidth", &tile_width)) {
            return 0;
        }
        if(!xml_read_attr_int(tileset_node, "tileheight", &tile_height)) {
            return 0;
        }
        if(!xml_read_attr_int(tileset_node, "columns", &columns)) {
            return 0;
        }
        name = mxmlElementGetAttr(tileset_node, "name");
        if(name == NULL) {
            log_error("failed to get tileset name");
            return 0;
        }
        if(!xml_read_attr_int(tileset_node, "margin", &margin)) {
            margin = 0;
            log_warn("using default margin value %d instead", margin);
        }
        if(!xml_read_attr_int(tileset_node, "spacing", &spacing)) {
            spacing = 0;
            log_warn("using default spacing value %d instead", spacing);
        }

        image_node = mxmlFindElement(tileset_node, tileset_node, "image", NULL, NULL, MXML_DESCEND);
        if(image_node == NULL) {
            log_error("failed to get image node");
            return 0;
        }
        source = mxmlElementGetAttr(image_node, "source");
        if(source == NULL) {
            log_error("failed to get image source");
            return 0;
        }
        char *filepath = path_join(path, source);
        if(filepath == NULL) {
            return 0;
        }
        
        int ret = tileset_load(&map->tileset[i], name, filepath, first_gid, tile_count, tile_width, tile_height, margin, spacing, columns);
        free(filepath);
        if(!ret) {
            return 0;
        }
    }
    return 1;
}

static int xml_read_tilemap_data(mxml_node_t *node, char *path, const char *name, tilemap_t *map) {
    int width;
    int height;
    int tile_width;
    int tile_height;
    int tileset_count;
    int i; 

    const char *str;
    const char *data;

    mxml_node_t *tileset_node, *layer_node;

    if(!xml_read_attr_int(node, "width", &width)) {
        return 0;
    }
    if(!xml_read_attr_int(node, "height", &height)) {
        return 0;
    }
    if(!xml_read_attr_int(node, "tilewidth", &tile_width)) {
        return 0;
    }
    if(!xml_read_attr_int(node, "tileheight", &tile_height)) {
        return 0;
    }

    for(tileset_count = 0, tileset_node = mxmlFindElement(node, node, "tileset", NULL, NULL, MXML_DESCEND);
        tileset_node;
        tileset_node = mxmlFindElement(tileset_node, node, "tileset", NULL, NULL, MXML_NO_DESCEND)) {
        tileset_count++;
    }
    if(tileset_count == 0) {
        log_error("failed to get tilesets");
        return 0;
    }

    if(!tilemap_create(map, name, width, height, tile_width, tile_height, tileset_count)) {
        log_error("failed to create tileset %s", name);
        return 0;
    }

    if(!xml_read_tilesets(map, path, node)) {
        return 0;
    }

    for(i = 0, layer_node = mxmlFindElement(node, node, "layer", NULL, NULL, MXML_DESCEND);
        layer_node;
        i++, layer_node = mxmlFindElement(layer_node, node, "layer", NULL, NULL, MXML_NO_DESCEND)) {
        str = mxmlElementGetAttr(layer_node, "name");
        if(str == NULL) {
            log_error("failed to get layer name");
            return 0;
        }

        if(!tilemap_add_layer(map, str)) {
            return 0;
        }

        mxml_node_t *data_node = mxmlFindElement(layer_node, layer_node, "data", NULL, NULL, MXML_DESCEND);
        if(data_node == NULL) {
            log_error("failed to get tilemap data node");
            return 0;
        }
        str = mxmlElementGetAttr(data_node, "encoding");
        if(str == NULL) {
            log_error("failed to get tilemap data encoding");
            return 0;
        }

        data = mxmlGetOpaque(data_node);
        if(data == NULL) {
            log_error("failed to get tilemap data");
            return 0;
        }

        if(!strcmp(str, "csv")) {
            const char *end = data + strlen(data) + 1;
            size_t last = (width*height) - 1;
            for(size_t j=0; (j<=last) && (data < end); j++) {
                for(;isspace(*data) && (data < end); data++) {
                }
                errno = 0;
                char *next;
                unsigned long int value = strtoul(data, &next, 10);
                if(errno) {
                    log_error("invalid tile value");
                    return 0;
                }
                map->layer[i].data[j] = value;
                if((*next != ',') && ((j == last) && !isspace(*next))) {
                    log_error("invalid separator (ascii: 0x%02x)", *next);
                    return 0;
                }
                data = next+1;
            }
        }
        else if(!strcmp(str, "base64")) {
            if(!base64_decode(data, (uint8_t*)map->layer[0].data, 4 * map->width * map->height)) {
                return 0;
            }
        }
        else {
            log_error("unsupported tilemap data encoding \"%s\"", str);
            return 0;
        }
    }
    return 1;
}

int xml_read_tilemap(tilemap_t *map, const char *filename) {
    int ret = 0;
    FILE *in;
    mxml_node_t *tree;
    char *path, *name;
    size_t len;

    in = fopen(filename, "rb");
    if(in == NULL) {
        log_error("failed to open %s: %s", filename, strerror(errno));
        return 0;
    }
    tree = mxmlLoadFile(NULL, in, MXML_OPAQUE_CALLBACK);
    fclose(in);

    if(tree == NULL) {
        log_error("failed to decode %s", filename);
        return 0;
    }

    len = strlen(filename);
    path = strdup(filename);
    cwk_path_get_dirname(path, &len);
    path[len] = '\0';

    name = basename_no_ext(filename);

    mxml_node_t *map_node = mxmlFindElement(tree, tree, "map", NULL, NULL, MXML_DESCEND);
    if(map_node) {
        if(xml_read_tilemap_data(map_node, path, name, map)) {
            ret = 1;
        }
        else {
            tilemap_destroy(map);
        }
    }
    else {
        log_error("failed to retrieve \"map\" node %s", filename);
    }

    free(name);
    free(path);
    mxmlDelete(tree);
    return ret;
}