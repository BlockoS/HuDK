# Try to find Mini-XML on Windows
#
# MXLM_FOUND - system has Mini-XML
# MXLM_INCLUDE_DIRS - the Mini-XML include directory
# MXLM_LIBRARIES - Link these to use Mini-XML
#
# Copyright (c) 2019 MooZ <mooz@blockos.org>
# Licensed under the MIT License
#

if (MXML_LIBRARIES AND MXML_INCLUDE_DIRS)
    # in cache already
    set(MXML_FOUND TRUE)
else (MXML_LIBRARIES AND MXML_INCLUDE_DIRS)

    find_path(MXML_INCLUDE_DIR
        NAMES
            mxml.h
        PATHS
            ${MXML_INCLUDE_DIRS}
    )

    find_library(MXML_LIBRARY
        NAMES
            mxml
        PATHS
            ${MXML_LIBRARY_DIRS}
    )

    set(MXML_INCLUDE_DIRS ${MXML_INCLUDE_DIR})
    set(MXML_LIBRARIES ${MXML_LIBRARY})

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(MXML DEFAULT_MSG MXML_LIBRARIES MXML_INCLUDE_DIRS)
    mark_as_advanced(MXML_INCLUDE_DIRS MXML_LIBRARIES)

end (MXML_LIBRARIES AND MXML_INCLUDE_DIRS)
