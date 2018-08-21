@echo off
:: Choose PLATFORM
setlocal EnableDelayedExpansion
IF DEFINED JENKINS (
:: add path for cmake, make 
set "PATH=!PATH!;C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\cygwin64\bin"
:: add path for msbuild
set "PATH=!PATH!;C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin"
:: add path for ifort and link.exe 
set "PATH=!PATH!;C:\Program Files (x86)\IntelSWTools\compilers_and_libraries_2018.3.210\windows\bin\intel64;C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.14.26428\bin\Hostx64\x64"
:: auxiliary include paths to make MUMPS work (are used within MakeFiles)
:: for example time.h, etc.
set "AUXONE=C:\Program Files (x86)\Windows Kits\10\Include\10.0.17134.0\ucrt"
:: for vcruntime.h
set "AUXTWO=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.14.26428\include"
set "WORKINGDIR=C:\Program Files (x86)\Jenkins\jobs\BoSSS-native\workspace"
copy /y "PropertySheet_JENKINS.props" "PropertySheet.props"
)

IF DEFINED HOME (
set "PATH=%PATH%C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\cygwin\bin;"
set WORKINGDIR=C:\BoSSS-native
copy /y "PropertySheet_HOME.props" "PropertySheet.props"
)

Echo modified PATH=%PATH%

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

del /q PropertySheet.props

ECHO %ERRORS% build failed