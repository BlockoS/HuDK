add_library(argparse STATIC argparse/argparse.c argparse/argparse.h)
target_include_directories(argparse INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include/argparse>
)

add_subdirectory(cwalk) 