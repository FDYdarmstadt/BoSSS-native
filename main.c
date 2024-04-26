#include <stdlib.h>
#include <stdio.h>


int BoSSS_bind_omp_threads(int NumThreads, int* CPUindices);

int main(int argc, char** argv) {
    int CPUindices[] = { 1, 3, 5, 7, 9, 11 };
    int NumCPUs = 6;

    BoSSS_bind_omp_threads(NumCPUs, CPUindices);

    for(int i = 0; i < NumCPUs; i++) {
        printf(" #### thread %d retval: %d\n", i, CPUindices[i]);
    }

    return 0;
}