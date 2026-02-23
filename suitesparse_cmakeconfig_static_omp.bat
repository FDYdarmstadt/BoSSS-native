echo off
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "SUPPOSED TO BE EXECUTED FROM MKL CMD !!!"
echo "(e.g., by call \"C:\Program Files (x86)\Intel\oneAPI\setvars.bat\" intel64 vs2022   "
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ON

cmake --fresh ^
      -S .\SuiteSparse_7.12.2 -B .\SuiteSparse_7.12.2_config_win_static_omp ^
	  -G "Visual Studio 17 2022" -A x64 ^
	  --log-level=VERBOSE ^
	  -DBLA_VENDOR=Intel10_64lp ^
	  -DBLAS_INCLUDE_DIRS="C:/Program Files (x86)/Intel/oneAPI/mkl/latest/include" ^
	  -DBLAS_LIBRARIES="C:/Program Files (x86)/Intel/oneAPI/mkl/latest/lib/mkl_intel_lp64.lib;C:/Program Files (x86)/Intel/oneAPI/compiler/latest/lib/libiomp5md.lib;C:/Program Files (x86)/Intel/oneAPI/mkl/latest/lib/mkl_intel_thread.lib;C:/Program Files (x86)/Intel/oneAPI/mkl/latest/lib/mkl_core.lib" ^
	  -DSUITESPARSE_USE_FORTRAN=OFF ^
	  -DCMAKE_C_FLAGS="/I\"%MKLROOT%\include\"" ^
      -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake ^
	  -DVCPKG_TARGET_TRIPLET=x64-windows ^
	  -DGMP_ROOT="C:\vcpkg\installed\x64-windows" ^
	  -DGMP_INCLUDE_DIR="C:\vcpkg\installed\x64-windows\include" ^
	  -DGMP_LIBRARY="C:\vcpkg\installed\x64-windows\lib\gmp.lib" ^
	  -DMPFR_INCLUDE_DIR="C:\vcpkg\installed\x64-windows\include" ^
	  -DMPFR_LIBRARY="C:\vcpkg\installed\x64-windows\lib\mpfr.lib" ^
	  -DBUILD_SHARED_LIBS=OFF ^
	  -DBUILD_STATIC_LIBS=ON ^
	  -DSUITESPARSE_USE_OPENMP=ON

::  dynamic
:: -DBLAS_LIBRARIES="C:/Program Files (x86)/Intel/oneAPI/mkl/latest/lib/mkl_intel_lp64.lib;    C:/Program Files (x86)/Intel/oneAPI/mkl/latest/lib/libiomp5md.lib      C:/Program Files (x86)/Intel/oneAPI/compiler/latest/lib/mkl_intel_thread.lib;C:/Program Files (x86)/Intel/oneAPI/mkl/latest/lib/mkl_core.lib" ^
 	  