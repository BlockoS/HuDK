cmake_minimum_required(VERSION 3.5)

project(C_7_scroll C)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_INCLUDE_PATH "" CACHE PATH "Path to HuDK include files")

set(DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/data/)

include_directories(${HUDK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

file(MAKE_DIRECTORY ${DATA_DIR})

add_custom_command(OUTPUT ${DATA_DIR}/map_8x8.inc 
                   COMMAND ${HUDK_TOOLS_PATH}/tiled2bat -p 0 -b 0x2200 ${CMAKE_CURRENT_SOURCE_DIR}/../../data/7_scroll/map_8x8.tmx
                   WORKING_DIRECTORY ${DATA_DIR}
                   COMMENT "convert 8x8 map")

add_custom_target(scroll_data_c DEPENDS "${DATA_DIR}/map_8x8.inc")

add_executable(scroll_c scroll_test.c)
add_dependencies(scroll_c scroll_data_c)
target_include_directories(scroll_c PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
set_target_properties(scroll_c PROPERTIES OUTPUT_NAME scroll.pce)
