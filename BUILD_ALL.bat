@echo off
setlocal EnableDelayedExpansion

::check if all necessary variables are set
set "ErrorInput="
IF NOT DEFINED MACHINE set ErrorInput=1
IF NOT DEFINED ALL_TYPE set ErrorInput=1
::ERROR ... EXECUTION IS ABORTED
IF DEFINED ErrorInput (
ECHO some variables are not set. please set:
ECHO MACHINE[JENKINS/HOME], ALL_TYPE[SER/PAR]
set ERRORS=1
GOTO EOF
)
ECHO MACHINE = %MACHINE%
ECHO.

:: MACHINE dependent specification
IF %MACHINE%==JENKINS (
set "WORKINGDIR=C:\Program Files (x86)\Jenkins\jobs\BoSSS-native\workspace"
:: add path for cmake, make 
set "PATH=!PATH!;C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\cygwin64\bin"
:: add path for msbuild
set "PATH=!PATH!;C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin"
:: add path for ifort and link.exe 
set "PATH=!PATH!;C:\Program Files (x86)\IntelSWTools\compilers_and_libraries_2018.3.210\windows\bin\intel64;C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.15.26726\bin\Hostx64\x64"
:: auxiliary include paths to make MUMPS work (are used within MakeFiles)
:: for example time.h, etc.
set "AUXONE=C:\Program Files (x86)\Windows Kits\10\Include\10.0.17134.0\ucrt"
:: for vcruntime.h
set "AUXTWO=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.14.26428\include"
:: MS and Intel .lib paths ...
set "MKL_LIB_DIR=%PROGRAMFILES(x86)%\IntelSWTools\compilers_and_libraries_2018.3.210\windows\mkl\lib\intel64_win"
set "MKL_OPENMP_DIR=%PROGRAMFILES(x86)%\IntelSWTools\compilers_and_libraries_2018.3.210\windows\compiler\lib\intel64_win"
set "MS_MPI_DIR=C:\Program Files\Microsoft MPI\Lib\amd64"
set "MS_MPI_INC=C:\Program Files\Microsoft MPI\Inc"
)

IF %MACHINE%==HOME (
set WORKINGDIR=C:\BoSSS-native
set "PATH=%PATH%C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\cygwin\bin;"
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

Echo PropertySheet.props was created ...

Echo modified PATH=%PATH%

:: specify build composition
IF %ALL_TYPE%==SER (
:: Build composition Serial
set MUMPS_TYPE=SEQ
set PARDISO_TYPE=SEQ
set METIS_TYPE=SEQ
set BLAS_LAPACK_TYPE=SEQ
set HYPRE_TYPE=MPI
)

IF %ALL_TYPE%==PAR (
:: Build composition Parallel
set MUMPS_TYPE=OpenMP
set PARDISO_TYPE=OpenMP
set METIS_TYPE=SEQ
set BLAS_LAPACK_TYPE=SEQ
set HYPRE_TYPE=MPI
)

echo slected composition: %ALL_TYPE%
echo.
echo BLAS_LAPACK_TYPE ... %BLAS_LAPACK_TYPE%
echo PARDISO_TYPE ... %PARDISO_TYPE%
echo HYPRE_TYPE ... %HYPRE_TYPE%
echo METIS_TYPE ... %METIS_TYPE%
echo MUMPS_TYPE ... %MUMPS_TYPE%

::error counter, indicates how many builds failed
set ERRORS=0

:: run individual Batch-Files
CALL blas_lapack-config\vsgen-blas_lapack.bat
CALL pardiso-config\vsgen-pardiso.bat
CALL hypre-config\vsgen-hypre.bat
CALL metis-seq-config\vsgen-metis-seq.bat
CALL dmumps-config\MUMPS_build_libs.bat

:: copy files to build directory
mkdir BUILDS
set "DESTDIR=%WORKINGDIR%\BUILDS"
set "PLATFORM=x64"
set "CONFIG=Release"
set BLAS_LAPACK_STATUS=unknown
set PARDISO_STATUS=unknown
set HYPRE_STATUS=unknown
set METIS_STATUS=unknown
set MUMPS_STATUS=unknown

xcopy "%BLAS_LAPACK_BUILD%\%PLATFORM%\%CONFIG%\BLAS_LAPACK.dll" "%DESTDIR%" /y
if %errorlevel%==0 set BLAS_LAPACK_STATUS=success
if %errorlevel%==1 (
set BLAS_LAPACK_STATUS=failure
set /a ERRORS=%ERRORS%+1
)
xcopy "%PARDISO_BUILD%\%PLATFORM%\%CONFIG%\PARDISO.dll" "%DESTDIR%" /y
if %errorlevel%==0 set PARDISO_STATUS=success
if %errorlevel%==1 (
set PARDISO_STATUS=failure
set /a ERRORS=%ERRORS%+1
)
xcopy "%HYPRE_BUILD%\%CONFIG%\HYPRE.dll" "%DESTDIR%" /y
if %errorlevel%==0 set HYPRE_STATUS=success
if %errorlevel%==1 (
set HYPRE_STATUS=failure
set /a ERRORS=%ERRORS%+1
)
xcopy "%METIS_BUILD%\libmetis\%CONFIG%\metis.dll" "%DESTDIR%" /y
if %errorlevel%==0 set METIS_STATUS=success
if %errorlevel%==1 (
set METIS_STATUS=failure
set /a ERRORS=%ERRORS%+1
)
xcopy "%MUMPS_BUILD%\%PLATFORM%\%CONFIG%\dmumps.dll" "%DESTDIR%" /y
if %errorlevel%==0 set MUMPS_STATUS=success
if %errorlevel%==1 (
set MUMPS_STATUS=failure
set /a ERRORS=%ERRORS%+1
)

ECHO BLAS AND LAPACK ... %BLAS_LAPACK_STATUS%
ECHO PARDISO ... %PARDISO_STATUS%
ECHO HYPRE ... %HYPRE_STATUS%
ECHO METIS ... %METIS_STATUS%
ECHO MUMPS ... %MUMPS_STATUS%
ECHO Total failures ... %ERRORS%

:: add linked libraries





del /q PropertySheet.props
:EOF
::EXIT %ERRORS%