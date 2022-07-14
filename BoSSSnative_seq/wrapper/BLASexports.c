#include "BLASexportsPreProc.h"

/*
 * Within this file, we define just those BLAS functions that should be exported by the
 * BLAS_LAPACK - library;
 * We add a BoSSS-prefix to avoid naming confusion.
 * (On Windows, it would be easier to us an .def - export file, but that is not supported
 * by gcc compiler Linux)
 */

MAKE_FORTRAN_EXPORT(ddot,5)
MAKE_FORTRAN_EXPORT(dnrm2,3)
MAKE_FORTRAN_EXPORT(dswap,5)
MAKE_FORTRAN_EXPORT(dgemm,13)
MAKE_FORTRAN_EXPORT(dgemv,11)
MAKE_FORTRAN_EXPORT(sgemm,13)
MAKE_FORTRAN_EXPORT(sgemv,11)
MAKE_FORTRAN_EXPORT(daxpy,6)
MAKE_FORTRAN_EXPORT(dscal,4)
