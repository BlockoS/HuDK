find_package(PNG)

if(NOT PNG_FOUND)
    add_library(zlib INTERFACE)

    ExternalProject_Add(zlib_external
        GIT_REPOSITORY https://github.com/madler/zlib.git
        GIT_TAG v1.2.11
        GIT_PROGRESS 1
        BUILD_ALWAYS OFF
        INSTALL_DIR ${CMAKE_BINARY_DIR}/package
        CMAKE_CACHE_ARGS
            -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/package
    )

    add_dependencies(zlib zlib_external)

    add_library(libpng INTERFACE)

    ExternalProject_Add(libpng_external
        DEPENDS zlib_external
        GIT_REPOSITORY https://git.code.sf.net/p/libpng/code
        GIT_TAG v1.6.37
        GIT_PROGRESS 1
        BUILD_ALWAYS OFF
        CMAKE_CACHE_ARGS
            -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/package
            -DCMAKE_PREFIX_PATH:PATH=${CMAKE_BINARY_DIR}/package
            -DPNG_SHARED:BOOL=OFF
            -DPNG_STATIC:BOOL=ON
            -DPNG_TESTS:BOOL=OFF
            -DPNG_DEBUG:BOOL=OFF
            -DPNGARG:BOOL=OFF
            -DBUILD_SHARED_LIBS:BOOL=FALSE
    )

    add_dependencies(libpng libpng_external)
    set(PNG_INCLUDE_DIRS ${CMAKE_BINARY_DIR}/package/include)
    find_library(PNG_LIBRARIES NAMES png PATHS ${CMAKE_BINARY_DIR}/package/)
endif()

set(HUDK_UTILS_SRC base64.c image.c log.c output.c buffer.c pce.c utils.c)
set(HUDK_UTILS_HDR base64.h image.h log.h output.h buffer.h pce.h utils.h)

add_library(hudk_utils STATIC ${HUDK_UTILS_SRC} ${HUDK_UTILS_HDR})
target_include_directories(hudk_utils PUBLIC ${HUDK_TOOLS_EXTERNALS_DIR} ${PNG_INCLUDE_DIRS})
target_link_libraries(hudk_utils ${PNG_LIBRARIES} cwalk)
if(NOT MSVC)
	target_compile_options(hudk_utils PRIVATE -Wall -Werror)
endif()
