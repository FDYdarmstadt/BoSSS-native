#!/bin/bash
cd c:/BoSSS-native/MUMPS_5.0.2
echo "=====clean up===="
make clean
echo "===== build ====="
make
cd examples
echo -e "single/double precision test [s/d]? \c"
read precision
echo -e "parallel [y/n]? \c"
read parallel

echo "start testing ..."
echo "================="

MS_MPI='/cygdrive/c/Program Files/Microsoft MPI/Bin/mpiexec\'
#echo $(MS_MPI)
case $precision in
	"d")
	echo "double precision" 
	case $parallel in
		"y")
		echo "parallel"
		"$MS_MPI" -n 2 ./c_example
		"$MS_MPI" -n 2 ./dsimpletest < input_simpletest_real;;
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
		"$MS_MPI" -n 2 ./c_example
		"$MS_MPI" -n 2 ./ssimpletest < input_simpletest_real;;
		#"$MS_MPI" -n 4 ./c_example
		#"$MS_MPI" -n 4 ./ssimpletest < input_simpletest_real
		"n")
		echo "sequential"
		./c_example
		./ssimpletest < input_simpletest_real;;
	esac;;
esac