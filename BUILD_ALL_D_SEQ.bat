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
:: MS and Intel .lib paths ...
set "MKL_LIB_DIR=%PROGRAMFILES(x86)%\IntelSWTools\compilers_and_libraries_2018.3.210\windows\mkl\lib\intel64_win"
set "MKL_OPENMP_DIR=%PROGRAMFILES(x86)%\IntelSWTools\compilers_and_libraries_2018.3.210\windows\compiler\lib\intel64_win"
set "MS_MPI_DIR=C:\Program Files\Microsoft MPI\Lib\amd64"
set "MS_MPI_INC=C:\Program Files\Microsoft MPI\Inc"
)

IF DEFINED HOME (
set "PATH=%PATH%C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\cygwin\bin;"
set WORKINGDIR=C:\BoSSS-native
:: MS and Intel .lib paths ...
set "MKL_LIB_DIR=%PROGRAMFILES(x86)%\IntelSWTools\compilers_and_libraries_2018.3.210\windows\mkl\lib\intel64_win"
set "MKL_OPENMP_DIR=%PROGRAMFILES(x86)%\IntelSWTools\compilers_and_libraries_2018.3.210\windows\compiler\lib\intel64_win"
set "MS_MPI_DIR=%PROGRAMFILES(x86)%\Microsoft SDKs\MPI\Lib\x64"
set "MS_MPI_INC=%PROGRAMFILES(x86)%\Microsoft SDKs\MPI\Include"
)

:: set paths in .property file (necessary for the VS builds)
del /q "PropertySheet.props"
for /L %%i in (0,1,%x%) do (
	for /f "tokens=*" %%a in (PropertySheet_blank.props) do (
		SET s=%%a
		SET "s=!s:_MKL_LIB_DIR=%MKL_LIB_DIR%!"
		set "s=!s:_MKL_OPENMP_DIR=%MKL_OPENMP_DIR%!"
		set "s=!s:_MS_MPI_DIR=%MS_MPI_DIR%!"
		set "s=!s:_MS_MPI_INC=%MS_MPI_INC%!"
		set "s=!s:_WORKINGDIR=%WORKINGDIR%!"
		echo !s!>>"PropertySheet.props"
	)
)

Echo PropertySheet.props was created

Echo modified PATH=%PATH%

:: Build composition Default
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
:: build dir for dll collection
mkdir BUILDS

:: run individual Batch-Files
CALL blas_lapack-config\vsgen-blas_lapack.bat
::CALL pardiso-config\vsgen-pardiso.bat
::CALL hypre-config\vsgen-hypre.bat
::CALL metis-seq-config\vsgen-metis-seq.bat
CALL dmumps-config\MUMPS_build_libs.bat

ECHO %ERRORS% build failed

:: Hand files over to BoSSS_Install_dir

:: xcopy 

:: del PropertySheet.props

:: EXIT %ERRORS%