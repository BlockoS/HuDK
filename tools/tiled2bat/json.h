/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2021 MooZ
 */
#ifndef HUDK_TOOLS_TILEMAP_JSON_H
#define HUDK_TOOLS_TILEMAP_JSON_H

#include "tilemap.h"

int json_read_tilemap(tilemap_t *map, const char *filename);

int json_write_tilemap(tilemap_t *map);

#endif /* HUDK_TOOLS_TILEMAP_JSON_H */