if(NOT (${CMAKE_SYSTEM_NAME} STREQUAL "Windows"))
    find_package(PkgConfig)
endif()

if(PKG_CONFIG_FOUND AND NOT (${CMAKE_SYSTEM_NAME} STREQUAL "Windows"))
    pkg_check_modules(MXML mxml)
else()
    find_package(MXML)
endif()

if(NOT MXML_FOUND)
    add_library(mxml INTERFACE)
    ExternalProject_Add(mxml_external
        GIT_REPOSITORY https://github.com/BlockoS/mxml
        GIT_PROGRESS 1
        BUILD_ALWAYS OFF
        INSTALL_DIR ${CMAKE_BINARY_DIR}/package
        CMAKE_CACHE_ARGS
            -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/package
    )

    add_dependencies(mxml mxml_external)
    set(MXML_INCLUDE_DIRS ${CMAKE_BINARY_DIR}/package/include)
    find_library(MXML_LIBRARIES NAMES mxml PATHS ${CMAKE_BINARY_DIR}/package/)
endif()

add_executable(tiled2bat tiled2bat.c tileset.c tilemap.c json.c xml.c)
target_include_directories(tiled2bat PRIVATE ${JANSSON_INCLUDE_DIRS} ${MXML_INCLUDE_DIRS} ${HUDK_TOOLS_EXTERNALS_DIR})
if(NOT MSVC)
    target_compile_definitions(tiled2bat PRIVATE LOG_TERM_COLOR)
	target_compile_options(tiled2bat PRIVATE -Wall -Werror)
endif()
target_link_libraries(tiled2bat hudk_utils ${JANSSON_LIBRARIES} ${MXML_LIBRARIES} ${PNG_LIBRARIES} argparse)

install(TARGETS tiled2bat RUNTIME DESTINATION bin)