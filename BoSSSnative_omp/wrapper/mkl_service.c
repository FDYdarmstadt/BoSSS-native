#define _GNU_SOURCE
#include <pthread.h>
#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
	   
#include <omp.h>
#include <mkl.h>

/*
 //Intel affinity API - not present in the standard omp.h 
#   if defined(_WIN32)
#       define __KAI_KMPC_CONVENTION __cdecl
#       ifndef __KMP_IMP
#           define __KMP_IMP __declspec(dllimport)
#       endif
#   else
#       define __KAI_KMPC_CONVENTION
#       ifndef __KMP_IMP
#           define __KMP_IMP
#       endif
#   endif


typedef void* kmp_affinity_mask_t;

extern int    __KAI_KMPC_CONVENTION  kmp_set_affinity(kmp_affinity_mask_t*);
extern int    __KAI_KMPC_CONVENTION  kmp_get_affinity(kmp_affinity_mask_t*);
extern int    __KAI_KMPC_CONVENTION  kmp_get_affinity_max_proc(void);
extern void   __KAI_KMPC_CONVENTION  kmp_create_affinity_mask(kmp_affinity_mask_t*);
extern void   __KAI_KMPC_CONVENTION  kmp_destroy_affinity_mask(kmp_affinity_mask_t*);
extern int    __KAI_KMPC_CONVENTION  kmp_set_affinity_mask_proc(int, kmp_affinity_mask_t*);
extern int    __KAI_KMPC_CONVENTION  kmp_unset_affinity_mask_proc(int, kmp_affinity_mask_t*);
extern int    __KAI_KMPC_CONVENTION  kmp_get_affinity_mask_proc(int, kmp_affinity_mask_t*);



*/

void BoSSS_set_num_threads(int nth) {
	mkl_set_num_threads(nth); 
}

int BoSSS_get_max_threads() {
	return mkl_get_max_threads(); 
}


//_Mkl_Api(void,MKL_Set_Num_Stripes,(int nstripes))
//#define mkl_set_num_stripes         MKL_Set_Num_Stripes

//_Mkl_Api(int,MKL_Get_Num_Stripes,(void))
//#define mkl_get_num_stripes         MKL_Get_Num_Stripes

//_Mkl_Api(int,MKL_Domain_Set_Num_Threads,(int nth, int MKL_DOMAIN))
//#define mkl_domain_set_num_threads  MKL_Domain_Set_Num_Threads

//_Mkl_Api(int,MKL_Domain_Get_Max_Threads,(int MKL_DOMAIN))
//#define mkl_domain_get_max_threads  MKL_Domain_Get_Max_Threads

//_Mkl_Api(void,MKL_Set_Dynamic,(int bool_MKL_DYNAMIC))
//#define mkl_set_dynamic             MKL_Set_Dynamic

//_Mkl_Api(int,MKL_Get_Dynamic,(void))
//#define mkl_get_dynamic             MKL_Get_Dynamic

//_Mkl_Api(void,MKL_Set_Dynamic,(int bool_MKL_DYNAMIC))
//#define mkl_set_dynamic             MKL_Set_Dynamic
 //__declspec(dllexport) 
 void BoSSS_set_dynamic(int Dynamic_Threads) {
     omp_set_dynamic(Dynamic_Threads);
 }

 void BoSSS_get_dynamic(int* Dynamic_Threads) {
    *Dynamic_Threads = omp_get_dynamic();
 }


/*


 //
 // From:
 // https://www.intel.com/content/www/us/en/docs/dpcpp-cpp-compiler/developer-guide-reference/2023-0/thread-affinity-interface.html#EXPLICITLY_SPECIFYING_OS_PROC_IDS__GOMP_CPU_AFFINITY
 // 
 //       Once an OpenMP thread has set its own affinity mask via a successful call to kmp_set_affinity(),
 //       then that thread remains bound to the corresponding OS proc set until 
 //       **at least** the end of the parallel region, 
 //       unless reset via a subsequent call to kmp_set_affinity().
 //      
 //       Between parallel regions, the affinity mask (and the corresponding OpenMP thread to OS proc bindings)
 //       can be considered thread private data objects, 
 //       and have the same persistence as described in the OpenMP Application Program Interface.
 //       For more information, see the OpenMP API specification (http://www.openmp.org), 
 //       some relevant parts of which are provided below:
 //
 //       In order for the affinity mask and thread binding to 
 //       **persist between two consecutive active parallel regions**, 
 //       all three of the following conditions must hold :
 //         1. Neither parallel region is nested inside another explicit parallel region.
 //         2. The number of threads used to execute both parallel regions is the same.
 //         3. The value of the dyn-var internal control variable in the enclosing task region
 //            is false at entry to both parallel regions.
 //
 //       Therefore, by **creating a parallel region at the start of the program** whose 
 //       **sole purpose** is to set the affinity mask for each thread, 
 //       you can mimic the behavior of the KMP_AFFINITY environment variable 
 //       with low-level affinity API calls, 
 //       if program execution obeys the three aforementioned rules from the OpenMP specification.
 //
 //
 //

 //
 // Note: this must be linked against the Intel OpenMP library (libiomp5),
 // because the routines to control thread-affinity (kmp_set_affinity, ...)
 // are Intel-specifiv and don't have a conterpart in other OpenMP implementations, 
 // e.g., GNU OpenMP (libgomp).
 //
 // Compilation/Linking with Intel Compiler against Inptel OpenMP is straigtforward;
 // Just use the `-liomp5` library:
 // icx -I"${MKLROOT}/include" -fopenmp -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_intel_lp64.a ${MKLROOT}/lib/intel64/libmkl_intel_thread.a ${MKLROOT}/lib/intel64/libmkl_core.a -Wl,--end-group -liomp5 -lpthread -lm -ldl  myomp.c -o my$
 //
 // Compilation with gcc against the `libomp5` is difficult:
 // See, e.g., the discussion here: https://stackoverflow.com/questions/25986091/telling-gcc-to-not-link-libgomp-so-it-links-libiomp5-instead
 // I was, however, not able to reproduse the solution  there.
 // - Providing `-liomp5` for the linker seems to pe ignored; `kmp_set_affinity`, etc., remains unresolved.
 // - Removing the `-fopenmp` switch from the linker just produces 
 // Finally, tweak the `/usr/lib/gcc/x86_64-linux-gnu/7/libgomp.spec` file which seems to enforce to link to `libgomp` 
 // ```
 //    # This spec file is read by gcc when linking.  It is used to specify the
 //    # standard libraries we need in order to link with libgomp.
 //    #*link_gomp: -lgomp %{static: -ldl } # old 
 //    *link_gomp: -liomp5 %{static: -ldl } #modifyed
 // ```
 //
 // Then, `gcc` finally seems to be able to link against `libomp5` 
 // gcc  -I"${MKLROOT}/include"  -fopenmp -c myomp.c # for compilation, the `-fopenmp` switsch is required, otherwise the OpenMP-code is just not parallelized 
 // gcc  -fopenmp -lm -ldl -o myomp myomp.o          # 
 //
 //
 // Furthermore, 
 //
 // a more portable, easier approch is suggested here:
 // see also: https://stackoverflow.com/questions/24862488/thread-affinity-with-windows-msvc-and-openmp


 // Force the executing thread to execute on logical CPU i
 // Returns 0 on success, something else on failure.
 int forceAffinity(int i)
 {
     kmp_affinity_mask_t mask;

     kmp_create_affinity_mask(&mask);
     kmp_set_affinity_mask_proc(i, &mask);

     return kmp_set_affinity(&mask);
 }
 
 */

int ParseCPUindices(int ThreadIndex, int* CPUindices, int** CPUindices_iThread) {

     int retval = 0;
     int iThread = 0;
     while (iThread <= ThreadIndex) {
         if (*CPUindices < -999999999) {
             retval = -1000000000; // affinity OMP thread # `iThread` shall be cloned from main thread
         } else if (*CPUindices >= 0) {
             retval = 1; // OMP thread # `iThread` is attaced to 1 CPU, CPU index is *CPUindices;
         } else {
             retval = -(*CPUindices) - 1; // eintry is -m, m > 0: the next m-1 entries are CPU indices for OMP thread # `iThread`

             if (iThread < ThreadIndex) {
                 for (int m = 0; m < retval; m++)
                     CPUindices++;
             } else {
                CPUindices++;
             }
         }

         iThread++;
         CPUindices++;
     }
     CPUindices--;

     *CPUindices_iThread = CPUindices;

     return retval;
 }

int BoSSS_bind_omp_threads(int NumThreads, int* CPUindices) {
    /*
    printf("BoSSS_bind_omp_threads, NumThreads = %d\n", NumThreads);
    for (int i = 0; i < NumThreads; i++) {
         printf("  thread %d ", i);
         fflush(stdout);
         int* pout;
         int NumCPUs = ParseCPUindices(i, CPUindices, &pout);
         printf(" NoOfCPUS = %d :", NumCPUs);
         for (int j = 0; j < NumCPUs; j++) {
             printf(" %d", pout[j]);
             fflush(stdout);
         }
         printf("\n");
         fflush(stdout);
     }*/


    mkl_set_num_threads(NumThreads);
    omp_set_num_threads(NumThreads); // doppelt hält besser

    // Dynamic threads must be turned of for setting affinity
    omp_set_dynamic(0);

    // we use Pthreads to set the OpenMP thread affinity;
    // Since GNU OpenMP (GOMP) builds on Pthreads, this should work.
    // We also assume that libBoSSSnative_omp is linked against GOMP and **not** Intel OpenMP (iomp5).
    cpu_set_t  mask;
    CPU_ZERO(&mask);
    for(int i = 0; i < NumThreads; i++) {
        CPU_SET(CPUindices[i], &mask);
    }

    sched_setaffinity(0, sizeof(mask), &mask);
#pragma omp parallel 
    {
        int iThread = omp_get_thread_num();
        int* CPUindices_iThread;
        int NumCPUs = ParseCPUindices(iThread, CPUindices, &CPUindices_iThread);
        
        if(NumCPUs >= 0) {
	        cpu_set_t  maskT;
            CPU_ZERO(&maskT);
            
            for(int j = 0; j < NumCPUs; j++)
                CPU_SET(CPUindices_iThread[j], &maskT);
            
            pthread_t thread;
            thread = pthread_self();
            CPUindices_iThread[0] = pthread_setaffinity_np(thread, sizeof(cpu_set_t), &maskT);
        } else {
            CPUindices_iThread[0] = 0;
        }
        //printf("retval in thread %d = %d\n", iThread, CPUindices_iThread[0]); fflush(stdout);

    }

    return 0;
}
