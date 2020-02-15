cmake_minimum_required(VERSION 3.5)

project(asm-examples ASM)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_TOOLS_PATH ${CMAKE_CURRENT_BINARY_DIR}/${HUDK_TOOLS_PATH})

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include ${CMAKE_CURRENT_SOURCE_DIR}/.. ${CMAKE_CURRENT_SOURCE_DIR})

add_subdirectory(asm/1_hello_world)
add_subdirectory(asm/2_custom_font)
add_subdirectory(asm/3_map_8x8)
add_subdirectory(asm/4_map_16x16)
add_subdirectory(asm/5_joypad)

add_executable(crc32 asm/crc32.s)
set_target_properties(crc32 PROPERTIES OUTPUT_NAME crc32.pce)
target_link_options(crc32 PRIVATE -C ${CMAKE_CURRENT_SOURCE_DIR}/asm/text.cfg)

add_executable(text asm/text.s)
set_target_properties(text PROPERTIES OUTPUT_NAME text.pce)
target_link_options(text PRIVATE -C ${CMAKE_CURRENT_SOURCE_DIR}/asm/text.cfg)

#add_executable(bm_tools asm/bm_tools.s)
#set_target_properties(bm_tools PROPERTIES OUTPUT_NAME bm_tools.pce)
#target_link_options(bm_tools PRIVATE -C ${CMAKE_CURRENT_SOURCE_DIR}/asm/text.cfg)
