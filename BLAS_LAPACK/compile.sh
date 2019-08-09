gcc -fPIC -c BLASexports.c
gcc BLASexports.o  -shared  -o libBLAS_LAPACK.so -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_intel_lp64.a ${MKLROOT}/lib/intel64/libmkl_sequential.a ${MKLROOT}/lib/intel64/libmkl_core.a -Wl,--end-group -Wl,--unresolved-symbols=report-all  -lpthread -lm -ldl
#gcc BLASexports.o  -shared -Wl,--unresolved-symbols=report-all -o libBLAS_LAPACK.so 
