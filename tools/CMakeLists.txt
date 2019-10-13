cmake_minimum_required (VERSION 3.12)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

add_executable(vgm_strip vgm_strip.c)
target_compile_options(vgm_strip PRIVATE -Wall -Werror)

find_package(PNG)
find_package(Jansson)

add_executable(tiled2bat tiled2bat.c tileset.c image.c output.c pce.c log.c)
target_include_directories(tiled2bat PRIVATE ${JANSSON_INCLUDE_DIRS} ${PNG_INCLUDE_DIRS})
if(UNIX)
    target_compile_definitions(tiled2bat PRIVATE LOG_TERM_COLOR)
endif(UNIX)
target_link_libraries(tiled2bat ${JANSSON_LIBRARIES} ${PNG_LIBRARIES})
target_compile_options(tiled2bat PRIVATE -Wall -Werror)
