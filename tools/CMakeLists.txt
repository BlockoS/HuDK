cmake_minimum_required (VERSION 3.12)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

set(HUDK_TOOLS_EXTERNALS_DIR "${CMAKE_CURRENT_LIST_DIR}/externals")

if(MSVC)
	add_definitions(-D_CRT_SECURE_NO_WARNINGS -D _CRT_NONSTDC_NO_DEPRECATE)
endif()

find_package(Jansson REQUIRED)

add_subdirectory(utils)
add_subdirectory(externals)

add_executable(vgm_strip vgm_strip.c)
target_include_directories(vgm_strip PRIVATE ${HUDK_TOOLS_EXTERNALS_DIR})
target_link_libraries(vgm_strip argparse)
if(NOT MSVC)
    target_compile_definitions(vgm_strip PRIVATE LOG_TERM_COLOR)
	target_compile_options(vgm_strip PRIVATE -Wall -Werror)
endif()

add_executable(encode_gfx encode_gfx.c)
target_include_directories(encode_gfx PRIVATE ${JANSSON_INCLUDE_DIRS} ${HUDK_TOOLS_EXTERNALS_DIR})
target_link_libraries(encode_gfx ${JANSSON_LIBRARIES} argparse cwalk hudk_utils)
if(NOT MSVC)
    target_compile_definitions(encode_gfx PRIVATE LOG_TERM_COLOR)
	target_compile_options(encode_gfx PRIVATE -Wall -Werror)
endif()

add_subdirectory(tiled2bat)

install(TARGETS vgm_strip encode_gfx RUNTIME DESTINATION bin)
