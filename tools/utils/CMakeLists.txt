find_package(PNG REQUIRED)

set(HUDK_UTILS_SRC base64.c image.c log.c output.c array.c pce.c utils.c)
set(HUDK_UTILS_HDR base64.h image.h log.h output.h array.h pce.h utils.h)

add_library(hudk_utils STATIC ${HUDK_UTILS_SRC} ${HUDK_UTILS_HDR})
target_include_directories(hudk_utils PUBLIC ${HUDK_TOOLS_EXTERNALS_DIR} ${PNG_INCLUDE_DIRS})
target_link_libraries(hudk_utils ${PNG_LIBRARIES} cwalk)
if(NOT MSVC)
	target_compile_options(hudk_utils PRIVATE -Wall -Werror)
endif()
