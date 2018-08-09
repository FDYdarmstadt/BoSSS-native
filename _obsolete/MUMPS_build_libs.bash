#!/bin/bash

# variables, which have to be set first: WORKINGDIR, MUMPS_TYPE, MS_MPI, INTEL_INC

echo $WORKINGDIR
echo ${MUMPS_TYPE}
echo ${MS_MPI}

cd $WORKINGDIR/MUMPS_5.0.2
echo "=====clean up===="
make clean
rm -f Makefile.inc
case ${MUMPS_TYPE} in
"SEQ")
echo "sequential MUMPS build initiated"
cp $WORKINGDIR/dmumps-config/Makefile.inc.seq $WORKINGDIR/MUMPS_5.0.2/Makefile.inc;;
"OPENMP")
echo "OpenMP MUMPS build initiated"
cp $WORKINGDIR/dmumps-config/Makefile.inc.OpenMP $WORKINGDIR/MUMPS_5.0.2/Makefile.inc;;
"HYBRID")
echo "OpenMP and MPI MUMPS build initiated"
cp $WORKINGDIR/dmumps-config/Makefile.inc.MPI+OpenMP $WORKINGDIR/MUMPS_5.0.2/Makefile.inc;;
esac
echo "===== build ====="
make
cd examples
#chose single or double precision [s/d]
precision=d
#MPI yes or no [y/n]
case ${MUMPS_TYPE} in
"SEQ")
parallel=n;;
"OPENMP")
parallel=n;;
"HYBRID")
parallel=y;;
esac

echo "start testing ..."
echo "================="

#MS_MPI='/cygdrive/c/Program Files/Microsoft MPI/Bin/mpiexec\'

case $precision in
	"d")
	echo "double precision" 
	case $parallel in
		"y")
		echo "parallel"
		"${MS_MPI}" -n 2 ./c_example
		"${MS_MPI}" -n 2 ./dsimpletest < input_simpletest_real;;
		#"$MS_MPI" -n 4 ./c_example
		#"$MS_MPI" -n 4 ./dsimpletest < input_simpletest_real
		"n")
		echo "sequential"
		./c_example
		./dsimpletest < input_simpletest_real;;
	esac;;
	
	"s")
	echo "single precision"
	case $parallel in
		"y")
		echo "parallel"
		"${MS_MPI}" -n 2 ./c_example
		"${MS_MPI}" -n 2 ./ssimpletest < input_simpletest_real;;
		#"$MS_MPI" -n 4 ./c_example
		#"$MS_MPI" -n 4 ./ssimpletest < input_simpletest_real
		"n")
		echo "sequential"
		./c_example
		./ssimpletest < input_simpletest_real;;
	esac;;
esac
cd $WORKINGDIR

echo "building shared libraries"
echo "========================="

