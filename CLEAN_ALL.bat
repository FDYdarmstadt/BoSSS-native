@echo off
:: Choose PLATFORM
IF %MACHINE%==JENKINS (
set "PATH=%PATH%C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\cygwin64\bin;"
set "WORKINGDIR=C:\Program Files (x86)\Jenkins\jobs\BoSSS-native\workspace"
)
IF %MACHINE%==HOME (
set "PATH=%PATH%C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\cygwin\bin;"
set WORKINGDIR=C:\BoSSS-native
)

:: directories
SET "MUMPS_THIRDPARTY=%WORKINGDIR%\MUMPS_5.0.2"
SET "MUMPS_BUILD=%WORKINGDIR%\MUMPS-VS"
SET "MUMPS_CONFIG=%WORKINGDIR%\dmumps-config"
SET "PARDISO_CONFIG=%WORKINGDIR%\pardiso-config"
SET "PARDISO_BUILD=%WORKINGDIR%\PARDISO"
SET "BLAS_LAPACK_CONFIG=%WORKINGDIR%\blas_lapack-config"
SET "BLAS_LAPACK_BUILD=%WORKINGDIR%\BLAS_LAPACK"
SET "METIS_THIRDPARTY=%WORKINGDIR%\metis-5.1.0"
SET "METIS_CONFIG=%WORKINGDIR%\metis-seq-config"
SET "METIS_BUILD=%METIS_THIRDPARTY%\build\windows"
SET "HYPRE_CONFIG=%WORKINGDIR%\hypre-config"
SET "HYPRE_THIRDPARTY=%WORKINGDIR%\hypre-2.11.2"
SET "HYPRE_BUILD=%WORKINGDIR%\hypre-2.11.2\src\cmbuild"

SET /P var= clean PARDISO ... <nul
cd "%PARDISO_BUILD%" >nul 2>&1
rmdir x64 /s /q >nul 2>&1
echo done.

SET /P var= clean MUMPS ... <nul
CD "%MUMPS_THIRDPARTY%" >nul 2>&1
CALL make clean >nul 2>&1
DEL "Makefile.inc" /q >nul 2>&1
rmdir "%MUMPS_BUILD%\x64" /s /q >nul 2>&1
echo done.

SET /P var= clean METIS ... <nul
rmdir "%METIS_BUILD%" /s /q >nul 2>&1
echo done.

SET /P var= clean BLAS and LAPACK ... <nul
cd "%BLAS_LAPACK_BUILD%" >nul 2>&1
rmdir x64 /s /q >nul 2>&1
echo done.

SET /P var= clean HYPRE ... <nul
cd "%HYPRE_BUILD%"
CALL msbuild HYPRE-MPI.proj /target:Clean >nul 2>&1
rmdir x64 /s /q >nul 2>&1
rmdir "HYPRE.dir" /s /q >nul 2>&1
rmdir Release /s /q >nul 2>&1
echo done.

cd %WORKINGDIR%

SET /P var= clean Working directory ... <nul
del "PropertySheet.props" /q >nul 2>&1
rmdir "BUILDS" /q /s >nul 2>&1
del log.txt /q >nul 2>&1
echo done.