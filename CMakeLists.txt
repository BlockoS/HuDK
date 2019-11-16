cmake_minimum_required(VERSION 3.5)

project(hudk)

option(BUILD_EXAMPLES "Build examples." OFF)

add_subdirectory(tools)

if(BUILD_EXAMPLES)
    set(PCEAS "" CACHE FILEPATH "PCEAS assembler")
    add_subdirectory(example)
endif(BUILD_EXAMPLES)
