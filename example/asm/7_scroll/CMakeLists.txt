cmake_minimum_required(VERSION 3.5)

project(7_scroll ASM)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_INCLUDE_PATH "" CACHE PATH "Path to HuDK include files")

set(DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/data/)

include_directories(${HUDK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

file(MAKE_DIRECTORY ${DATA_DIR})

add_custom_command(OUTPUT ${DATA_DIR}/map_8x8.inc 
                   COMMAND ${HUDK_TOOLS_PATH}/tiled2bat -p 0 -b 0x2200 ${CMAKE_CURRENT_SOURCE_DIR}/map_8x8.tmx
                   WORKING_DIRECTORY ${DATA_DIR}
                   COMMENT "convert 8x8 map")

add_custom_target(scroll_data DEPENDS "${DATA_DIR}/map_8x8.inc")

add_executable(scroll scroll.s)
add_dependencies(scroll scroll_data)
target_include_directories(scroll PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
set_target_properties(scroll PROPERTIES OUTPUT_NAME scroll.pce)
target_link_options(scroll PRIVATE -C ${CMAKE_CURRENT_SOURCE_DIR}/scroll.cfg)
