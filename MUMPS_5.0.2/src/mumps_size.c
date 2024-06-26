/*
 *
 *  This file is part of MUMPS 5.0.2, released
 *  on Fri Jul 15 09:12:54 UTC 2016
 *
 *
 *  Copyright 1991-2016 CERFACS, CNRS, ENS Lyon, INP Toulouse, Inria,
 *  University of Bordeaux.
 *
 *  This version of MUMPS is provided to you free of charge. It is
 *  released under the CeCILL-C license:
 *  http://www.cecill.info/licences/Licence_CeCILL-C_V1-en.html
 *
 */
/* Utility to automatically get the sizes of Fortran types */
#include "mumps_size.h"
void  MUMPS_CALL MUMPS_SIZE_C(char *a, char *b, MUMPS_INT *diff)
{
    *diff = (MUMPS_INT) (b - a);
}
