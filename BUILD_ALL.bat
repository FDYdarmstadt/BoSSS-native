@echo off
setlocal EnableDelayedExpansion

::counter of total errors
set ERRORS=0
::check if all necessary variables are set
set "ErrorInput="
IF NOT DEFINED WORKINGDIR set ErrorInput=1
::IF NOT DEFINED ALL_TYPE set ErrorInput=1
::ERROR ... EXECUTION IS ABORTED
IF DEFINED ErrorInput (
ECHO some variables are not set. please set:
ECHO WORKINGDIR[...]
ECHO optional: BUILD_SPEED[SLOW/FAST]
set ERRORS=1
GOTO EOF
)
IF NOT DEFINED BUILD_SPEED set BUILD_SPEED=SLOW
ECHO DLL BUILD PROCESS STARTED ...
ECHO.
ECHO WORKINGDIR = %WORKINGDIR%
ECHO BUILD SPEED = %BUILD_SPEED%
ECHO.

:: MACHINE dependent specification
:: add path for cmake, make 
::set "PATH=!PATH!;C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\cygwin64\bin"
:: add path for msbuild
::set "PATH=!PATH!;C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin"
:: add path for ifort and link.exe 
::set "PATH=!PATH!;C:\Program Files (x86)\IntelSWTools\compilers_and_libraries_2018.3.210\windows\bin\intel64;C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.15.26726\bin\Hostx64\x64"
:: auxiliary include paths to make MUMPS work (are used within MakeFiles)
:: for example time.h, etc.
::set "AUXONE=C:\Program Files (x86)\Windows Kits\10\Include\10.0.17134.0\ucrt"
:: for vcruntime.h
::set "AUXTWO=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.15.26726\include"
:: MS and Intel .lib paths ...
::set "MKL_LIB_DIR=%PROGRAMFILES(x86)%\IntelSWTools\compilers_and_libraries_2018.3.210\windows\mkl\lib\intel64_win"
::set "MKL_OPENMP_DIR=%PROGRAMFILES(x86)%\IntelSWTools\compilers_and_libraries_2018.3.210\windows\compiler\lib\intel64_win"
set "MS_MPI_DIR=C:\Program Files (x86)\Microsoft SDKs\MPI\Lib\x64"
set "MS_MPI_INC=C:\Program Files (x86)\Microsoft SDKs\MPI\Include"
:: paths to related shared libraries
set "INTEL_REDIST=C:\Program Files (x86)\Intel\oneAPI\compiler\2024.0\bin"

::you can preset PATHS, then they are not searched ...
::set "AUXONE= "
::set "AUXTWO= "
::set "MKL_LIB_DIR= "
::set "MKL_OPENMP_DIR= "
::set "MS_MPI_DIR= "
::set "MS_MPI_INC= "
::set "INTEL_REDIST= "

:: try to set paths automatically ...
CALL SET_PATHS.bat
if not %ERRORS%==0 goto EOF
For /f "tokens=*" %%p in ('more addpath.txt') do set "PATH=%PATH%%%p"
echo PATH is set to ... %PATH%
For /f "tokens=*" %%e in ('more variables.txt') do set %%e
::echo %AUXTWO%

:: sauberen Ausgangszustand herstellen ...
set ALL_TYPE=SER
del "log.txt" /q

:START_PAR_BUILD

::echo checkpoint1: %ALL_TYPE%

:: Build composition Serial
IF %ALL_TYPE%==SER (
set MUMPS_TYPE=SEQ
set PARDISO_TYPE=SEQ
set METIS_TYPE=SEQ
set BLAS_LAPACK_TYPE=SEQ
set "HYPRE_TYPE="
)

::echo checkpoint2: %ALL_TYPE%

:: CAUTION: if names are not unique, dll are overwritten!
:: Build composition Parallel
IF %ALL_TYPE%==PAR (
set "METIS_TYPE="
set "BLAS_LAPACK_TYPE="
set HYPRE_TYPE=MPI
set PARDISO_TYPE=OPENMP
set MUMPS_TYPE=MPI
)
echo.
echo selected composition: %ALL_TYPE%
echo.
echo BLAS_LAPACK_TYPE ... %BLAS_LAPACK_TYPE%
echo PARDISO_TYPE ... %PARDISO_TYPE%
echo HYPRE_TYPE ... %HYPRE_TYPE%
echo METIS_TYPE ... %METIS_TYPE%
echo MUMPS_TYPE ... %MUMPS_TYPE%

::echo checkpoint3: %ALL_TYPE%

:: run at Jenkins-native
if %BUILD_SPEED%==SLOW (
CALL blas_lapack-config\vsgen-blas_lapack.bat
CALL pardiso-config\vsgen-pardiso.bat
CALL hypre-config\vsgen-hypre.bat
CALL metis-seq-config\vsgen-metis-seq.bat
CALL dmumps-config\MUMPS_build_libs.bat
)

if %BUILD_SPEED%==FAST (
start "Blas LAPACK" cmd /C "CALL blas_lapack-config\vsgen-blas_lapack.bat >log_0.txt" 
start "PARDISO" cmd /C "CALL pardiso-config\vsgen-pardiso.bat >log_1.txt" 
start "HYPRE" cmd /C "CALL hypre-config\vsgen-hypre.bat >log_2.txt" 
start "METIS" cmd /C "CALL metis-seq-config\vsgen-metis-seq.bat >log_3.txt"
start "MUMPS" cmd /C "CALL dmumps-config\MUMPS_build_libs.bat >log_4.txt" 
)| pause

::unify logtexts
(
echo this is output log of %ALL_TYPE%-build ...
echo started at %date% %time%
echo .
) >>log.txt
for /L %%I in (0,1,4) do (
type log_%%I.txt>>log.txt
del "log_%%I.txt" /q
)

if %BUILD_SPEED%==FAST (
:: choosing fast build the paths defined in batch-Files are lost and have to be set
SET "BLAS_LAPACK_BUILD=%WORKINGDIR%\BLAS_LAPACK"
SET "PARDISO_BUILD=%WORKINGDIR%\PARDISO"
SET "HYPRE_BUILD=%WORKINGDIR%\hypre-2.11.2\src\cmbuild"
SET "METIS_BUILD=%WORKINGDIR%\metis-5.1.0\build\windows"
SET "MUMPS_BUILD=%WORKINGDIR%\MUMPS-VS"
)

:: copy files to build directory
IF NOT EXIST "%WORKINGDIR%\BUILDS" mkdir "%WORKINGDIR%\BUILDS"
set "DESTDIR=%WORKINGDIR%\BUILDS"
set "PLATFORM=x64"
set "CONFIG=Release"
set BLAS_LAPACK_STATUS=unknown
set PARDISO_STATUS=unknown
set HYPRE_STATUS=unknown
set METIS_STATUS=unknown
set MUMPS_STATUS=unknown

::set dll names properly
set "MUMPS_DLL_NAME="
if %MUMPS_TYPE%==SEQ set "MUMPS_DLL_NAME=dmumps-seq.dll"
if %MUMPS_TYPE%==OPENMP set "MUMPS_DLL_NAME=dmumps-openmp.dll"
if %MUMPS_TYPE%==MPI set "MUMPS_DLL_NAME=dmumps-mpi.dll"
if %MUMPS_TYPE%==HYBRID set "MUMPS_DLL_NAME=dmumps-hybrid.dll"

::gather and check DLLs
if not defined BLAS_LAPACK_TYPE GOTO PARDISOCHECK
copy "%BLAS_LAPACK_BUILD%\%PLATFORM%\%CONFIG%\BLAS_LAPACK.dll" "%DESTDIR%\" /y
if %errorlevel%==0 set BLAS_LAPACK_STATUS=success
if not %errorlevel%==0 (
set BLAS_LAPACK_STATUS=failure
set /a ERRORS=%ERRORS%+1
)
:PARDISOCHECK
if not defined PARDISO_TYPE GOTO HYPRECHECK
copy "%PARDISO_BUILD%\%PLATFORM%\%CONFIG%\PARDISO*.dll" "%DESTDIR%\" /y
if %errorlevel%==0 set PARDISO_STATUS=success
if not %errorlevel%==0 (
set PARDISO_STATUS=failure
set /a ERRORS=%ERRORS%+1
)
:HYPRECHECK
if not defined HYPRE_TYPE GOTO METISCHECK
copy "%HYPRE_BUILD%\%CONFIG%\HYPRE.dll" "%DESTDIR%\" /y
if %errorlevel%==0 set HYPRE_STATUS=success
if not %errorlevel%==0 (
set HYPRE_STATUS=failure
set /a ERRORS=%ERRORS%+1
)
:METISCHECK
if not defined METIS_TYPE GOTO MUMPSCHECK
copy "%METIS_BUILD%\libmetis\%CONFIG%\metis.dll" "%DESTDIR%\" /y
if %errorlevel%==0 set METIS_STATUS=success
if not %errorlevel%==0 (
set METIS_STATUS=failure
set /a ERRORS=%ERRORS%+1
)
:MUMPSCHECK
if not defined MUMPS_TYPE GOTO EOFCHECKS
copy "%MUMPS_BUILD%\%PLATFORM%\%CONFIG%\%MUMPS_DLL_NAME%" "%DESTDIR%\" /y
if %errorlevel%==0 set MUMPS_STATUS=success
if not %errorlevel%==0 (
set MUMPS_STATUS=failure
set /a ERRORS=%ERRORS%+1
)
:EOFCHECKS
ECHO.
ECHO BLAS AND LAPACK ... %BLAS_LAPACK_STATUS%
ECHO PARDISO ... %PARDISO_STATUS%
ECHO HYPRE ... %HYPRE_STATUS%
ECHO METIS ... %METIS_STATUS%
ECHO MUMPS ... %MUMPS_STATUS%
ECHO Total failures ... %ERRORS%

:: create changelog
IF %ALL_TYPE%==SER (
ECHO === CHANGELOG === >>changelog.txt
)
(
ECHO build finished at %date% %time%
ECHO %ALL_TYPE%-build configuration
echo.
echo BLAS_LAPACK_TYPE ... %BLAS_LAPACK_TYPE%
echo PARDISO_TYPE ... %PARDISO_TYPE%
echo HYPRE_TYPE ... %HYPRE_TYPE%
echo METIS_TYPE ... %METIS_TYPE%
echo MUMPS_TYPE ... %MUMPS_TYPE%
echo.
ECHO %ALL_TYPE%-build status
ECHO BLAS AND LAPACK ... %BLAS_LAPACK_STATUS%
ECHO PARDISO ... %PARDISO_STATUS%
ECHO HYPRE ... %HYPRE_STATUS%
ECHO METIS ... %METIS_STATUS%
ECHO MUMPS ... %MUMPS_STATUS%
ECHO.
)>>changelog.txt


:: switch to parallel ans start over (goto-loop)
IF %ALL_TYPE%==SER (
set ALL_TYPE=PAR
GOTO START_PAR_BUILD
)

:: get finished: add linked libraries
:: MUMPS ...
copy ".\WinDlls\*.dll" "%DESTDIR%\" /y
copy "%INTEL_REDIST%\libiomp5md.dll" "%DESTDIR%\" /y
copy "%INTEL_REDIST%\LIBIFCOREMD.DLL" "%DESTDIR%\" /y
copy "%INTEL_REDIST%\LIBMMD.DLL" "%DESTDIR%\" /y
copy "%INTEL_REDIST%\SVML_DISPMD.DLL" "%DESTDIR%\" /y

:: and list these libraries in changelog
(
ECHO DLL bundle is containing: 
echo.
dir "%DESTDIR%" /b 
)>>changelog.txt
move /y "C:\BoSSS-native\changelog.txt" "C:\BoSSS-native\BUILDS\"

:EOF
EXIT %ERRORS%