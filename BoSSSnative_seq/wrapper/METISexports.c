#include "METISexportsPreProc.h"

/*
 * Within this file, we define just those METIS functions that should be exported by the
 * METIS - library;
 * We add a BoSSS-prefix to avoid naming confusion.
 * (On Windows, it would be easier to us an .def - export file, but that is not supported
 * by gcc compiler Linux)
 */

MAKE_FORTRAN_EXPORT(METIS_PartGraphKway,13)
MAKE_FORTRAN_EXPORT(METIS_PartGraphRecursive,13)
