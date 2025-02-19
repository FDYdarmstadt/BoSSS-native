@echo off
setlocal EnableDelayedExpansion

set ERRORS=0

Echo Searching for executable, inculde and library directories ...
echo.
set "Intel_Version=2024.0"
set "Executables=cmake make msbuild ifort link"	

for /F %%E in ("%Executables%") do set "path_%%E="

for /F "tokens=*" %%I IN ('dir /s /b "C:\Program Files\Microsoft Visual Studio\2022\" ^| find /i "bin\cmake.exe" ^| find /i /v ".config"') do (
set "a=%%~fI"
set "path_cmake=!a:\cmake.exe=!"
)

for /F "tokens=*" %%I IN ('dir /s /b "c:\Program Files\Microsoft Visual Studio\2022\" ^| find /i "Hostx64\x64\link.exe" ^| find /i /v ".config"') do (
set "a=%%~fI"
set "path_link=!a:\link.exe=!"
)


for /F "tokens=*" %%I IN ('dir /s /b "c:\Program Files\Microsoft Visual Studio\2022\" ^| find /i "Bin\MSBuild.exe" ^| find /i /v ".config"') do (
set "a=%%~fI"
set "path_msbuild=!a:\msbuild.exe=!"
)

for /F "tokens=*" %%I IN ('^(dir /s /b "c:\cygwin\" ^|^| dir /s /b "c:\cygwin64\" ^|^| dir /s /b "c:\Program Files (x86)\cygwin\" ^|^| dir /s /b "c:\Program Files (x86)\cygwin64\"^)^|find /i "bin\make.exe"') do (
set "a=%%~fI"
set "path_make=!a:\make.exe=!"
)

rem for /F "tokens=*" %%I IN ('dir /s /b "C:\Program Files (x86)\Intel\oneAPI\" ^| find /i "bin\ifort.exe" ^| find /i "%Intel_Version%" ^| find /i /v ".config"') do (
rem set "a=%%~fI"
rem set "path_ifort=!a:\ifort.exe=!"
rem )
set "path_ifort=C:\Program Files (x86)\Intel\oneAPI\compiler\2024.0\bin"


set "target=time.h"
if not defined AUXONE (
for /F "tokens=*" %%I IN ('dir /s /b "C:\Program Files (x86)\Windows Kits\10\" ^| find /i "\%target%"') do (
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
for /F "tokens=*" %%I IN ('dir /s /b "C:\Program Files\Microsoft Visual Studio\2022\" ^| find /i "\%target%"') do (
set "a=%%~fI"
set "AUXTWO=!a:\%target%=!"
)
if not defined AUXTWO (
echo path to !target! not found!
set /a ERRORS=%ERRORS%+1
) else (
echo !target! was found at AUXTWO=!AUXTWO!)
)

set "target=mkl.h"
rem if not defined MKL_INC_DIR (
rem for /F "tokens=*" %%I IN ('dir /s /b "C:\Program Files (x86)\Intel\oneAPI\" ^| find /i "\%target%" ^| find /i "%Intel_Version%"') do (
rem set "a=%%~fI"
rem set "MKL_INC_DIR=!a:\%target%=!"
rem )
set "MKL_INC_DIR=C:\Program Files (x86)\Intel\oneAPI\mkl\2024.0\include"
if not defined MKL_INC_DIR (
echo path to !target! not found!
set /a ERRORS=%ERRORS%+1
) else (
echo !target! was found at MKL_INC_DIR=!MKL_INC_DIR!)
)


set "target=mkl_core.lib"
rem if not defined MKL_LIB_DIR (
rem for /F "tokens=*" %%I IN ('dir /s /b "C:\Program Files (x86)\Intel\oneAPI\" ^| find /i "\%target%" ^| find /i "%Intel_Version%"') do (
rem set "a=%%~fI"
rem set "MKL_LIB_DIR=!a:\%target%=!"
rem )
set "MKL_LIB_DIR=C:\Program Files (x86)\Intel\oneAPI\mkl\2024.0\lib"
if not defined MKL_LIB_DIR (
echo path to !target! not found!
set /a ERRORS=%ERRORS%+1
) else (
echo !target! was found at MKL_LIB_DIR=!MKL_LIB_DIR!)
)

set "target=libiomp5md.lib"
rem if not defined MKL_OPENMP_DIR (
rem for /F "tokens=*" %%I IN (' dir /s /b "C:\Program Files (x86)\Intel\oneAPI\" ^| find /i  "lib" ^| find /i "\%target%" ^| find /i "%Intel_Version%"') do (
rem set "a=%%~fI"
rem set "MKL_OPENMP_DIR=!a:\%target%=!"
rem )
set "MKL_OPENMP_DIR=C:\Program Files (x86)\Intel\oneAPI\compiler\2024.0\lib"
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
rem if not defined INTEL_REDIST (
rem for /F "tokens=*" %%I IN ('^(dir /s /b "C:\Program Files\" ^| find /i "intel" ^| find /i "64" ^| find /i "\%target%"^) ^|^| ^(dir /s /b "C:\Program Files (x86)\" ^| find /i "intel" ^| find /i "64" ^| find /i "\%target%"^)') do (
rem set "a=%%~fI"
rem set "INTEL_REDIST=!a:\%target%=!"
rem )
if not defined INTEL_REDIST (
echo path to %target% not found!
set /a ERRORS=%ERRORS%+1
) else (
echo !target! was found at INTEL_REDIST=!INTEL_REDIST!)
)

::set "AddPath=%PATH%"
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

::set PATH=%AddPath%
if not %ERRORS%==0 echo %ERRORS% paths not found! Make sure you installed stuff at C:\Program Files or C:Program Files (x86), otherwise set the variables manually!
if not %ERRORS%==0 GOTO EOF

ECHO.
echo %AddPath% is written to file: addpath.txt
echo %AddPath% >addpath.txt
echo export variables to file: variables.txt

(
echo "AUXONE=%AUXONE%"
echo "AUXTWO=%AUXTWO%"
echo "MKL_INC_DIR=%MKL_INC_DIR%"
echo "MKL_LIB_DIR=%MKL_LIB_DIR%"
echo "MKL_OPENMP_DIR=%MKL_OPENMP_DIR%"
echo "MS_MPI_DIR=%MS_MPI_DIR%"
echo "MS_MPI_INC=%MS_MPI_INC%"
echo "INTEL_REDIST=%INTEL_REDIST%"
)>variables.txt

:: set paths in .property file (necessary for the VS builds)
del /q "PropertySheet.props"
for /L %%i in (0,1,%x%) do (
	for /f "tokens=*" %%a in (PropertySheet_blank.props) do (
		SET s=%%a
		SET "s=!s:_MKL_INC_DIR=%MKL_INC_DIR%!"
		SET "s=!s:_MKL_LIB_DIR=%MKL_LIB_DIR%!"
		set "s=!s:_MKL_OPENMP_DIR=%MKL_OPENMP_DIR%!"
		set "s=!s:_MS_MPI_DIR=%MS_MPI_DIR%!"
		set "s=!s:_MS_MPI_INC=%MS_MPI_INC%!"
		set "s=!s:_WORKINGDIR=%WORKINGDIR%!"
		echo !s!>>"PropertySheet.props"
	)
)
echo.
If %ERRORS%==0 echo PropertySheet.props was created successfully...
echo.
:EOF