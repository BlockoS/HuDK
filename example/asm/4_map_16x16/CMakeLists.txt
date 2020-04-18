cmake_minimum_required(VERSION 3.5)

project(4_map_16x16 ASM)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_INCLUDE_PATH "" CACHE PATH "Path to HuDK include files")

set(DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/data/)

include_directories(${HUDK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

file(MAKE_DIRECTORY ${DATA_DIR})

add_custom_command(OUTPUT ${DATA_DIR}/map_16x16.inc 
                   COMMAND ${HUDK_TOOLS_PATH}/tiled2bat -p 0 -b 0x2200 ${CMAKE_CURRENT_SOURCE_DIR}/map_16x16.json
                   WORKING_DIRECTORY ${DATA_DIR}
                   COMMENT "convert 16x16 map")

add_custom_target(map_16x16_data DEPENDS "${DATA_DIR}/map_16x16.inc")

add_executable(map_16x16 map_16x16.s)
add_dependencies(map_16x16 map_16x16_data)
target_include_directories(map_16x16 PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
set_target_properties(map_16x16 PROPERTIES OUTPUT_NAME map_16x16.pce)
