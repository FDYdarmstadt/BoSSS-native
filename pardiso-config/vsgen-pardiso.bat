@echo off

ECHO ^>^>^>^>^>^>BoSSSnative BUILD^>^>^>^>^>^>
ECHO =======================
ECHO.

::echo checkpoint4: %PARDISO_TYPE%

::check if all necessary variables are set
set "ErrorInput="
IF NOT DEFINED WORKINGDIR set ErrorInput=1
::IF NOT DEFINED MS_MPI set ErrorInput=1
IF DEFINED ErrorInput (
ECHO some variables are not set. please set:
ECHO WORKINGDIR[path]
GOTO EOF
)
::Define all pending directories
SET "PARDISO_CONFIG=%WORKINGDIR%\pardiso-config"
SET "PARDISO_BUILD=%WORKINGDIR%\BoSSSnative_win"

ECHO ======================
ECHO clean BoSSSnative_win
ECHO ======================

cd %PARDISO_BUILD%
::devenv PARDISO.sln /Clean

rmdir x64 /s /q
ECHO ======================
ECHO build BoSSSnative 
ECHO ======================

for %%i in (*.sln) do set SLN_NAME=%%~ni
SET PLATFORM=x64
SET CONFIG=Release

::echo checkpoint5: %PARDISO_TYPE%

::devenv BoSSSnative_seq.vcxproj /Build "Release|x64"
::devenv BoSSSnative_omp.vcxproj /Build "Release|x64"
set "DLL="
::IF %PARDISO_TYPE%==SEQ (
CALL msbuild /property:Configuration=%CONFIG% /property:Platform=%PLATFORM% /property:SolutionName=%SLN_NAME% libfakeintel.vcxproj
CALL msbuild /property:Configuration=%CONFIG% /property:Platform=%PLATFORM% /property:SolutionName=%SLN_NAME% BoSSSnative_seq.vcxproj
CALL msbuild /property:Configuration=%CONFIG% /property:Platform=%PLATFORM% /property:SolutionName=%SLN_NAME% BoSSSnative_omp.vcxproj


::check if build was successful
CD "%PARDISO_BUILD%\%PLATFORM%\%CONFIG%"
set "CHECK="
set "FAILCHECK="
IF NOT EXIST libfakeintel.dll SET FAILCHECK=1
IF NOT EXIST BoSSSnative_seq.dll SET FAILCHECK=1
IF NOT EXIST BoSSSnative_omp.dll SET FAILCHECK=1
IF NOT DEFINED FAILCHECK (
ECHO Build successful
  set CHECK=1
) ELSE (
ECHO Build failed
)

:EOF
CD %WORKINGDIR%
ECHO building BoSSSnative finished, returning to working directory ...
ECHO =======================
ECHO ^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>