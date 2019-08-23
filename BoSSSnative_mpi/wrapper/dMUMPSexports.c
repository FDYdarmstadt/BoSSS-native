#include "dMUMPSexportsPreProc.h"

/*
 * Within this file, we define just those dMUMPS functions that should be exported by the
 * MUMPS - library;
 * We add a BoSSS-prefix to avoid naming confusion.
 * (On Windows, it would be easier to us an .def - export file, but that is not supported
 * by gcc compiler Linux)
 */

MAKE_FORTRAN_EXPORT(dmumps_f77_,83)
MAKE_FORTRAN_EXPORT(mumps_get_mapping,0)
MAKE_FORTRAN_EXPORT(mumps_get_pivnul_list,0)
MAKE_FORTRAN_EXPORT(mumps_get_sym_perm,0)
MAKE_FORTRAN_EXPORT(mumps_get_uns_perm,0)
