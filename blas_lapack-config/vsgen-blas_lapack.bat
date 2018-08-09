@echo off

ECHO ^>^>^>^>^>^>BLAS and LAPACK BUILD^>^>^>^>^>^>
ECHO =======================
ECHO.

::check if all necessary variables are set
set "ErrorInput="
IF NOT DEFINED WORKINGDIR set ErrorInput=1
IF NOT DEFINED BLAS_LAPACK_TYPE set ErrorInput=1
::IF NOT DEFINED MS_MPI set ErrorInput=1
IF DEFINED ErrorInput (
ECHO some variables are not set. please set:
ECHO WORKINGDIR[path], BLAS_LAPACK_TYPE[SEQ]
GOTO EOF
)
::Define all pending directories
SET BLAS_LAPACK_CONFIG=%WORKINGDIR%\blas_lapack-config
SET BLAS_LAPACK_BUILD=%WORKINGDIR%\BLAS_LAPACK

ECHO ======================
ECHO clean BLAS and LAPACK
ECHO ======================

cd %BLAS_LAPACK_BUILD%
rmdir x64 /s /q

ECHO ======================
ECHO build BLAS and LAPACK %BLAS_LAPACK_TYPE%-Type
ECHO ======================

for %%i in (*.sln) do set SLN_NAME=%%~ni
SET PLATFORM=x64
SET CONFIG=Release

IF %BLAS_LAPACK_TYPE%==SEQ (
CALL msbuild /property:Configuration=%CONFIG% /property:Platform=%PLATFORM% /property:SolutionName=%SLN_NAME% BLAS_LAPACK-seq.vcxproj
)

::check if build was successful
CD %BLAS_LAPACK_BUILD%\%PLATFORM%\%CONFIG%

set "CHECK="
IF EXIST BLAS_LAPACK.dll SET CHECK=1
IF DEFINED CHECK (
ECHO Build successful
) ELSE (
ECHO Build failed
IF DEFINED ERRORS set /a ERRORS=%ERRORS%+1
)

:EOF
CD %WORKINGDIR%
ECHO building BLAS and LAPACK finished, returning to working directory ...
ECHO =======================
ECHO ^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>