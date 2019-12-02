cmake_minimum_required(VERSION 3.5)

project(pceas-examples ASM)

add_executable(crc32 crc32.s)
target_include_directories(crc32 PRIVATE ${CMAKE_SOURCE_DIR}/../../include ${CMAKE_SOURCE_DIR}/.. ${CMAKE_SOURCE_DIR})
set_target_properties(crc32 PROPERTIES OUTPUT_NAME crc32.pce)

