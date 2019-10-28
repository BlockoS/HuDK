cmake_minimum_required (VERSION 3.12)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

set(HUDK_TOOLS_EXTERNALS_DIR "${CMAKE_CURRENT_LIST_DIR}/externals")

add_subdirectory(externals)

add_executable(vgm_strip vgm_strip.c)
target_compile_options(vgm_strip PRIVATE -Wall -Werror)

add_subdirectory(tiled2bat)
