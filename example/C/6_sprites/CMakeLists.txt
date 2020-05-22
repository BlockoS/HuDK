cmake_minimum_required(VERSION 3.5)

project(C_6_sprites C)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_INCLUDE_PATH "" CACHE PATH "Path to HuDK include files")

set(DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/data/)

include_directories(${HUDK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

file(MAKE_DIRECTORY ${DATA_DIR})

set(sprites_list ${DATA_DIR}/ball0.bin ${DATA_DIR}/ball1.bin
                 ${DATA_DIR}/ball2.bin ${DATA_DIR}/ball3.bin
                 ${DATA_DIR}/ball4.bin ${DATA_DIR}/ball5.bin
                 ${DATA_DIR}/ball6.bin ${DATA_DIR}/ball7.bin
                 ${DATA_DIR}/palette.bin)

add_custom_command(OUTPUT ${sprites_list}
                   COMMAND ${HUDK_TOOLS_PATH}/encode_gfx data.json balls.png -o ${DATA_DIR}
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../../data/6_sprites
                   COMMENT "convert sprites")

add_custom_target(sprites_data_c ALL DEPENDS ${sprites_list})

add_executable(sprites_c sprites.c)
add_dependencies(sprites_c sprites_data_c)
set_target_properties(sprites_c PROPERTIES OUTPUT_NAME sprites.pce)
