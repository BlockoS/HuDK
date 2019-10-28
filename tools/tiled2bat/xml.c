/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2019 MooZ
 */
#include "xml.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

#include <mxml.h>

#include "log.h"

int xml_read_tilemap(tilemap_t *map, const char *filename) {
    FILE *in;
    mxml_node_t *tree;

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

    // [todo]

    return 1;
}