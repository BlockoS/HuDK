cmake_minimum_required(VERSION 3.5)

project(C_8_clock C)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_INCLUDE_PATH "" CACHE PATH "Path to HuDK include files")

include_directories(${HUDK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(clock_c clock.c)
set_target_properties(clock_c PROPERTIES OUTPUT_NAME clock.pce)
