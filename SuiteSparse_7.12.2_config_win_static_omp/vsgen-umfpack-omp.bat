@echo off

ECHO ^>^>^>^>^>^>UMFPACK BUILD^>^>^>^>^>^>
ECHO =======================
ECHO.


::check if all necessary variables are set
set "ErrorInput="
IF NOT DEFINED WORKINGDIR set ErrorInput=1
IF DEFINED ErrorInput (
ECHO some variables are not set. please set:
ECHO WORKINGDIR=%WORKINGDIR% [expecting path]
GOTO EOF
)


SET PLATFORM=x64
SET CONFIG=Release

CD SuiteSparse_7.12.2_config_win_static_omp
MSBuild .\UMFPACK\UMFPACK.sln /p:Configuration=%CONFIG% /p:Platform=%PLATFORM%

:: check if build was successful
CD "UMFPACK\Release"
set "CHECK="
IF EXIST umfpack_static.dll SET CHECK=1
IF DEFINED CHECK (
ECHO Build successful
) ELSE (
ECHO Build failed
)

:EOF
CD "%WORKINGDIR%"
ECHO building UMFPACK finished, returning to working directory ...
ECHO =======================
ECHO ^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>
