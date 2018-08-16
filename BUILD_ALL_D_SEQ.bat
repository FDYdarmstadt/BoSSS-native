@echo off
:: Choose PLATFORM
IF DEFINED JENKINS (
set "PATH=%PATH%;C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\cygwin64\bin;"
set "WORKINGDIR=C:\Program Files (x86)\Jenkins\jobs\BoSSS-native\workspace"
:: specify paths for VS-projects, plz edit if necessary:
set "MKL_DIR=%PROGRAMFILES(x86)%\IntelSWTools\compilers_and_libraries_2018.3.210\windows"
set "MKL_LIB_DIR=%PROGRAMFILES(x86)%\IntelSWTools\compilers_and_libraries_2018.3.210\windows\mkl\lib\intel64_win"
:: directory of libiomp5md.lib ...
set "MKL_OPENMP_DIR=%PROGRAMFILES(x86)%\IntelSWTools\compilers_and_libraries_2018.3.210\windows\compiler\lib\intel64_win"
set "MS_MPI_DIR=%PROGRAMFILES(x86)%\Microsoft SDKs\MPI\Lib\x64"
)

IF DEFINED HOME (
set "PATH=%PATH%C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\cygwin\bin;"
set WORKINGDIR=C:\BoSSS-native
set "MKL_DIR=%PROGRAMFILES(x86)%\IntelSWTools\compilers_and_libraries_2018.3.210\windows"
set "MKL_LIB_DIR=%PROGRAMFILES(x86)%\IntelSWTools\compilers_and_libraries_2018.3.210\windows\mkl\lib\intel64_win"
:: directory of libiomp5md.lib ...
set "MKL_OPENMP_DIR=%PROGRAMFILES(x86)%\IntelSWTools\compilers_and_libraries_2018.3.210\windows\compiler\lib\intel64_win"
set "MS_MPI_DIR=%PROGRAMFILES(x86)%\Microsoft SDKs\MPI\Lib\x64"
)

:: Build composition ::
set MUMPS_TYPE=SEQ
set PARDISO_TYPE=SEQ
set METIS_TYPE=SEQ
set BLAS_LAPACK_TYPE=SEQ
set HYPRE_TYPE=MPI

echo Composition:
echo.
echo MUMPS_TYPE ... %MUMPS_TYPE%
echo PARDISO_TYPE ... %PARDISO_TYPE%
echo METIS_TYPE ... %METIS_TYPE%
echo BLAS_LAPACK_TYPE ... %BLAS_LAPACK_TYPE%
echo HYPRE_TYPE ... %HYPRE_TYPE%

set ERRORS=0
:: run individual Batch-Files
CALL pardiso-config\vsgen-pardiso.bat
CALL metis-seq-config\vsgen-metis-seq.bat
CALL dmumps-config\MUMPS_build_libs.bat
CALL blas_lapack-config\vsgen-blas_lapack.bat
::hypre-config\

ECHO %ERRORS% build failed