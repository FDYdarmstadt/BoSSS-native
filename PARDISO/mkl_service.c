#include "stdafx.h"

#include <omp.h>
#include <mkl.h>


/* Intel affinity API - not present in the Microsoft omp.h */
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


//_Mkl_Api(int,MKL_Set_Num_Threads_Local,(int nth))
//#define mkl_set_num_threads         MKL_Set_Num_Threads
__declspec(dllexport) void BoSSS_set_num_threads(int nth) {
	mkl_set_num_threads(nth); 
}

//_Mkl_Api(int,MKL_Get_Max_Threads,(void))
//#define mkl_get_max_threads         MKL_Get_Max_Threads
 __declspec(dllexport) int BoSSS_get_max_threads() {
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
 __declspec(dllexport) void BoSSS_set_dynamic(int Dynamic_Threads) {
     omp_set_dynamic(Dynamic_Threads);
 }

 __declspec(dllexport) void BoSSS_get_dynamic(int* Dynamic_Threads) {
    *Dynamic_Threads = omp_get_dynamic();
 }


//_Mkl_Api(int,MKL_Get_Dynamic,(void))
//#define mkl_get_dynamic             MKL_Get_Dynamic


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

 // Force the executing thread to execute on logical CPU i
 // Returns 0 on success, something else on failure.
 int forceAffinity(int i)
 {
     kmp_affinity_mask_t mask;

     kmp_create_affinity_mask(&mask);
     kmp_set_affinity_mask_proc(i, &mask);

     return kmp_set_affinity(&mask);
 }

 __declspec(dllexport) int BoSSS_bind_omp_threads(int NumThreads, int* CPUindices) {
     mkl_set_num_threads(NumThreads);
     omp_set_num_threads(NumThreads); // doppelt hält besser

     // Dynamic threads must be turned of for setting affinity
     // 
     omp_set_dynamic(0); 

     

#pragma omp parallel
     {
         int thread_id = omp_get_thread_num(); // Get the thread ID of the current thread
         //printf("Hello from thread %d, setting affinity to CPU/core %d ...", thread_id, CPUindices[thread_id]);
         CPUindices[thread_id] = forceAffinity(CPUindices[thread_id]);
         //printf(" success: %d\n", CPUindices[thread_id]);
     }

     int i;
     for (i = 0; i < NumThreads; i++) {
         if (CPUindices[i] != 0)
             return -i - 1;
     }

     return 0;
 }