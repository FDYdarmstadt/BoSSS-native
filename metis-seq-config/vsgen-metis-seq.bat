@echo off

ECHO ^>^>^>^>^>^>METIS BUILD^>^>^>^>^>^>
ECHO =======================
ECHO.

SET METIS_TYPE=SEQ

::check if all necessary variables are set
set "ErrorInput="
IF NOT DEFINED WORKINGDIR set ErrorInput=1
IF NOT DEFINED METIS_TYPE set ErrorInput=1
::IF NOT DEFINED MS_MPI set ErrorInput=1
IF DEFINED ErrorInput (
ECHO some variables are not set. please set:
ECHO WORKINGDIR[path], MUMPS_TYPE[SEQ/OPENMP/HYBRID]
GOTO EOF
)
::Define all pending directories
SET METIS_THIRDPARTY=%WORKINGDIR%\metis-5.1.0
SET METIS_CONFIG=%WORKINGDIR%\metis-seq-config
SET METIS_BUILD=%METIS_THIRDPARTY%\build\windows

ECHO =======================
ECHO clean METIS
ECHO =======================
::cd %METIS_BUILD%\..\
::rmdir windows /s /q
::MKDIR windows
IF exist %METIS_BUILD% del /q "%METIS_BUILD%\*"
MKDIR %METIS_BUILD%

ECHO =======================
ECHO build METIS %METIS_TYPE%-Type
ECHO =======================

CD %METIS_CONFIG%
xcopy /y gk_arch.h "%METIS_THIRDPARTY%\GKlib\"
CD %METIS_BUILD%

SET PLATFORM=x64
SET CONFIG=Release

IF %METIS_TYPE%==SEQ (

CALL cmake -DCMAKE_CONFIGURATION_TYPES="%CONFIG%" ..\.. -G "Visual Studio 15 2017 Win64" -DSHARED=1
:: cmake -DCMAKE_CONFIGURATION_TYPES="Release" ..\.. -G "Visual Studio 15 2017 Win64" -DSHARED=1 -DCMAKE_C_COMPILER=cl
ECHO VS files have been generated in %METIS_BUILD%
::devenv METIS.sln /Clean
::devenv ALL_BUILD.vcxproj /Build "Release|x64"
for %%i in (*.sln) do set SLN_NAME=%%~ni
CALL msbuild /property:Configuration=%CONFIG% /property:Platform=%PLATFORM% /property:SolutionName=%SLN_NAME% ALL_BUILD.vcxproj
) ELSE (
ECHO YOU ARE NOT SUPPOSED TO DO THAT
)

:: check if build was successful
CD %METIS_BUILD%\libmetis\Release
set "CHECK="
IF EXIST metis.dll SET CHECK=1
IF DEFINED CHECK (
ECHO Build successful
) ELSE (
ECHO Build failed
IF DEFINED ERRORS set /a ERRORS=%ERRORS%+1
)

:EOF
CD %WORKINGDIR%
ECHO building METIS finished, returning to working directory ...
ECHO =======================
ECHO ^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>

