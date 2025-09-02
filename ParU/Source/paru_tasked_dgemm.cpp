////////////////////////////////////////////////////////////////////////////////
//////////////////////////  paru_tasked_dgemm //////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// ParU, Copyright (c) 2022-2024, Mohsen Aznaveh and Timothy A. Davis,
// All Rights Reserved.
// SPDX-License-Identifier: GPL-3.0-or-later

/*! @brief      a wrapper around BLAS_DGEMM for tasked base dgemmed
 *
 *
 * @author Aznaveh
 */

#include "paru_internal.hpp"

bool paru_tasked_dgemm
(
    int64_t f,
    int64_t M,
    int64_t N,
    int64_t K,
    double *A,
    int64_t lda,
    double *B,
    int64_t ldb,
    double beta,
    double *C,
    int64_t ldc,
    paru_work *Work,
    ParU_Numeric Num
)
{

    // get Control
    int32_t nthreads = Work->nthreads ;
    int64_t worthwhile_dgemm = Work->worthwhile_dgemm ;
    int64_t trivial = Work->trivial ;
    bool small = (M < worthwhile_dgemm && N < worthwhile_dgemm) ;
    bool tiny = (M < trivial && N < trivial && K < trivial) ;

    #define CHUNK ((double) 1e8)
    double work = ((double) M) * ((double) N) * ((double) K) ;
//  int nth = paru_nthreads (work, CHUNK, nthreads) ;
    int nth = nthreads ;

    int my_share = 0 ;

    DEBUGLEVEL(0);
    // alpha is always -1  in my DGEMMs
    double alpha = -1;
    int64_t naft;

    bool blas_ok = true ;

    #pragma omp atomic read
    naft = Work->naft;
    if (naft == 1)
    {
        // let the BLAS decide how many threads to use
        BLAS_set_num_threads (nth) ;
        printf ("proc_bind: %d ", omp_get_proc_bind ( )) ;
        printf ("dynamic: %d\n", omp_get_dynamic ( )) ;
    }
    else
    {
        // use a single thread in the BLAS
        BLAS_set_num_threads (1) ;
    }

#ifndef NTIME
    double start_time = PARU_OPENMP_GET_WTIME;
#endif

    if (tiny)
    {

        //----------------------------------------------------------------------
        // trivial dgemm: do this without the BLAS
        //----------------------------------------------------------------------

        PRLEVEL(-1, ("%% SMALL DGEMM (" LD "," LD "," LD ") in "
            LD "\n", M, N, K, f));
        for (int64_t i = 0; i < M; i++)
        {
            for (int64_t j = 0; j < N; j++)
            {
                if (beta == 0) C[i + j * ldc] = 0;
                for (int64_t k = 0; k < K; k++)
                {
                    C[i + j * ldc] -= A[i + k * lda] * B[k + j * ldb];
                }
            }
        }

    }
//    else if (small || (naft == 1) || (naft >= nth))
    else if (small || (naft >= nth))
    {

        //----------------------------------------------------------------------
        // single call to dgemm
        //----------------------------------------------------------------------

        // if small or no other tasks competing or there are lots of other tasks

        PRLEVEL(-1, ("%% A naft: %ld nth: %d DGEMM (" LD "x" LD ") in " LD "\n",
            naft, nth, M, N, f));

        my_share = (small || (naft >= nth)) ? 1 : nth ;
        int prior = BLAS_set_num_threads_local (my_share) ;
        SUITESPARSE_BLAS_dgemm("N", "N", M, N, K, &alpha, A, lda, B, ldb, &beta,
                               C, ldc, blas_ok);
        BLAS_set_num_threads_local (prior) ;

    }
    else
    {

        //----------------------------------------------------------------------
        // tasked dgemm
        //----------------------------------------------------------------------

        // This case is tested in ParU/Tcov, sometimes miss it, depending on
        // how the threads are scheduled.
        my_share = std::max ((int) 1, (int) (nth / naft)) ;

        #if ( defined ( BLAS_Intel10_64ilp ) || defined ( BLAS_Intel10_64lp ) )
        {

            //------------------------------------------------------------------
            // tasked dgemm with MKL BLAS: requires mkl_set_num_threads_local
            //------------------------------------------------------------------

            PRLEVEL(-1, ("%% MKL local threads for DGEMM (" LD "x" LD ") in "
                LD " [[%d]]\n", M, N, f, my_share));

            // using my share of threads
            int prior = BLAS_set_num_threads_local (my_share) ;
            SUITESPARSE_BLAS_dgemm("N", "N", M, N, K, &alpha, A, lda, B, ldb,
                &beta, C, ldc, blas_ok);
            BLAS_set_num_threads_local (prior) ;

        }
        #else
        {

            //------------------------------------------------------------------
            // tasked dgemm with any BLAS
            //------------------------------------------------------------------

            // This method works for any BLAS, but it is not as good as using
            // tasking within the BLAS (as done by MKL).

            // This code is tested in ParU/Tcov by the c-62.mtx, but it
            // sometimes is not triggered, depending on the non-deterministic
            // task ordering.

            PRLEVEL(-1, ("%%YES tasking for DGEMM (" LD "x" LD
                ") in " LD " \n", M, N, f));
            int64_t num_col_blocks = N / worthwhile_dgemm + 1;
            int64_t num_row_blocks = M / worthwhile_dgemm + 1;

            int64_t len_col = N / num_col_blocks;
            int64_t len_row = M / num_row_blocks;

            PRLEVEL(-1, ("%% col-blocks=" LD ",row-blocks=" LD " [" LD "]\n",
                num_col_blocks, num_row_blocks,
                num_col_blocks * num_row_blocks));
            // FIXME: add num_threads(nth) here:
            printf ("TASKING using %d threads, active level %d, max levels %d\n",
                omp_get_num_threads (),
                omp_get_active_level (),
                omp_get_max_active_levels ()) ;
            #pragma omp parallel proc_bind(close) num_threads(nth)
            #pragma omp single nowait
            {
                for (int64_t I = 0; I < num_row_blocks; I++)
                {
                    int64_t m = ((I + 1) == num_row_blocks) ?
                        (M - I * len_row) : len_row;

                    for (int64_t J = 0; J < num_col_blocks; J++)
                    {
                        int64_t n = ((J + 1) == num_col_blocks) ?
                            (N - J * len_col) : len_col;
                        PRLEVEL(1, ("%% I=" LD " J=" LD " m=" LD " n=" LD
                            " in " LD "\n", I, J, m, n, f));
                        #pragma omp task
                        {
                            bool my_blas_ok = true ;
                            SUITESPARSE_BLAS_dgemm(
                                "N", "N", m, n, K, &alpha, A + (I * len_row),
                                lda,
                                B + (J * len_col * ldb), ldb, &beta,
                                C + (J * ldc * len_col + I * len_row), ldc,
                                my_blas_ok);
                            if (!my_blas_ok)
                            {
                                #pragma omp atomic write
                                blas_ok = false ;
                            }
                        }
                    }
                }
            }
        }
        #endif
    }

#ifndef NTIME
    double time = PARU_OPENMP_GET_WTIME;
    time -= start_time;
    PRLEVEL(-1, ("%% DGEMM (" LD "," LD "," LD ")%1.1f in " LD " {naft: " LD
        "} in %lf seconds, work %g, nthreads %d, nth %d, my_share %d\n",
        M, N, K, beta, f, naft, time, work, nthreads, nth, my_share));
#endif

#ifdef COUNT_FLOPS
    #pragma omp atomic update
    Work->flp_cnt_dgemm += (double)2 * M * N * K;
#endif

    return (blas_ok) ;
}
