#include "LAPACKexportsPreProc.h"

/*
 * Within this file, we define just those LAPACK functions that should be exported by the
 * BLAS_LAPACK - library;
 * We add a BoSSS-prefix to avoid naming confusion.
 * (On Windows, it would be easier to us an .def - export file, but that is not supported
 * by gcc compiler Linux)
 */

MAKE_FORTRAN_EXPORT(dgetrf,6)
MAKE_FORTRAN_EXPORT(dgetrs,9)
MAKE_FORTRAN_EXPORT(dgetri,7)
MAKE_FORTRAN_EXPORT(dgelsy,13)
MAKE_FORTRAN_EXPORT(dgelss,13)
MAKE_FORTRAN_EXPORT(dpotrf,5)
MAKE_FORTRAN_EXPORT(dtrtri,6)
MAKE_FORTRAN_EXPORT(dpotri,5)
MAKE_FORTRAN_EXPORT(dgeqrf,8)
MAKE_FORTRAN_EXPORT(dgeqp3,9)
MAKE_FORTRAN_EXPORT(dorgqr,9)
MAKE_FORTRAN_EXPORT(dposv,8)
MAKE_FORTRAN_EXPORT(dgecon,9)
MAKE_FORTRAN_EXPORT(dgeev,14)
MAKE_FORTRAN_EXPORT(dsyev,9)