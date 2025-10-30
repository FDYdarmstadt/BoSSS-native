This folder contains sample scripts to run the paru_benchmark program on two
particular systems. These scripts were used to benchmark ParU and UMFPACK for
the ACM TOMS paper submission for ParU:

    do_paru_and_umf_hyper
    do_paru_and_umf.slurm

You will need to revise these scripts to point to the particular locations of
the paru_benchmark program, and the test matrices (in Matrix Market format).
The test matrices are too large to include here.  They can be obtained from the
SuiteSparse matrix collection, currently at sparse.tamu.edu.

