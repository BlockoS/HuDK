cmake_minimum_required(VERSION 3.5)

project(2_custom_font ASM)

set(HUDK_TOOLS_PATH "" CACHE PATH "Path to HuDK tools")
set(HUDK_INCLUDE_PATH "" CACHE PATH "Path to HuDK include files")

include_directories(${HUDK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/data/font.bin
                   COMMAND ${HUDK_TOOLS_PATH}/encode_gfx data.json font.png 
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                   COMMENT "convert fontset")

add_custom_target(font DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/data/font.bin")

add_executable(custom_font custom_font.s)
add_dependencies(custom_font font)
set_target_properties(custom_font PROPERTIES OUTPUT_NAME custom_font.pce)
target_link_options(custom_font PRIVATE -C ${CMAKE_CURRENT_SOURCE_DIR}/custom_font.cfg)
