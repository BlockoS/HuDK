cmake_minimum_required(VERSION 3.5)

project(C_1_hello_world C)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_INCLUDE_PATH "" CACHE PATH "Path to HuDK include files")

include_directories(${HUDK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(hello_world_c hello_world.c)
set_target_properties(hello_world_c PROPERTIES OUTPUT_NAME hello_world.pce)
