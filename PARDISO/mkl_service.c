#include "stdafx.h"

#include <omp.h>
#include <windows.h>
#include <mkl.h>

#include <stdio.h>
#include <string.h>

//#include <windows.h>

#define NUMBER_OF_SUPPORTED_PROCGROUPS  16

// C++ headers
//#include <iostream>
//#include <string>
//#include <sstream> // Include for std::ostringstream

/* Intel affinity API; included only in the omp.h used for Intel compiler; not contained for the MS compiler */
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
    omp_set_num_threads(nth);
}

__declspec(dllexport) int BoSSS_get_num_threads() {
    return omp_get_num_threads();
}

//_Mkl_Api(int,MKL_Get_Max_Threads,(void))
//#define mkl_get_max_threads         MKL_Get_Max_Threads
 __declspec(dllexport) int BoSSS_get_max_threads(int* ompSetting) {
    *ompSetting = omp_get_max_threads();
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

 // (Windows version) Returns information of CPU's to which the current process is assigned to.
 void GetAffinityString(char* str) {
     char tmp[255];
     memset(tmp, 0, sizeof(tmp));

     HANDLE processHandle = GetCurrentProcess();


     USHORT groupCount = 0;
     GetProcessGroupAffinity(processHandle, &groupCount, NULL); // second arg 0 on iput -> returns the n umber of processor 
     if (groupCount != 1) {
         //Console.WriteLine($"Process associated to more than one processor group ({groupCount}) -- i don't know what to do about it (tell Florian)!");
         //throw new NotSupportedException("Process associated to more than one processor group -- i don't know what to do about it (tell Florian)!");
     }

     sprintf(str, "NoOf CPUgrps: %d ", groupCount);

     USHORT groups[100];
     if (!GetProcessGroupAffinity(processHandle, &groupCount, groups)) {
         DWORD errorCode = GetLastError();
         fprintf(stderr, "Failed to get processor group affinity (Error code = %d).", errorCode);
         return;
     }

     for (int cntGroup = 0; cntGroup < groupCount; cntGroup++) {
         USHORT group = groups[cntGroup];
         GROUP_AFFINITY groupAffinity;
         if (GetThreadGroupAffinity(GetCurrentThread(), &groupAffinity)) {
             sprintf(tmp, "G%d, m=%I64x ", group, groupAffinity.Mask);
             strcat(str, tmp);
         }
         else {
             int errorCode = GetLastError();
             fprintf(stderr, "Failed GetThreadGroupAffinity (Error code = %d).", errorCode);;
         }
     }
 }


 // (Windows version) Returns information of CPU's to which the current process is assigned to.
 int GetAffinities(USHORT *pGroups, GROUP_AFFINITY* pAff) {
     

     HANDLE processHandle = GetCurrentProcess();


     USHORT groupCount = 0;
     GetProcessGroupAffinity(processHandle, &groupCount, NULL); // second arg 0 on iput -> returns the n umber of processor 
     
     if (groupCount >= NUMBER_OF_SUPPORTED_PROCGROUPS) {
         fprintf(stderr, "Got %d processor group, this machine is not from this world!\n", groupCount);
         return -1;
     }

     USHORT groups[NUMBER_OF_SUPPORTED_PROCGROUPS];
     if (!GetProcessGroupAffinity(processHandle, &groupCount, groups)) {
         DWORD errorCode = GetLastError();
         fprintf(stderr, "Failed to get processor group affinity (Error code = %d).\n", errorCode);
         return -1;
     }

     memcpy(pGroups, groups, sizeof(USHORT) * groupCount);

     for (int cntGroup = 0; cntGroup < groupCount; cntGroup++) {
         USHORT group = groups[cntGroup];
         GROUP_AFFINITY groupAffinity;
         if (GetThreadGroupAffinity(GetCurrentThread(), &groupAffinity)) {
             memcpy(pAff + cntGroup, &groupAffinity, sizeof(GROUP_AFFINITY));
         } else {
             DWORD errorCode = GetLastError();
             fprintf(stderr, "BoSSS_bind_omp_threads: Failed to get thread group affinity (Error code = %d).\n", errorCode);
             return -1;
         }
     }

     return groupCount;
 }

 int SetClonedAffinities(int NumberOfGroups, GROUP_AFFINITY* pAff) {

     //printf("Cloning %d groups, mask = %I64x\n", NumberOfGroups, pAff->Mask);

     for (int cntGroup = 0; cntGroup < NumberOfGroups; cntGroup++) {
         //USHORT group = groups[cntGroup];
         //GROUP_AFFINITY groupAffinity;
         if (SetThreadGroupAffinity(GetCurrentThread(), pAff + cntGroup, NULL)) {
             
         } else {
             DWORD errorCode = GetLastError();
             fprintf(stderr, "BoSSS_bind_omp_threads: Failed to SET thread group affinity (Error code = %d).\n", errorCode);
             return -1;
         }
     }

     return 0;
 }


 int BindToCPU_Win32(int NoOfCPUs, int* CPUIndex) {

    /* int thread_id = omp_get_thread_num();
     {
         printf("  thread %d, %d CPUs: ", thread_id, NoOfCPUs);
         fflush(stdout);
         for (int j = 0; j < NoOfCPUs; j++) {
             printf(" %d", CPUIndex[j]);
             fflush(stdout);
         }
         printf("\n");
         fflush(stdout);
     }*/

     GROUP_AFFINITY groupAffinity;
     ZeroMemory(&groupAffinity, sizeof(GROUP_AFFINITY));
     WORD group = (WORD)(CPUIndex[0] / 64);
     for (int i = 0; i < NoOfCPUs; i++) {
         if (CPUIndex[i] / 64 != group) {
             fprintf(stderr, "Unsupported: multiple CPU groups for a single thread.\n");
             return -77;
         }

         groupAffinity.Mask |= (KAFFINITY)1 << (CPUIndex[i] % 64); // Bind to the first core in the group
         groupAffinity.Group = group;
     }
     /*printf("affinity mask = %I64x\n", groupAffinity.Mask);
     fflush(stdout);*/

     if (SetThreadGroupAffinity(GetCurrentThread(), &groupAffinity, NULL)) {
         return 0;
     } else {
         DWORD errorCode = GetLastError();
         fprintf(stderr, "Failed to SET thread group affinity (Error code = %d).\n", errorCode);
         return -1;
     }

 }

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
 // Furthermore, `kmp_set_affinity_mask_proc`, etc. chrash from time to time
 // and shut-down the entire process:
 // ```
 //    OMP: Error #13: Assertion failure at kmp_affinity.cpp(5334).
 //    OMP: Hint Please submit a bug report with this message, compile and run commands used, and machine configuration info including native compiler and operating system versions. Faster response will be obtained by including all program sources. For information on submitting this issue, please see http://www.intel.com/software/products/support/.
 // ```
 //
 // a more portable, easier approch is suggested here:
 // see also: https://stackoverflow.com/questions/24862488/thread-affinity-with-windows-msvc-and-openmp

 int forceAffinity(int i)
 {
     kmp_affinity_mask_t mask;

     kmp_create_affinity_mask(&mask);
     kmp_set_affinity_mask_proc(i, &mask);

     return kmp_set_affinity(&mask);
 }


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



 __declspec(dllexport) int BoSSS_bind_omp_threads(int NumThreads, int* CPUindices) {
     mkl_set_num_threads(NumThreads);
     omp_set_num_threads(NumThreads); // doppelt h?lt besser
     
     /*
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
     }
     */


     // Dynamic threads must be turned of for setting affinity
     omp_set_dynamic(0); 

     HANDLE currentProcess = GetCurrentProcess();
     HANDLE mainThread = GetCurrentThread();
     DWORD mainThreadId = GetCurrentThreadId();

     USHORT groups[NUMBER_OF_SUPPORTED_PROCGROUPS];
     GROUP_AFFINITY Affinities[NUMBER_OF_SUPPORTED_PROCGROUPS];
     int NumberOfGroups = GetAffinities(groups, Affinities);
     if (NumberOfGroups <= 0)
         return -666;

#pragma omp parallel
     {
         int thread_id = omp_get_thread_num(); // Get the thread index of the current thread
         DWORD ompThreadId = GetCurrentThreadId();
         
         int* CPUindices_thread_id;
         int NumCPUs = ParseCPUindices(thread_id, CPUindices, &CPUindices_thread_id);
         
         {
             // duplicate from main thread
             if (NumCPUs < 0) {
                 // clone from main thread
                 CPUindices_thread_id[0] = SetClonedAffinities(NumberOfGroups, Affinities);
             } else if (NumCPUs >= 0) {
                 // bind to specific CPU
                 CPUindices_thread_id[0] = BindToCPU_Win32(NumCPUs, CPUindices_thread_id);
             }
         }



         //
         //CPUindices[thread_id] = forceAffinity(CPUindices[thread_id]);
     }

     USHORT groupsAfter[NUMBER_OF_SUPPORTED_PROCGROUPS];
     GROUP_AFFINITY AffinitiesAfter[NUMBER_OF_SUPPORTED_PROCGROUPS];
     int NumberOfGroupsAfter = GetAffinities(groupsAfter, AffinitiesAfter);
     if (NumberOfGroupsAfter > 0) {
         if (NumberOfGroupsAfter != NumberOfGroups) {
             printf("BoSSS_bind_omp_threads Warning: Number of proc groups in main thread changed: %d (before) vs. %d (after)\n", NumberOfGroups, NumberOfGroupsAfter);
             fflush(stdout);
         }

         if (memcmp(groups, groupsAfter, min(NumberOfGroups, NumberOfGroupsAfter) * sizeof(USHORT)) != 0
             || memcmp(Affinities, AffinitiesAfter, min(NumberOfGroups, NumberOfGroupsAfter) * sizeof(GROUP_AFFINITY))) {
             char AffString[1024];
             GetAffinityString(AffString);
             printf("BoSSS_bind_omp_threads Warning: affinity of main thread changed: %s \n", AffString);
             fflush(stdout);
         }
     }


     

     return 0;
 }