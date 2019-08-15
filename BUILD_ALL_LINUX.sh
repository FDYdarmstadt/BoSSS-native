#!/bin/bash
echo "=========================================="
echo "Building of BoSSSnative dynamic libraries started!"

# declare some path variables
export WORKINGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd )"
export LIBDIR="$WORKINGDIR/lib"
export INCLUDEDIR="$WORKINGDIR/thirdpartylibs"
cd $WORKINGDIR

# clean and create the thirdparty library directory
echo "Working in $WORKINGDIR"
if [ -d "$INCLUDEDIR" ]; then
    echo "Thirdparty library folder $INCLUDEDIR already exists, commencing ..."
  else
    echo "Thirdparty library folder $INCLUDEDIR does not exist, creating ..."
    mkdir $INCLUDEDIR
fi

# clean and create the output directory
if [ -d "$LIBDIR" ]; then
    echo "Output folder $LIBDIR already exists, commencing ..."
  else
    echo "Output folder $LIBDIR does not exist, creating ..."
    mkdir $LIBDIR
fi

echo "=========================================="
echo "Creating of static third-party libraries ..."
echo "Compiling single and double precision sequential MUMPS"
echo "Compiling single and double precision openMP parallel MUMPS"
echo "Compiling single and double precision MPI parallel MUMPS"
echo "Compiling METIS"

echo "Compiling TECIO Tecplot library"
FILE=libtecio.a
if [ -f "$INCLUDEDIR/$FILE" ]; then
  echo "$FILE exists, skipping compilation of TECIO"
else
  echo "$FILE does not exist, commencing compilation of TECIO"
  cd $WORKINGDIR/TECIO/teciosrc
  make -f Makefile.linux clean
  make -f Makefile.linux
  cp libtecio.a $INCLUDEDIR
  cd $WORKINGDIR
  echo "Done compiling TECIO"
fi

echo "=========================================="
echo "Starting compiling and linking of libBoSSSnative_seq.so"
ERRORS=""
make -f $WORKINGDIR/BoSSSnative_seq/Makefile
make clean -f $WORKINGDIR/BoSSSnative_seq/Makefile
