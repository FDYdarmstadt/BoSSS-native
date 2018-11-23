@echo off
setlocal EnableDelayedExpansion

::counter of total errors
set ERRORS=0
::check if all necessary variables are set
set "ErrorInput="
IF NOT DEFINED WORKINGDIR set ErrorInput=1
IF NOT DEFINED ALL_TYPE set ErrorInput=1
::ERROR ... EXECUTION IS ABORTED
IF DEFINED ErrorInput (
ECHO some variables are not set. please set:
ECHO WORKINGDIR[...], ALL_TYPE[SER/PAR]
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
::set "MS_MPI_DIR=C:\Program Files\Microsoft MPI\Lib\amd64"
::set "MS_MPI_INC=C:\Program Files\Microsoft MPI\Inc"
:: paths to related shared libraries
::set "INTEL_REDIST=%PROGRAMFILES(x86)%\Common Files\Intel\Shared Libraries\redist\intel64_win\compiler"

:: preset variables for auto filling
::set "AUXONE= "
::set "AUXTWO= "
::set "MKL_LIB_DIR= "
::set "MKL_OPENMP_DIR= "
::set "MS_MPI_DIR= "
::set "MS_MPI_INC= "
::set "INTEL_REDIST= "

:: try to set paths automatically ...
Echo Searching for executable, inculde and library directories ...

set "Intel_Version=2018.3.210"
set "Executables=cmake make msbuild ifort link"	

for /F %%E in ("%Executables%") do set "path_%%E="

for /F "tokens=*" %%I IN ('dir /s /b "c:\Program Files (x86)\Microsoft Visual Studio\" ^| find /i "bin\cmake.exe" ^| find /i /v ".config"') do (
set "a=%%~fI"
set "path_cmake=!a:\cmake.exe=!"
)

for /F "tokens=*" %%I IN ('dir /s /b "c:\Program Files (x86)\Microsoft Visual Studio\" ^| find /i "Hostx64\x64\link.exe" ^| find /i /v ".config"') do (
set "a=%%~fI"
set "path_link=!a:\link.exe=!"
)

for /F "tokens=*" %%I IN ('dir /s /b "c:\Program Files (x86)\Microsoft Visual Studio\" ^| find /i "Bin\MSBuild.exe" ^| find /i /v ".config"') do (
set "a=%%~fI"
set "path_msbuild=!a:\msbuild.exe=!"
)

for /F "tokens=*" %%I IN ('^(dir /s /b "c:\cygwin\" ^|^| dir /s /b "c:\cygwin64\" ^|^| dir /s /b "c:\Program Files (x86)\cygwin\" ^|^| dir /s /b "c:\Program Files (x86)\cygwin64\"^)^|find /i "bin\make.exe"') do (
set "a=%%~fI"
set "path_make=!a:\make.exe=!"
)

for /F "tokens=*" %%I IN ('dir /s /b "C:\Program Files (x86)\IntelSWTools\" ^| find /i "windows\bin\intel64\ifort.exe" ^| find /i "%Intel_Version%" ^| find /i /v ".config"') do (
set "a=%%~fI"
set "path_ifort=!a:\ifort.exe=!"
)

set "target=time.h"
if not defined AUXONE (
for /F "tokens=*" %%I IN ('dir /s /b "C:\Program Files (x86)\Windows Kits\" ^| find /i "\%target%"') do (
set "a=%%~fI"
set "AUXONE=!a:\%target%=!"
)
if not defined AUXONE (
echo path to !target! not found!
set /a ERRORS=%ERRORS%+1
) else (
echo !target! was found at AUXONE=!AUXONE!)
)

set "target=vcruntime.h"
if not defined AUXTWO (
for /F "tokens=*" %%I IN ('dir /s /b "C:\Program Files (x86)\Microsoft Visual Studio\" ^| find /i "\%target%"') do (
set "a=%%~fI"
set "AUXTWO=!a:\%target%=!"
)
if not defined AUXTWO (
echo path to !target! not found!
set /a ERRORS=%ERRORS%+1
) else (
echo !target! was found at AUXTWO=!AUXTWO!)
)


set "target=mkl_core.lib"
if not defined MKL_LIB_DIR (
for /F "tokens=*" %%I IN ('dir /s /b "C:\Program Files (x86)\IntelSWTools\" ^| find /i  "windows" ^| find /i "64" ^| find /i "\%target%" ^| find /i "%Intel_Version%"') do (
set "a=%%~fI"
set "MKL_LIB_DIR=!a:\%target%=!"
)
if not defined MKL_LIB_DIR (
echo path to !target! not found!
set /a ERRORS=%ERRORS%+1
) else (
echo !target! was found at MKL_LIB_DIR=!MKL_LIB_DIR!)
)

set "target=libiomp5md.lib"
if not defined MKL_OPENMP_DIR (
for /F "tokens=*" %%I IN (' dir /s /b "C:\Program Files (x86)\IntelSWTools\" ^| find /i  "windows" ^| find /i "64" ^| find /i "\%target%" ^| find /i "%Intel_Version%"') do (
set "a=%%~fI"
set "MKL_OPENMP_DIR=!a:\%target%=!"
)
if not defined MKL_OPENMP_DIR (
echo path to !target! not found!
set /a ERRORS=%ERRORS%+1
) else (
echo !target! was found at MKL_OPENMP_DIR=!MKL_OPENMP_DIR!)
)

set "target=msmpi.lib"
if not defined MS_MPI_DIR (
for /F "tokens=*" %%I IN (' ^(dir /s /b "C:\Program Files\" ^| find /i "64" ^| find /i "mpi" ^| find /i "\%target%"^) ^|^| ^(dir /s /b "C:\Program Files (x86)\" ^| find /i "64" ^| find /i "mpi" ^| find /i "\%target%"^)') do (
set "a=%%~fI"
set "MS_MPI_DIR=!a:\%target%=!"
)
if not defined MS_MPI_DIR (
echo path to !target! not found!
set /a ERRORS=%ERRORS%+1
) else (
echo !target! was found at MS_MPI_DIR=!MS_MPI_DIR!)
)

set "target=mpi.h"
if not defined MS_MPI_INC (
for /F "tokens=*" %%I IN ('^(dir /s /b "C:\Program Files\" ^| find /i "mpi" ^| find /i "\%target%"^) ^|^| ^(dir /s /b "C:\Program Files (x86)\" ^| find /i "mpi" ^| find /i "\%target%"^)') do (
set "a=%%~fI"
set "MS_MPI_INC=!a:\%target%=!"
)
if not defined MS_MPI_INC (
echo path to !target! not found!
set /a ERRORS=%ERRORS%+1
) else (
echo !target! was found at MS_MPI_INC=!MS_MPI_INC!)
)

set "target=libmmd.dll"
if not defined INTEL_REDIST (
for /F "tokens=*" %%I IN ('^(dir /s /b "C:\Program Files\" ^| find /i "intel" ^| find /i "64" ^| find /i "\%target%"^) ^|^| ^(dir /s /b "C:\Program Files (x86)\" ^| find /i "intel" ^| find /i "64" ^| find /i "\%target%"^)') do (
set "a=%%~fI"
set "INTEL_REDIST=!a:\%target%=!"
)
if not defined INTEL_REDIST (
echo path to %target% not found!
set /a ERRORS=%ERRORS%+1
) else (
echo !target! was found at INTEL_REDIST=!INTEL_REDIST!)
)

set "AddPath=%PATH%"
ECHO.
for %%E in (%Executables%) do (
if not defined path_%%~nE (
echo path to %%~nE.exe not found!
set /a ERRORS=%ERRORS%+1
) else (
echo path to %%~nE.exe is set to !path_%%~nE!
)
set "AddPath=!AddPath!!path_%%~nE!;"
)

set PATH=%AddPath%
if not %ERRORS%==0 echo %ERRORS% paths not found! Make sure you installed stuff at C:\Program Files or C:Program Files (x86). Otherwise set the variables manually!
:: After this error counter will indicate how many builds have failed
IF NOT %ERRORS%==0 GOTO EOF

ECHO.
Echo modified PATH=%PATH%

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
set MUMPS_TYPE=MPI
set PARDISO_TYPE=OPENMP
set METIS_TYPE=SEQ
set BLAS_LAPACK_TYPE=SEQ
set HYPRE_TYPE=MPI
)
echo.
echo slected composition: %ALL_TYPE%
echo.
echo BLAS_LAPACK_TYPE ... %BLAS_LAPACK_TYPE%
echo PARDISO_TYPE ... %PARDISO_TYPE%
echo HYPRE_TYPE ... %HYPRE_TYPE%
echo METIS_TYPE ... %METIS_TYPE%
echo MUMPS_TYPE ... %MUMPS_TYPE%

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

del "log.txt" /q
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
mkdir "%WORKINGDIR%\BUILDS"
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
copy "%BLAS_LAPACK_BUILD%\%PLATFORM%\%CONFIG%\BLAS_LAPACK.dll" "%DESTDIR%\" /y
if %errorlevel%==0 set BLAS_LAPACK_STATUS=success
if not %errorlevel%==0 (
set BLAS_LAPACK_STATUS=failure
set /a ERRORS=%ERRORS%+1
)
copy "%PARDISO_BUILD%\%PLATFORM%\%CONFIG%\PARDISO.dll" "%DESTDIR%\" /y
if %errorlevel%==0 set PARDISO_STATUS=success
if not %errorlevel%==0 (
set PARDISO_STATUS=failure
set /a ERRORS=%ERRORS%+1
)
copy "%HYPRE_BUILD%\%CONFIG%\HYPRE.dll" "%DESTDIR%\" /y
if %errorlevel%==0 set HYPRE_STATUS=success
if not %errorlevel%==0 (
set HYPRE_STATUS=failure
set /a ERRORS=%ERRORS%+1
)
copy "%METIS_BUILD%\libmetis\%CONFIG%\metis.dll" "%DESTDIR%\" /y
if %errorlevel%==0 set METIS_STATUS=success
if not %errorlevel%==0 (
set METIS_STATUS=failure
set /a ERRORS=%ERRORS%+1
)
copy "%MUMPS_BUILD%\%PLATFORM%\%CONFIG%\%MUMPS_DLL_NAME%" "%DESTDIR%\" /y
if %errorlevel%==0 set MUMPS_STATUS=success
if not %errorlevel%==0 (
set MUMPS_STATUS=failure
set /a ERRORS=%ERRORS%+1
)

ECHO.
ECHO BLAS AND LAPACK ... %BLAS_LAPACK_STATUS%
ECHO PARDISO ... %PARDISO_STATUS%
ECHO HYPRE ... %HYPRE_STATUS%
ECHO METIS ... %METIS_STATUS%
ECHO MUMPS ... %MUMPS_STATUS%
ECHO Total failures ... %ERRORS%

:: add linked libraries
:: MUMPS ...
copy "%INTEL_REDIST%\LIBIFCOREMD.DLL" "%DESTDIR%\" /y
copy "%INTEL_REDIST%\LIBMMD.DLL" "%DESTDIR%\" /y
copy "%INTEL_REDIST%\SVML_DISPMD.DLL" "%DESTDIR%\" /y

::del /q PropertySheet.props
:EOF
::EXIT %ERRORS%