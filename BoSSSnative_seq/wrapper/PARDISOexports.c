#include "PARDISOexportsPreProc.h"

/*
 * Within this file, we define just those PARDISO functions that should be exported by the
 * PARDISO - library ;
 * We add a BoSSS-prefix to avoid naming confusion.
 * (On Windows, it would be easier to us an .def - export file, but that is not supported
 * by gcc compiler Linux)
 */

MAKE_FORTRAN_EXPORT(pardisoinit,3)
MAKE_FORTRAN_EXPORT(pardiso,16)
