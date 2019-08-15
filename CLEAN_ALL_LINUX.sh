#!/bin/bash
echo ==========================================
echo Cleaning of libBoSSSnative_seq.so started!

export WORKINGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd )"
export LIBDIR="lib"
echo Working in $WORKINGDIR
echo ==========================================

ERRORS=""
