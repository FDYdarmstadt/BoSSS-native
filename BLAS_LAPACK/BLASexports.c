#include "DllExportPreProc.h"

/*
 * Within this file, we define just those BLAS functions that should be exported by the 
 * BLAS_LAPACK - library;
 * We add a BoSSS-prefix to avoid naming confusion.
 * (On Windows, it would be easier to us an .def - export file, but that is not supported 
 * by gcc compiler Linux)
 */

MAKE_FORTRAN_EXPORT(dgemm, 13)
MAKE_FORTRAN_EXPORT(sgemm, 13)
MAKE_FORTRAN_EXPORT(dgecon,9)
MAKE_FORTRAN_EXPORT(dgeev,14)
MAKE_FORTRAN_EXPORT(dsyev,9)
