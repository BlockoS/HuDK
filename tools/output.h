/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2019 MooZ
 */
#ifndef HUDK_TOOLS_OUTPUT_H
#define HUDK_TOOLS_OUTPUT_H

#include <stdio.h>
#include <stdint.h>

int output_table(FILE *output, const char* name, const int8_t* table, int count);

int output_raw(FILE *output, uint8_t* buffer, size_t sz);

#endif /* HUDK_TOOLS_OUTPUT_H */
