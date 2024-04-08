#include "stdafx.h"

#include <omp.h>
#include <windows.h>
#include <mkl.h>

#include <stdio.h>
#include <string.h>


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
             fprintf(stderr, "Failed to get thread group affinity (Error code = %d).\n", errorCode);
             return -1;
         }
     }

     return groupCount;
 }

 int SetClonedAffinities(int NumberOfGroups, GROUP_AFFINITY* pAff) {

     for (int cntGroup = 0; cntGroup < NumberOfGroups; cntGroup++) {
         //USHORT group = groups[cntGroup];
         //GROUP_AFFINITY groupAffinity;
         if (SetThreadGroupAffinity(GetCurrentThread(), pAff + cntGroup, NULL)) {
             
         } else {
             DWORD errorCode = GetLastError();
             fprintf(stderr, "Failed to SET thread group affinity (Error code = %d).\n", errorCode);
             return -1;
         }
     }

     return 0;
 }


 int BindToCPU_Win32(int CPUIndex) {

     GROUP_AFFINITY groupAffinity;
     ZeroMemory(&groupAffinity, sizeof(GROUP_AFFINITY));
     groupAffinity.Mask = (KAFFINITY)1 << (CPUIndex % 64); // Bind to the first core in the group
     groupAffinity.Group = (USHORT)(CPUIndex / 64);

     if (SetThreadGroupAffinity(GetCurrentThread(), &groupAffinity, NULL)) {
         return 0;
     } else {
         DWORD errorCode = GetLastError();
         fprintf(stderr, "Failed to SET thread group affinity (Error code = %d).\n", errorCode);
         return -1;
     }

 }



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
 // see also: https://stackoverflow.com/questions/24862488/thread-affinity-with-windows-msvc-and-openmp
 __declspec(dllexport) int BoSSS_bind_omp_threads(int NumThreads, int* CPUindices) {
     mkl_set_num_threads(NumThreads);
     omp_set_num_threads(NumThreads); // doppelt hält besser

     

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


     //printf("Main thread: %I64x\n", (__int64) mainThread);
#pragma omp parallel
     {
         int thread_id = omp_get_thread_num(); // Get the thread ID of the current thread
         
         
         //printf("Hello from thread %d, setting affinity to CPU/core %d ...", thread_id, CPUindices[thread_id]);
         //printf(" success: %d\n", CPUindices[thread_id]);

         //char affinityInfo[1024];
         //GetAffinityString(affinityInfo);

         //HANDLE ompThread = GetCurrentThread();
         DWORD ompThreadId = GetCurrentThreadId();
         //BOOL equalToMain = ompThreadId == mainThreadId;
         //printf("Thread %d, to CPU %d, equal to main %d, %s \n", thread_id, CPUindices[thread_id], equalToMain, affinityInfo);

         if(ompThreadId != mainThreadId) {
             // duplicate from main thread
             if(CPUindices[thread_id] < 0)
                 // clone from main thread
                 CPUindices[thread_id] = SetClonedAffinities(NumberOfGroups, Affinities);
             else 
                 // bind to specific CPU
                 CPUindices[thread_id] = BindToCPU_Win32(CPUindices[thread_id]);

         } else {
             // never mess with the main thread
             CPUindices[thread_id] = 0;
         }



         //
         //CPUindices[thread_id] = forceAffinity(CPUindices[thread_id]);
     }


     USHORT groupsAfter[NUMBER_OF_SUPPORTED_PROCGROUPS];
     GROUP_AFFINITY AffinitiesAfter[NUMBER_OF_SUPPORTED_PROCGROUPS];
     int NumberOfGroupsAfter = GetAffinities(groupsAfter, AffinitiesAfter);
     if (NumberOfGroupsAfter > 0) {
         if (NumberOfGroupsAfter != NumberOfGroups) {
             printf("Warning: Number of proc groups in main thread changed: %d (before) vs. %d (after)\n", NumberOfGroups, NumberOfGroupsAfter);
             fflush(stdout);
         }

         if (memcmp(groups, groupsAfter, min(NumberOfGroups, NumberOfGroupsAfter) * sizeof(USHORT)) != 0
             || memcmp(Affinities, AffinitiesAfter, min(NumberOfGroups, NumberOfGroupsAfter) * sizeof(GROUP_AFFINITY))) {
             char AffString[1024];
             GetAffinityString(AffString);
             printf("Warning: affinity of main thread changed: %s \n", AffString);
             fflush(stdout);
         }
     }
         


     //printf("finished OMP thread binding; ----------- \n\n ");
     //fflush(stdout);
     int i;
     for (i = 0; i < NumThreads; i++) {
         if (CPUindices[i] != 0)
             return -i - 1;
     }

     return 0;
 }