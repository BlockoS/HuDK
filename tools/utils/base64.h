/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2019 MooZ
 */
#ifndef HUDK_TOOLS_BASE64_H
#define HUDK_TOOLS_BASE64_H

#include <stdlib.h>
#include <stdint.h>

int base64_decode(const char *in, uint8_t *out, size_t len);

#endif // HUDK_TOOLS_BASE64_H
