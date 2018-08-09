@echo off
:: Choose PLATFORM
IF DEFINED JTEST (
set "PATH=%PATH%C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\cygwin64\bin;"
set WORKINGDIR=C:\Users\JenkinsCI\test\workspace
)
IF DEFINED JENKINS (
set "PATH=%PATH%C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\cygwin64\bin;"
set "WORKINGDIR=C:\Program Files (x86)\Jenkins\jobs\BoSSS-native\workspace"
)
IF DEFINED HOME (
set "PATH=%PATH%C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\cygwin\bin;"
set WORKINGDIR=C:\BoSSS-native
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