/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2019 MooZ
 */
#include "output.h"

#include "log.h"

#include <errno.h>
#include <string.h>

int output_table(FILE *output, const char* name, const int8_t* table, int count) {
    int i;
    fprintf(output, "%s:\n", name);
    for(i=0; i<count; i++) {
        if((i%16) == 0) {
            fprintf(output, "    .db ");
        }
        fprintf(output, "$%02x%c", (uint8_t)table[i], (((i%16) == 15) || (i >= (count-1))) ? '\n':',');
    }
    return 1;
}

int output_raw(FILE *output, uint8_t* buffer, size_t sz) {
    size_t nwritten;    
    nwritten = fwrite(buffer, 1, sz, output);
    if(sz != nwritten) {
        log_error("failed to write %zu bytes: %s", sz, strerror(errno));
        return 0;
    }
    return 1;
}
