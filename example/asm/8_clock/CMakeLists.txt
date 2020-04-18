cmake_minimum_required(VERSION 3.5)

project(8_clock ASM)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_INCLUDE_PATH "" CACHE PATH "Path to HuDK include files")

include_directories(${HUDK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(clock clock.s)
set_target_properties(clock PROPERTIES OUTPUT_NAME clock.pce)
