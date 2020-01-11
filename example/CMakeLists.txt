cmake_minimum_required(VERSION 3.5)

project(asm-examples ASM)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include ${CMAKE_CURRENT_SOURCE_DIR}/.. ${CMAKE_CURRENT_SOURCE_DIR})

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/data/map)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/data/map/map8x8.inc
                   COMMAND ${HUDK_TOOLS_PATH}/tiled2bat -p 0 -b 0x2200 data/map/map8x8.tmx
                   WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/data/map
                   COMMENT "convert 8x8 map")

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/data/map/map16x16.inc
                   COMMAND ${HUDK_TOOLS_PATH}/tiled2bat -p 0 -b 0x2200 data/map/map16x16.json
                   WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/data/map
                   COMMENT "convert 16x16 map")

add_subdirectory(asm/1_hello_world)

add_executable(crc32 asm/crc32.s)
set_target_properties(crc32 PROPERTIES OUTPUT_NAME crc32.pce)
target_link_options(crc32 PRIVATE -C ${CMAKE_CURRENT_SOURCE_DIR}/asm/text.cfg)

add_executable(joytest asm/joytest.s)
set_target_properties(joytest PROPERTIES OUTPUT_NAME joytest.pce)
target_link_options(joytest PRIVATE -C ${CMAKE_CURRENT_SOURCE_DIR}/asm/text.cfg)

add_executable(text asm/text.s)
set_target_properties(text PROPERTIES OUTPUT_NAME text.pce)
target_link_options(text PRIVATE -C ${CMAKE_CURRENT_SOURCE_DIR}/asm/text.cfg)

add_executable(map8x8 asm/map8x8.s data/map/map8x8.inc)
set_target_properties(map8x8 PROPERTIES OUTPUT_NAME map8x8.pce)
target_link_options(map8x8 PRIVATE -C ${CMAKE_CURRENT_SOURCE_DIR}/asm/text.cfg)

add_executable(map16x16 asm/map16x16.s data/map/map16x16.inc)
set_target_properties(map16x16 PROPERTIES OUTPUT_NAME map16x16.pce)
target_link_options(map16x16 PRIVATE -C ${CMAKE_CURRENT_SOURCE_DIR}/asm/text.cfg)

#add_executable(bm_tools asm/bm_tools.s)
#set_target_properties(bm_tools PROPERTIES OUTPUT_NAME bm_tools.pce)
#target_link_options(bm_tools PRIVATE -C ${CMAKE_CURRENT_SOURCE_DIR}/asm/text.cfg)
