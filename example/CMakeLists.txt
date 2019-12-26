cmake_minimum_required(VERSION 3.5)

# [todo] move this to the pceas directory

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/data/map)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/data/map/map8x8.inc
                   COMMAND $<TARGET_FILE:tiled2bat> -p 0 -b 0x2200 ${CMAKE_CURRENT_SOURCE_DIR}/data/map/map8x8.tmx
                   WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/data/map
                   DEPENDS tiled2bat
                   COMMENT "convert 8x8 map")

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/data/map/map16x16.inc
                   COMMAND $<TARGET_FILE:tiled2bat> -p 0 -b 0x2200 ${CMAKE_CURRENT_SOURCE_DIR}/data/map/map16x16.json
                   WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/data/map
                   DEPENDS tiled2bat
                   COMMENT "convert 16x16 map")

