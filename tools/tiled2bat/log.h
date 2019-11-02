/*
 * This file is part of HuDK.
 * ASM and C open source software development kit for the NEC PC Engine.
 * Licensed under the MIT License
 * (c) 2016-2019 MooZ
 */
#ifndef HUDK_TOOLS_LOG_H
#define HUDK_TOOLS_LOG_H

#include <stdlib.h>
#include <stdarg.h>

typedef enum {
    LOG_INFO,
    LOG_WARNING,
    LOG_ERROR
} log_type_t;

typedef void (*log_print_func_t)(log_type_t type, const char* file, size_t line, const char* function, const char* format, ...);

void log_set_print_func(log_print_func_t func);
log_print_func_t log_get_print_func();

#define log_error(format, ...) (log_get_print_func())(LOG_ERROR, __FILE__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)
#define log_warn(format,  ...) (log_get_print_func())(LOG_WARNING, __FILE__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)
#define log_info(format,  ...) (log_get_print_func())(LOG_INFO, __FILE__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)

#endif // HUDK_TOOLS_LOG_H
