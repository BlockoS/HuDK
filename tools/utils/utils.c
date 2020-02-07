/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2020 MooZ
 */
#include "utils.h"

#include <stdlib.h>
#include <string.h>

#include <cwalk.h>

#include "log.h"

char* path_join(const char* path, const char* filename) {
    size_t capacity = strlen(path) + strlen(filename) + 2;
    char *out = (char*)malloc(capacity);
    if(out == NULL) {
        log_error("failed to allocate string buffer");
        return NULL;
    }
    size_t len = cwk_path_join(path, filename, out, capacity);
    if(len >= capacity) {
        char *tmp = (char*)realloc(out, len+1);
        if(tmp == NULL) {
            free(out);
            log_error("failed to allocate string buffer");
            return NULL;
        }
        out = tmp;
        if(cwk_path_join(path, filename, out, len+1) != len) {
            log_error("failed to build tileset file path");
            free(out);
            return NULL;
        }
    }
    return out;
}

char* basename_no_ext(const char *path) {
    char *out;
    const char *basename, *extension;
    size_t basename_len, extension_len, len;
    
    cwk_path_get_basename(path, &basename, &basename_len);
    if(!cwk_path_get_extension(path, &extension, &extension_len)) {
        extension = basename + basename_len;
    }
        
    len = extension - basename;
    out = (char*)malloc(len + 1);
    strncpy(out, basename, len);
    out[len] = '\0';
    
    return out;
}