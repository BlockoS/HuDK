/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2020 MooZ
 */
#include "base64.h"

#include "log.h"

#include <errno.h>
#include <string.h>
#include <ctype.h>

int base64_decode(const char *in, uint8_t *out, size_t len) {
    size_t in_len = strlen(in);
    size_t decoded = 0;
    uint8_t *ptr;
    uint32_t buffer;
    size_t j;
    ptr = out;
    j = 0;
    for(size_t i=0; i<in_len; i++) {
        uint32_t c = in[i];
        if((c >= 'A') && (c <= 'Z')) {
            c = c - 'A';
        }
        else if((c >= 'a') && (c <= 'z')) {
            c = c - 'a' + 26;
        }
        else if((c >= '0') && (c <= '9')) {
            c = c - '0' + 52;
        }
        else if(c == '+') {
            c = 62;
        }
        else if(c == '/') {
            c = 63;
        }
        else if(c == '=') {
            break;
        }
        else if(isspace(c)) {
            continue;
        }
        else {
            log_error("invalid character 0x%02x", c);
            return 0;
        }

        buffer = (buffer << 6) | c;
        j++;
        if(j == 4) {
            if((decoded+3) > len) {
                log_error("output buffer is too small");
                return 0;
            }
            *ptr++ = (buffer >> 16) & 0xff;
            *ptr++ = (buffer >>  8) & 0xff;
            *ptr++ = buffer & 0xff;
            decoded += 3;
            buffer = 0;
            j = 0;
        }
    }

    if(j == 3) {
        if((decoded+2) > len) {
                log_error("output buffer is too small %d %d", decoded+2, len);
            return 0;
        }
        *ptr++ = (buffer >> 10) & 0xff;
        *ptr++ = (buffer >>  2) & 0xff;
        decoded += 2;
    }
    else if(j == 2) {
        if((decoded+1) > len) {
                log_error("output buffer is too small %d %d", decoded+1, len);
            return 0;
        }
        *ptr++ = (buffer >> 4) & 0xff;
        decoded++;
    }

    if(decoded < len) {
        log_error("not enough input data");
        return 0;
    }
    return 1;
}