cmake_minimum_required(VERSION 3.5)

project(C_2_custom_font C)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_INCLUDE_PATH "" CACHE PATH "Path to HuDK include files")

set(DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/data/)

include_directories(${HUDK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

file(MAKE_DIRECTORY ${DATA_DIR})

add_custom_command(OUTPUT ${DATA_DIR}/font.bin
                   COMMAND ${HUDK_TOOLS_PATH}/encode_gfx data.json font.png -o ${DATA_DIR}
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../../data/2_custom_font
                   COMMENT "convert fontset")

add_custom_target(font_c DEPENDS "${DATA_DIR}/font.bin")

add_executable(custom_font_c custom_font.c)
add_dependencies(custom_font_c font_c)
target_include_directories(custom_font_c PRIVATE ${DATA_DIR})
set_target_properties(custom_font_c PROPERTIES OUTPUT_NAME custom_font.pce)
