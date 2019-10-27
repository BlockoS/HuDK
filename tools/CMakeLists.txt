cmake_minimum_required (VERSION 3.12)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

add_executable(vgm_strip vgm_strip.c)
target_compile_options(vgm_strip PRIVATE -Wall -Werror)

find_package(PNG)
find_package(Jansson)
if(NOT (${CMAKE_SYSTEM_NAME} STREQUAL "Windows"))
    find_package(PkgConfig)
endif()
if(PKG_CONFIG_FOUND AND NOT (${CMAKE_SYSTEM_NAME} STREQUAL "Windows"))
    pkg_check_modules(MXML REQUIRED mxml)
else()
    find_package(MXML REQUIRED)
endif()

add_subdirectory(externals)

add_executable(tiled2bat tiled2bat.c tileset.c image.c output.c pce.c log.c)
target_include_directories(tiled2bat PRIVATE ${JANSSON_INCLUDE_DIRS} ${MXML_INCLUDE_DIRS} ${PNG_INCLUDE_DIRS} ${CMAKE_CURRENT_SOURCE_DIR}/externals)
if(UNIX)
    target_compile_definitions(tiled2bat PRIVATE LOG_TERM_COLOR)
endif(UNIX)
target_link_libraries(tiled2bat ${JANSSON_LIBRARIES} ${MXML_LIBRARIES} ${PNG_LIBRARIES} argparse cwalk)
target_compile_options(tiled2bat PRIVATE -Wall -Werror)
