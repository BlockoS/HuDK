cmake_minimum_required(VERSION 3.5)

project(asm-examples ASM)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include ${CMAKE_CURRENT_SOURCE_DIR}/.. ${CMAKE_CURRENT_SOURCE_DIR})

add_subdirectory(asm/1_hello_world)
add_subdirectory(asm/2_custom_font)
add_subdirectory(asm/3_map_8x8)
add_subdirectory(asm/4_map_16x16)
add_subdirectory(asm/5_joypad)
add_subdirectory(asm/6_sprites)
add_subdirectory(asm/7_scroll)
add_subdirectory(asm/8_clock)
add_subdirectory(asm/9_pong)
add_subdirectory(asm/20_vgm)

add_subdirectory(C/1_hello_world)
add_subdirectory(C/2_custom_font)
add_subdirectory(C/3_map_8x8)
add_subdirectory(C/4_map_16x16)
add_subdirectory(C/5_joypad)
add_subdirectory(C/6_sprites)
add_subdirectory(C/7_scroll)
add_subdirectory(C/8_clock)
add_subdirectory(C/9_pong)
add_subdirectory(C/20_vgm)

