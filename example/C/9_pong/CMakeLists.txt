cmake_minimum_required(VERSION 3.5)

project(C_9_pong C)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_INCLUDE_PATH "" CACHE PATH "Path to HuDK include files")

set(DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/data/)

include_directories(${HUDK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

file(MAKE_DIRECTORY ${DATA_DIR})

add_custom_command(OUTPUT ${DATA_DIR}/pong_map.inc 
                   COMMAND ${HUDK_TOOLS_PATH}/tiled2bat -p 0 -b 0x2200 ${CMAKE_CURRENT_SOURCE_DIR}/../../data/9_pong/pong_map.json
                   WORKING_DIRECTORY ${DATA_DIR}
                   COMMENT "convert map")

add_custom_target(pong_map_c DEPENDS "${DATA_DIR}/pong_map.inc")

set(sprites_list ${DATA_DIR}/sprites.bin ${DATA_DIR}/palette.bin)
add_custom_command(OUTPUT ${sprites_list}
                   COMMAND ${HUDK_TOOLS_PATH}/encode_gfx sprite.json sprite.png -o ${DATA_DIR}
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../../data/9_pong
                   COMMENT "convert sprites")

add_custom_target(pong_sprites_c ALL DEPENDS ${sprites_list})

add_executable(pong_c pong.c)
add_dependencies(pong_c pong_map_c pong_sprites_c)
target_include_directories(pong_c PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
set_target_properties(pong_c PROPERTIES OUTPUT_NAME pong.pce)
