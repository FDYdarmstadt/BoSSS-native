#include "TECIOexportsPreProc.h"

/*
 * Within this file, we define just those BLAS functions that should be exported by the
 * BLAS_LAPACK - library;
 * We add a BoSSS-prefix to avoid naming confusion.
 * (On Windows, it would be easier to us an .def - export file, but that is not supported
 * by gcc compiler Linux)
 */

MAKE_FORTRAN_EXPORT(tecini110,6)
MAKE_FORTRAN_EXPORT(teczne110,18)
MAKE_FORTRAN_EXPORT(tecdat110,3)
MAKE_FORTRAN_EXPORT(tecend110,0)
MAKE_FORTRAN_EXPORT(tecnod110,1)
