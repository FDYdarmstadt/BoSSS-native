#!/bin/sh
echo "\n==========================================\n"
echo "Building of BoSSSnative dynamic libraries started!\n"

# declare some path variables
export WORKINGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd )"
export LIBDIR="$WORKINGDIR/lib"
export INCLUDEDIR="$WORKINGDIR/thirdpartylibs"
export MKLROOT=/opt/intel/compilers_and_libraries_2019.4.243/linux/mkl
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

# check for the required libraries if they exist in the correct location
# if not compile them from source using the respective build system
# for more information consider the readmes in the specific folders
echo "\n==========================================\n"
echo "Creating static third-party libraries ..."

echo "Compiling single and double precision sequential MUMPS"
FILE1=libmumps_common_seq.a
FILE2=libdmumps_seq.a
FILE3=libsmumps_seq.a
if [ -f "$INCLUDEDIR/$FILE1" ] && [ -f "$INCLUDEDIR/$FILE2" ] &&  [ -f "$INCLUDEDIR/$FILE3" ]; then
  echo "$FILE1, $FILE2, $FILE3 exists, skipping compilation of MUMPS"
else
  echo "sequential MUMPS incomplete, commencing compilation of MUMPS"
  cd $WORKINGDIR/MUMPS_5.0.2
  # first clean up
  make clean 1>/dev/null 2>&1
  cp Make.inc/Makefile.MUMPS.SEQ ./Makefile.inc
  if [ ! -f "$INCLUDEDIR/$FILE2" ]; then
    echo "$FILE2 does not exist, starting compilation of dMUMPS"
    make 'd'
    cp lib/libdmumps.a $INCLUDEDIR/$FILE2
  fi
  if [ ! -f "$INCLUDEDIR/$FILE3" ]; then
    echo "$FILE3 does not exist, starting compilation of sMUMPS"
    make 's'
    cp lib/libsmumps.a $INCLUDEDIR/$FILE3
  fi
  cp lib/libmumps_common.a $INCLUDEDIR/$FILE1
  cp lib/libpord.a $INCLUDEDIR/libpord_seq.a
  cp libseq/libmpiseq.a $INCLUDEDIR/libmpiseq.a
  make clean 1>/dev/null 2>&1
  cd $WORKINGDIR
  echo "Done compiling sequential MUMPS\n"
fi

echo "Compiling single and double precision openMP parallel MUMPS"
FILE1=libmumps_common_omp.a
FILE2=libdmumps_omp.a
FILE3=libsmumps_omp.a
if [ -f "$INCLUDEDIR/$FILE1" ] && [ -f "$INCLUDEDIR/$FILE2" ] && [ -f "$INCLUDEDIR/$FILE3" ]; then
  echo "$FILE1, $FILE2, $FILE3 exists, skipping compilation of MUMPS"
else
  echo "openMP parallel MUMPS incomplete, commencing compilation of MUMPS"
  cd $WORKINGDIR/MUMPS_5.0.2
  # first clean up
  make clean 1>/dev/null 2>&1
  cp Make.inc/Makefile.MUMPS.OMP ./Makefile.inc
  if [ ! -f "$INCLUDEDIR/$FILE2" ]; then
    echo "$FILE2 does not exist, starting compilation of dMUMPS"
    make 'd'
    cp lib/libdmumps.a $INCLUDEDIR/$FILE2
  fi
  if [ ! -f "$INCLUDEDIR/$FILE3" ]; then
    echo "$FILE3 does not exist, starting compilation of sMUMPS"
    make 's'
    cp lib/libsmumps.a $INCLUDEDIR/$FILE3
  fi
  cp lib/libmumps_common.a $INCLUDEDIR/$FILE1
    cp lib/libpord.a $INCLUDEDIR/libpord_omp.a
  make clean 1>/dev/null 2>&1
  cd $WORKINGDIR
  echo "Done compiling openMP parallel MUMPS\n"
fi

echo "Compiling single and double precision MPI parallel MUMPS"
FILE1=libmumps_common_mpi.a
FILE2=libdmumps_mpi.a
FILE3=libsmumps_mpi.a
if [ -f "$INCLUDEDIR/$FILE1" ] && [ -f "$INCLUDEDIR/$FILE2" ] && [ -f "$INCLUDEDIR/$FILE3" ]; then
  echo "$FILE1, $FILE2, $FILE3 exists, skipping compilation of MUMPS"
else
  echo "MPI parallel MUMPS incomplete, commencing compilation of MUMPS"
  cd $WORKINGDIR/MUMPS_5.0.2
  # first clean up
  make clean 1>/dev/null 2>&1
  cp Make.inc/Makefile.MUMPS.MPI ./Makefile.inc
  if [ ! -f "$INCLUDEDIR/$FILE2" ]; then
    echo "$FILE2 does not exist, starting compilation of dMUMPS"
    make 'd'
    cp lib/libdmumps.a $INCLUDEDIR/$FILE2
  fi
  if [ ! -f "$INCLUDEDIR/$FILE3" ]; then
    echo "$FILE3 does not exist, starting compilation of sMUMPS"
    make 's'
    cp lib/libsmumps.a $INCLUDEDIR/$FILE3
  fi
  cp lib/libmumps_common.a $INCLUDEDIR/$FILE1
    cp lib/libpord.a $INCLUDEDIR/libpord_mpi.a
  make clean 1>/dev/null 2>&1
  cd $WORKINGDIR
  echo "Done compiling MPI parallel MUMPS\n"
fi

echo "Compiling METIS"
FILE=libmetis.a
if [ -f "$INCLUDEDIR/$FILE" ]; then
  echo "$FILE exists, skipping compilation of METIS"
else
  echo "$FILE does not exist, commencing compilation of METIS"
  cd $WORKINGDIR/metis-5.1.0
  make config cc=gcc prefix=$WORKINGDIR/metis-5.1.0/install
  make install
  cp install/lib/libmetis.a $INCLUDEDIR
  cd build/Linux-x86_64
  make clean
  cd ../..
  make clean
  make uninstall
  make distclean
  cd $WORKINGDIR
  echo "Done compiling METIS\n"
fi

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
  echo "Done compiling TECIO\n"
fi

echo "All thirdparty libraries existent!"

echo "\n==========================================\n"
echo "Starting compiling and linking of libBoSSSnative_seq.so"
ERRORS=""
cd $WORKINGDIR/BoSSSnative_seq
make -f $WORKINGDIR/BoSSSnative_seq/Makefile
make clean -f $WORKINGDIR/BoSSSnative_seq/Makefile 1>/dev/null 2>&1
echo "Finished compiling and linking of libBoSSSnative_seq.so\n"

echo "\n==========================================\n"
echo "Starting compiling and linking of libBoSSSnative_mpi.so"
ERRORS=""
cd $WORKINGDIR/BoSSSnative_seq
make -f $WORKINGDIR/BoSSSnative_mpi/Makefile
make clean -f $WORKINGDIR/BoSSSnative_mpi/Makefile 1>/dev/null 2>&1
echo "Finished compiling and linking of libBoSSSnative_mpi.so\n"
