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
set ERRORS=1
GOTO EOF
)
IF NOT DEFINED BUILD_SPEED set BUILD_SPEED=SLOW
ECHO DLL BUILD PROCESS STARTED ...
ECHO.
ECHO WORKINGDIR = %WORKINGDIR%
ECHO.

::set BLAS_LAPACK_STATUS=unknown
set PARDISO_STATUS=unknown
set HYPRE_STATUS=unknown
set METIS_STATUS=unknown
set MUMPS_SEQ_STATUS=unknown
set MUMPS_MPI_STATUS=unknown

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
set "MS_MPI_DIR=C:\Program Files (x86)\Microsoft SDKs\MPI\Lib\x64"
set "MS_MPI_INC=C:\Program Files (x86)\Microsoft SDKs\MPI\Include"
:: paths to related shared libraries
set "INTEL_REDIST=C:\Program Files (x86)\Intel\oneAPI\compiler\2024.0\bin"

:: copy files to build directory
IF NOT EXIST "%WORKINGDIR%\BUILDS" mkdir "%WORKINGDIR%\BUILDS"
set "DESTDIR=%WORKINGDIR%\BUILDS"
set "PLATFORM=x64"
set "CONFIG=Release"

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

:: Contains SEQ and OpenMP build
CALL pardiso-config\vsgen-pardiso.bat 

copy "PARDISO\%PLATFORM%\%CONFIG%\PARDISO*.dll" "%DESTDIR%\" /y
copy "PARDISO\%PLATFORM%\%CONFIG%\libfakeintel.dll" "%DESTDIR%\" /y
if %errorlevel%==0 set PARDISO_STATUS=success
if not %errorlevel%==0 (
set PARDISO_STATUS=failure
set /a ERRORS=%ERRORS%+1
)

:: Contains only MPI build
CALL hypre-config\vsgen-hypre.bat

copy "%HYPRE_BUILD%\%CONFIG%\HYPRE.dll" "%DESTDIR%\" /y
if %errorlevel%==0 set HYPRE_STATUS=success
if not %errorlevel%==0 (
set HYPRE_STATUS=failure
set /a ERRORS=%ERRORS%+1
)

:: Contains only SEQ build
CALL metis-seq-config\vsgen-metis-seq.bat

copy "%METIS_BUILD%\libmetis\%CONFIG%\metis.dll" "%DESTDIR%\" /y
if %errorlevel%==0 set METIS_STATUS=success
if not %errorlevel%==0 (
set METIS_STATUS=failure
set /a ERRORS=%ERRORS%+1
)

:: Build MUMPS in SEQ
set MUMPS_TYPE=SEQ
CALL dmumps-config\MUMPS_build_libs.bat

copy "%MUMPS_BUILD%\%PLATFORM%\%CONFIG%\dmumps-seq.dll" "%DESTDIR%\" /y
if %errorlevel%==0 set MUMPS_SEQ_STATUS=success
if not %errorlevel%==0 (
set MUMPS_STATUS=failure
set /a ERRORS=%ERRORS%+1
)

:: Build MUMPS in MPI
set MUMPS_TYPE=MPI
CALL dmumps-config\MUMPS_build_libs.bat

copy "%MUMPS_BUILD%\%PLATFORM%\%CONFIG%\dmumps-mpi.dll" "%DESTDIR%\" /y
if %errorlevel%==0 set MUMPS_MPI_STATUS=success
if not %errorlevel%==0 (
set MUMPS_STATUS=failure
set /a ERRORS=%ERRORS%+1
)




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

:EOFCHECKS
ECHO.
::ECHO BLAS AND LAPACK ... %BLAS_LAPACK_STATUS%
ECHO PARDISO ... %PARDISO_STATUS%
ECHO HYPRE ... %HYPRE_STATUS%
ECHO METIS ... %METIS_STATUS%
ECHO MUMPS ... %MUMPS_STATUS%
ECHO Total failures ... %ERRORS%

ECHO %ALL_TYPE%-build status
ECHO PARDISO ... %PARDISO_STATUS%
ECHO HYPRE ... %HYPRE_STATUS%
ECHO METIS ... %METIS_STATUS%
ECHO MUMPS_SEQ ... %MUMPS_SEQ_STATUS%
ECHO MUMPS_MPI ... %MUMPS_MPI_STATUS%

:: get finished: add linked libraries
:: MUMPS ...
copy ".\WinDlls\*.dll" "%DESTDIR%\" /y
copy "%DESTDIR%\PARDISO_omp.dll" "%DESTDIR%\PARDISO2_omp.dll" /y
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