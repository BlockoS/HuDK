cmake_minimum_required(VERSION 3.5)

project(9_pong ASM)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_INCLUDE_PATH "" CACHE PATH "Path to HuDK include files")

set(DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/data/)

include_directories(${HUDK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

file(MAKE_DIRECTORY ${DATA_DIR})

add_custom_command(OUTPUT ${DATA_DIR}/pong_map.inc 
                   COMMAND ${HUDK_TOOLS_PATH}/tiled2bat -p 0 -b 0x2200 ${CMAKE_CURRENT_SOURCE_DIR}/pong_map.json
                   WORKING_DIRECTORY ${DATA_DIR}
                   COMMENT "convert map")

add_custom_target(pong_map DEPENDS "${DATA_DIR}/pong_map.inc")

set(sprites_list ${DATA_DIR}/sprites.bin ${DATA_DIR}/palette.bin)
add_custom_command(OUTPUT ${sprites_list}
                   COMMAND ${HUDK_TOOLS_PATH}/encode_gfx sprite.json sprite.png -o ${DATA_DIR}
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                   COMMENT "convert sprites")

add_custom_target(pong_sprites ALL DEPENDS ${sprites_list})

add_executable(pong pong.s)
add_dependencies(pong pong_map pong_sprites)
target_include_directories(pong PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
set_target_properties(pong PROPERTIES OUTPUT_NAME pong.pce)
