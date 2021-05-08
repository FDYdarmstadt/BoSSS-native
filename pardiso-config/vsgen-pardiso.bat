@echo off

ECHO ^>^>^>^>^>^>PARDISO BUILD^>^>^>^>^>^>
ECHO =======================
ECHO.

::echo checkpoint4: %PARDISO_TYPE%

::check if all necessary variables are set
set "ErrorInput="
IF NOT DEFINED WORKINGDIR set ErrorInput=1
IF NOT DEFINED PARDISO_TYPE set ErrorInput=1
::IF NOT DEFINED MS_MPI set ErrorInput=1
IF DEFINED ErrorInput (
ECHO some variables are not set. please set:
ECHO WORKINGDIR[path], PARDISO_TYPE[SEQ/OPENMP/HYBRID]
GOTO EOF
)
::Define all pending directories
SET "PARDISO_CONFIG=%WORKINGDIR%\pardiso-config"
SET "PARDISO_BUILD=%WORKINGDIR%\PARDISO"

ECHO ======================
ECHO clean PARDISO
ECHO ======================

cd %PARDISO_BUILD%
::devenv PARDISO.sln /Clean

rmdir x64 /s /q
ECHO ======================
ECHO build PARDISO %PARDISO_TYPE%-Type
ECHO ======================

for %%i in (*.sln) do set SLN_NAME=%%~ni
SET PLATFORM=x64
SET CONFIG=Release

::echo checkpoint5: %PARDISO_TYPE%

::devenv PARDISO-seq.vcxproj /Build "Release|x64"
::devenv PARDISO-openMP.vcxproj /Build "Release|x64"
set "DLL="
IF %PARDISO_TYPE%==SEQ (
CALL msbuild /property:Configuration=%CONFIG% /property:Platform=%PLATFORM% /property:SolutionName=%SLN_NAME% PARDISO-seq.vcxproj
set DLL=PARDISO_seq.dll
)
IF %PARDISO_TYPE%==OPENMP (
CALL msbuild /property:Configuration=%CONFIG% /property:Platform=%PLATFORM% /property:SolutionName=%SLN_NAME% PARDISO-openMP.vcxproj
set DLL=PARDISO_omp.dll
)
::check if build was successful

CD "%PARDISO_BUILD%\%PLATFORM%\%CONFIG%"

set "CHECK="
IF EXIST %DLL% SET CHECK=1
IF DEFINED CHECK (
ECHO Build successful
) ELSE (
ECHO Build failed
)

:EOF
CD %WORKINGDIR%
ECHO building PARDISO finished, returning to working directory ...
ECHO =======================
ECHO ^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>