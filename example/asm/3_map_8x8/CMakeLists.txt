cmake_minimum_required(VERSION 3.5)

project(3_map_8x8 ASM)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_INCLUDE_PATH "" CACHE PATH "Path to HuDK include files")

set(DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/data/)

include_directories(${HUDK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

file(MAKE_DIRECTORY ${DATA_DIR})

add_custom_command(OUTPUT ${DATA_DIR}/map_8x8.inc 
                   COMMAND ${HUDK_TOOLS_PATH}/tiled2bat -p 0 -b 0x2200 ${CMAKE_CURRENT_SOURCE_DIR}/../../data/3_map_8x8/map_8x8.tmx
                   WORKING_DIRECTORY ${DATA_DIR}/
                   COMMENT "convert 8x8 map")

add_custom_target(map_8x8_data DEPENDS "${DATA_DIR}/map_8x8.inc")

add_executable(map_8x8 map_8x8.s)
add_dependencies(map_8x8 map_8x8_data)
target_include_directories(map_8x8 PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
set_target_properties(map_8x8 PROPERTIES OUTPUT_NAME map_8x8.pce)
