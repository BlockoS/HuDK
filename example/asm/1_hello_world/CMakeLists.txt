cmake_minimum_required(VERSION 3.5)

project(1_hello_world ASM)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_INCLUDE_PATH "" CACHE PATH "Path to HuDK include files")

include_directories(${HUDK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(hello_world hello_world.s)
set_target_properties(hello_world PROPERTIES OUTPUT_NAME hello_world.pce)
target_link_options(hello_world PRIVATE -C ${CMAKE_CURRENT_SOURCE_DIR}/hello_world.cfg)
