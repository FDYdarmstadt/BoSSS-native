#-------------------------------------------------------------------------------
# SuiteSparse/cmake_modules/SuiteSparse__blas_threading.cmake
#-------------------------------------------------------------------------------

# Copyright (c) 2017-2025, Timothy A. Davis.  All Rights Reserved.
# SPDX-License-Identifier: BSD-3-clause

#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# determine the BLAS library properties: sequential or multithreaded
#-------------------------------------------------------------------------------

set ( CMAKE_REQUIRED_LIBRARIES    ${BLAS_LIBRARIES} )
set ( CMAKE_REQUIRED_LINK_OPTIONS ${BLAS_LINKER_FLAGS} )
set ( CMAKE_REQUIRED_INCLUDES     ${BLAS_INCLUDE_DIRS} )

#-------------------------------------------------------------------------------
# check the Intel MKL properties
#-------------------------------------------------------------------------------

string ( REGEX MATCH "^Intel" is_Intel ${BLA_VENDOR} )

if ( is_Intel )

    #-----------------------------------------------------------------------
    # determine if MKL is single-threaded or multi-threaded
    #-----------------------------------------------------------------------

    # check if the Intel MKL is single-threaded or multi-threaded

    try_run ( MKL_RUNS MKL_COMPILES
        ${CMAKE_CURRENT_BINARY_DIR}
        ${PROJECT_SOURCE_DIR}/../SuiteSparse_config/cmake_modules/check_mkl.c
        LINK_OPTIONS    ${BLAS_LINKER_FLAGS}
        LINK_LIBRARIES  ${BLAS_LIBRARIES}
        RUN_OUTPUT_VARIABLE MKL_OUTPUT )

    if ( ${MKL_COMPILES} )
        if ( ${MKL_RUNS} STREQUAL "FAILED_TO_RUN" )
            # MKL compiled but failed to run ... why?
            message ( FATAL_ERROR "Intel MKL failed to run" )
        endif ( )
        if ( ${MKL_OUTPUT} EQUAL 1 )
            message ( STATUS "Intel MKL: single-threaded" )
        else ( )
            message ( STATUS "Intel MKL: multi-threaded (threads: ${MKL_OUTPUT})" )
        endif ( )
    else ( )
        message ( FATAL_ERROR "Intel MKL failed to compile" )
    endif ( )

endif ( )

#-------------------------------------------------------------------------------
# check the OpenBLAS properties
#-------------------------------------------------------------------------------

if ( ${BLA_VENDOR} STREQUAL "OpenBLAS" )

    # check if OpenBLAS has openblas_get_num_threads (Mar 2015 or later)
    try_run ( OPENBLAS_2015_RUNS OPENBLAS_2015_COMPILES
        ${CMAKE_CURRENT_BINARY_DIR}
        ${PROJECT_SOURCE_DIR}/../SuiteSparse_config/cmake_modules/check_openblas_Mar2015.c
        LINK_OPTIONS    ${BLAS_LINKER_FLAGS}
        LINK_LIBRARIES  ${BLAS_LIBRARIES}
        RUN_OUTPUT_VARIABLE OPENBLAS_2015_OUTPUT )
    if ( ${OPENBLAS_2015_COMPILES} )
        if ( ${OPENBLAS_2015_RUNS} STREQUAL "FAILED_TO_RUN" )
            # OpenBLAS compiled but failed to run ... why?
            message ( FATAL_ERROR "OpenBLAS failed to run (v0.2.14 or later is required)" )
        endif ( ) 
    else ( )
        message ( FATAL_ERROR "OpenBLAS failed to compile (v0.2.14 or later is required)" )
    endif ( )

    # check if OpenBLAS has openblas_set_num_threads_local (Apr 2024 or later)
    try_run ( OPENBLAS_2024_RUNS OPENBLAS_2024_COMPILES
        ${CMAKE_CURRENT_BINARY_DIR}
        ${PROJECT_SOURCE_DIR}/../SuiteSparse_config/cmake_modules/check_openblas_Apr2024.c
        LINK_OPTIONS    ${BLAS_LINKER_FLAGS}
        LINK_LIBRARIES  ${BLAS_LIBRARIES}
        RUN_OUTPUT_VARIABLE OPENBLAS_2024_OUTPUT )

    if ( ${OPENBLAS_2024_COMPILES} )
        if ( ${OPENBLAS_2024_RUNS} STREQUAL "FAILED_TO_RUN" )
            # OpenBLAS compiled but failed to run ... why?
            message ( FATAL_ERROR "OpenBLAS v0.3.27 or later: failed to run" )
        endif ( )
        # We have OpenBLAS 0.3.27 or later;
        add_compile_definitions ( SUITESPARSE_HAVE_OPENBLAS_SET_NUM_THREADS_LOCAL )
        if ( ${OPENBLAS_2024_OUTPUT} EQUAL 1 )
            message ( STATUS "OpenBLAS v0.3.27 or later: single-threaded" )
        else ( )
            message ( STATUS "OpenBLAS v0.3.27 or later: multi-threaded (threads: ${OPENBLAS_2024_OUTPUT})" )
        endif ( )
    else ( )
        # We have OpenBLAS 0.2.14 to 0.3.26;
        # openblas_set_num_threads_local is not available
        if ( ${OPENBLAS_2015_OUTPUT} EQUAL 1 )
            message ( STATUS "OpenBLAS v0.2.14 to v0.3.26: single-threaded" )
        else ( )
            message ( STATUS "OpenBLAS v0.2.14 to v0.3.26: multi-threaded (threads: ${OPENBLAS_2015_OUTPUT})" )
        endif ( )
    endif ( )
endif ( )

