cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/data/map)

add_custom_command(OUTPUT data/map/map00.bin
                   COMMAND $<TARGET_FILE:tiled2bat> -p 0 -b 0x2200 ${CMAKE_CURRENT_SOURCE_DIR}/data/map/map8x8.tmx
                   WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/data/map
                   DEPENDS tiled2bat
                   COMMENT "convert 8x8 map")

# atm you can't specify an output file to pceas, so the rom is generated next to the source file.
add_custom_command(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/pceas/map8x8.pce
                   COMMAND ${PCEAS} -I ${CMAKE_CURRENT_LIST_DIR}/../include -I . -I ./example ${CMAKE_CURRENT_SOURCE_DIR}/pceas/map8x8.s
                   DEPENDS data/map/map00.bin
                   COMMENT "build 8x8 map example")

add_custom_target(map8x8_pceas ALL DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/pceas/map8x8.pce)
