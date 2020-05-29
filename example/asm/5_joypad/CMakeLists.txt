cmake_minimum_required(VERSION 3.5)

project(5_joypad ASM)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_INCLUDE_PATH "" CACHE PATH "Path to HuDK include files")

include_directories(${HUDK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(joypad_test joypad_test.s)
set_target_properties(joypad_test PROPERTIES OUTPUT_NAME joypad_test.pce)
