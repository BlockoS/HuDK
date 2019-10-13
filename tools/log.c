/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2019 MooZ
 */
#include "log.h"

#include <stdio.h>

static void log_terminal_print(log_type_t type, const char* file, size_t line, const char* function, const char* format, ...) {
    FILE *out = (type == LOG_ERROR) ? stderr: stdout;
    va_list args;
    
    const char *prefix;
#if LOG_TERM_COLOR
    switch(type) {
        case LOG_INFO:
            prefix = "\x1b[1;32m[info]\x1b[0m";
            break;
        case LOG_WARNING:
            prefix = "\x1b[1;33m[warning]\x1b[0m";
            break;
        case LOG_ERROR:
            prefix = "\x1b[1;31m[error]\x1b[0m";
            break;
    }
#else
    switch(type) {
        case LOG_INFO:
            prefix = "[info]";
            break;
        case LOG_WARNING:
            prefix = "[warning]";
            break;
        case LOG_ERROR:
            prefix = "[error]";
            break;
    }    
#endif // LOG_TERM_COLOR
    fprintf(out, "%s %s:%zd %s : ", prefix, file, line, function);
    va_start(args, format);
    vfprintf(out, format, args);
    va_end(args);
    fputc('\n', out);
    fflush(out);
}

static log_print_func_t g_log_print_func = log_terminal_print;

void log_set_print_func(log_print_func_t func) {
    g_log_print_func = func;
}

log_print_func_t log_get_print_func() {
    return g_log_print_func;
}
