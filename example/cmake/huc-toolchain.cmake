set( CMAKE_SYSTEM_NAME Generic )

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

get_filename_component(HUC_TOOLCHAIN_PATH "${HUC_PATH}" REALPATH)

set( CMAKE_C_COMPILER ${HUC_TOOLCHAIN_PATH}/huc CACHE PATH "Huc6280 C compiler")
set( CMAKE_C_COMPILER_ID huc )

set( CMAKE_C_COMPILER_ID_RUN TRUE )
set( CMAKE_C_COMPILER_ID_WORKS TRUE )
set( CMAKE_C_COMPILER_ID_FORCED TRUE )

set( CMAKE_ASM_COMPILER ${HUC_TOOLCHAIN_PATH}/pceas CACHE PATH "Huc6280 asm compiler")
set( CMAKE_ASM_COMPILER_ID pceas )

set( CMAKE_ASM_COMPILER_ID_RUN TRUE )
set( CMAKE_ASM_COMPILER_ID_WORKS TRUE )
set( CMAKE_ASM_COMPILER_ID_FORCED TRUE )
