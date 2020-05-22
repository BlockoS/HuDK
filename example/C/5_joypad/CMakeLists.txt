cmake_minimum_required(VERSION 3.5)

project(C_5_joypad C)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_INCLUDE_PATH "" CACHE PATH "Path to HuDK include files")

include_directories(${HUDK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(joypad_c joypad_test.c)
set_target_properties(joypad_c PROPERTIES OUTPUT_NAME joypad.pce)
