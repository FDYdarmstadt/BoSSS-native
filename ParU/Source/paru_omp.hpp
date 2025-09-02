////////////////////////////////////////////////////////////////////////////////
//////////////////////////  paru_omp.hpp ///////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// ParU, Copyright (c) 2022-2024, Mohsen Aznaveh and Timothy A. Davis,
// All Rights Reserved.
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef PARU_OMP_H
#define PARU_OMP_H
//!
// definitions of using OpenMP inside ParU
//  @author Aznaveh
//

#if defined ( _OPENMP )

    #include <omp.h>
    #define PARU_OPENMP_MAX_THREADS       omp_get_max_threads ( )
    #define PARU_OPENMP_GET_WTIME         omp_get_wtime ( )
    #define PARU_OPENMP_GET_THREAD_ID     omp_get_thread_num ( )
    #define PARU_OPENMP_SET_MAX_ACTIVE_LEVELS(l)   omp_set_max_active_levels(l)
    #define PARU_OPENMP_GET_MAX_ACTIVE_LEVELS      omp_get_max_active_levels( )
    #define PARU_OPENMP_GET_ACTIVE_LEVEL  omp_get_active_level()
    #define PARU_OPENMP_GET_THREAD_NUM    omp_get_thread_num ( )

    static inline int PARU_omp_get_num_threads (void)
    {
        // get the current # of threads used by OpenMP
        return (omp_get_num_threads ( )) ;
    }

    static inline int PARU_omp_set_num_threads (int nthreads)
    {
        // get the current # of threads used by OpenMP, and return prior setting
        int prior = omp_get_num_threads ( ) ;
        omp_set_num_threads (nthreads) ;
        return (prior) ;
    }

    static inline int PARU_omp_get_dynamic (void)
    {
        // get the current OpenMP dynamic setting
        return (omp_get_dynamic ( )) ;
    }

    static inline int PARU_omp_set_dynamic (int dynamic)
    {
        // set the OpenMP dynamic threading option, and return prior setting
        int prior = omp_get_dynamic ( ) ;
        omp_set_dynamic (dynamic) ;
        return (prior) ;
    }

#else

    // no OpenMP, so use sequential frontal tree tasking
    #ifndef PARU_1TASK
    #define PARU_1TASK
    #endif

    #define PARU_OPENMP_MAX_THREADS       (1)
    #define PARU_OPENMP_GET_WTIME         (0)
    #define PARU_OPENMP_GET_THREAD_ID     (0)
    #define PARU_OPENMP_SET_MAX_ACTIVE_LEVELS(l)
    #define PARU_OPENMP_GET_MAX_ACTIVE_LEVELS      (1)
    #define PARU_OPENMP_GET_ACTIVE_LEVEL   (0)
    #define PARU_OPENMP_GET_THREAD_NUM     (0)

    static inline int PARU_omp_get_num_threads (void)
    {
        return (1) ;
    }

    static inline int PARU_omp_set_num_threads (int nthreads)
    {
        return (1) ;
    }

    static inline int PARU_omp_get_dynamic (void)
    {
        return (0) ;
    }

    static inline int PARU_omp_set_dynamic (int dynamic)
    {
        return (0) ;
    }

#endif

#endif
