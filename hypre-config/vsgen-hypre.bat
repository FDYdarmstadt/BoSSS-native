::@echo off
echo

ECHO ^>^>^>^>^>^>HYPRE BUILD^>^>^>^>^>^>
ECHO =======================
ECHO.

set HYPRE_TYPE=MPI

ECHO WORKINGDIR is %WORKINGDIR%
ECHO HYPRE_TYPE is %HYPRE_TYPE%

::check if all necessary variables are set
set "ErrorInput="
IF NOT DEFINED WORKINGDIR set ErrorInput=1
IF NOT DEFINED HYPRE_TYPE set ErrorInput=1
::IF NOT DEFINED MS_MPI set ErrorInput=1
IF DEFINED ErrorInput (
ECHO some variables are not set. please set:
ECHO WORKINGDIR[path], HYPRE_TYPE[MPI]
GOTO EOF
)
::Define all pending directories
SET "HYPRE_CONFIG=%WORKINGDIR%\hypre-config"
SET "HYPRE_THIRDPARTY=%WORKINGDIR%\hypre-2.11.2"
SET "HYPRE_BUILD=%WORKINGDIR%\hypre-2.11.2\src\cmbuild"

ECHO ======================
ECHO clean HYPRE
ECHO ======================

cd %HYPRE_BUILD%
CALL msbuild HYPRE-MPI.proj /target:Clean
rmdir x64 /s /q
rmdir "HYPRE.dir" /s /q
rmdir Release /s /q

echo done.

ECHO ======================
ECHO build HYPRE %HYPRE_TYPE%-Type
ECHO ======================

for %%i in (*.sln) do set SLN_NAME=%%~ni
SET PLATFORM=x64
SET CONFIG=Release

IF %HYPRE_TYPE%==MPI (
CALL msbuild /property:Configuration=%CONFIG% /property:Platform=%PLATFORM% /property:SolutionName=%SLN_NAME% HYPRE-MPI.vcxproj 
)

::check if build was successful
CD "%HYPRE_BUILD%\%CONFIG%"

set "CHECK="
IF EXIST HYPRE.dll SET CHECK=1
IF DEFINED CHECK (
ECHO Build successful
) ELSE (
ECHO Build failed
)

:EOF
CD "%WORKINGDIR%"
ECHO building HYPRE finished, returning to working directory ...
ECHO =======================
ECHO ^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>