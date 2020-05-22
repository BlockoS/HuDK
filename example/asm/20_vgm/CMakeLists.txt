cmake_minimum_required(VERSION 3.5)

project(20_vgm ASM)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_INCLUDE_PATH "" CACHE PATH "Path to HuDK include files")

set(DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/data/)

include_directories(${HUDK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

file(MAKE_DIRECTORY ${DATA_DIR})

set(vgm_data_list ${DATA_DIR}/song.inc)

add_custom_command(OUTPUT ${vgm_data_list}
                   COMMAND ${HUDK_TOOLS_PATH}/vgm_strip -o 0x6000 -b 1 song magician_domain.vgm ${DATA_DIR}
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../../data/20_vgm
                   COMMENT "convert vgm")

add_custom_target(vgm_data ALL DEPENDS ${vgm_data_list})

add_executable(vgm_play vgm_play.s)
target_include_directories(vgm_play PRIVATE ${DATA_DIR})
add_dependencies(vgm_play vgm_data)
set_target_properties(vgm_play PROPERTIES OUTPUT_NAME vgm_play.pce)
