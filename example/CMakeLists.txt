cmake_minimum_required(VERSION 3.5)

# [todo] move this to the pceas directory

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/data/map)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/data/map/map8x8.inc
                   COMMAND $<TARGET_FILE:tiled2bat> -p 0 -b 0x2200 ${CMAKE_CURRENT_SOURCE_DIR}/data/map/map8x8.tmx
                   WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/data/map
                   DEPENDS tiled2bat
                   COMMENT "convert 8x8 map")

# atm you can't specify an output file to pceas, so the rom is generated next to the source file.
add_custom_command(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/pceas/map8x8.pce
                   COMMAND ${PCEAS} -I ${CMAKE_CURRENT_LIST_DIR}/../include -I . -I ./example ${CMAKE_CURRENT_SOURCE_DIR}/pceas/map8x8.s
                   DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/data/map/map8x8.inc
                           ${CMAKE_CURRENT_SOURCE_DIR}/pceas/map8x8.s
                   COMMENT "build 8x8 map example")

add_custom_target(map8x8_pceas ALL DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/pceas/map8x8.pce)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/data/map/map16x16.inc
                   COMMAND $<TARGET_FILE:tiled2bat> -p 0 -b 0x2200 ${CMAKE_CURRENT_SOURCE_DIR}/data/map/map16x16.json
                   WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/data/map
                   DEPENDS tiled2bat
                   COMMENT "convert 16x16 map")

add_custom_command(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/pceas/map16x16.pce
                   COMMAND ${PCEAS} -I ${CMAKE_CURRENT_LIST_DIR}/../include -I . -I ./example ${CMAKE_CURRENT_SOURCE_DIR}/pceas/map16x16.s
                   DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/data/map/map16x16.inc
                           ${CMAKE_CURRENT_SOURCE_DIR}/pceas/map16x16.s
                   COMMENT "build 16x16 map example")

add_custom_target(map16x16_pceas ALL DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/pceas/map16x16.pce)

add_custom_command(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/pceas/bm_tools.pce
                   COMMAND ${PCEAS} -I ${CMAKE_CURRENT_LIST_DIR}/../include -I . -I ./example ${CMAKE_CURRENT_SOURCE_DIR}/pceas/bm_tools.s
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/pceas/bm_tools.s
                   COMMENT "build backup ram editor example")

add_custom_target(bm_tools_pceas ALL DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/pceas/bm_tools.pce)

