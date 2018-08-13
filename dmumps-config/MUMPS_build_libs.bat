@echo off

ECHO ^>^>^>^>^>^>MUMPS BUILD^>^>^>^>^>^>
ECHO ========================
ECHO.
::variables, which have to be set first: WORKINGDIR[path], MUMPS_TYPE[SEQ/OPENMP/HYBRID], MS_MPI[path], PRECISION[d/s]

::check if all necessary variables are set
set "ErrorInput="
IF NOT DEFINED WORKINGDIR set ErrorInput=1
IF NOT DEFINED MUMPS_TYPE set ErrorInput=1
::IF NOT DEFINED MS_MPI set ErrorInput=1
IF DEFINED ErrorInput (
ECHO some variables are not set. please set:
ECHO WORKINGDIR[path], MUMPS_TYPE[SEQ/OPENMP/HYBRID]
GOTO EOF
)
IF NOT DEFINED MS_MPI SET MS_MPI=c:\Program Files\Microsoft MPI\Bin\mpiexec.exe

::Define all pending directories
SET MUMPS_THIRDPARTY=%WORKINGDIR%\MUMPS_5.0.2
SET MUMPS_VSPROJECT=%WORKINGDIR%\MUMPS-VS
SET MUMPS_CONFIG=%WORKINGDIR%\dmumps-config

ECHO Working directory ... %WORKINGDIR%
ECHO MUMPS build type ... %MUMPS_TYPE%
ECHO MS MPI path ... %MS_MPI%

CD %MUMPS_THIRDPARTY%

ECHO ========================
ECHO clean up MUMPS directory
ECHO ========================

CALL make clean 2>&1
DEL Makefile.inc

IF %MUMPS_TYPE%==SEQ (
ECHO sequential MUMPS build initiated
COPY /y %MUMPS_CONFIG%\Makefile.inc.seq %MUMPS_THIRDPARTY%\Makefile.inc
)
IF %MUMPS_TYPE%==OPENMP (
ECHO OpenMP MUMPS build initiated
COPY /y %MUMPS_CONFIG%\Makefile.inc.OpenMP %MUMPS_THIRDPARTY%\Makefile.inc
)
IF %MUMPS_TYPE%==HYBRID (
ECHO OpenMP and MPI MUMPS build initiated
COPY /y %MUMPS_CONFIG%\Makefile.inc.Hybrid %MUMPS_THIRDPARTY%\Makefile.inc
)

ECHO done.

ECHO ===========================
ECHO clean up MUMPS-VS directory
ECHO ===========================

rmdir %MUMPS_VSPROJECT%\x64 /s /q
ECHO done.

ECHO ======================
ECHO build static libraries
ECHO ======================

CALL make
::path to examples from vendor to test libs, probably changes with future releases
CD examples
::chose single or double precision [s/d]
IF NOT DEFINED PRECISION SET PRECISION=d
::MPI yes or no [y/n]
set "PARALLEL="
IF %MUMPS_TYPE%==SEQ set PARALLEL=n
IF %MUMPS_TYPE%==OPENMP set PARALLEL=n
IF %MUMPS_TYPE%==MPI set PARALLEL=y
IF %MUMPS_TYPE%==HYBRID set PARALLEL=y

ECHO =====================
ECHO test static libraries
ECHO =====================

IF %PRECISION%==d (
	ECHO double precision
	IF %PARALLEL%==y (
		ECHO parallel test
		CALL "%MS_MPI%" -n 2 c_example
		CALL "%MS_MPI%" -n 2 dsimpletest < input_simpletest_real
	)
		::"-n 4" leads to deadlock --> internal Bug of MUMPS ?!?!
		::"$MS_MPI" -n 4 ./c_example
		::"$MS_MPI" -n 4 ./dsimpletest < input_simpletest_real
	IF %PARALLEL%==n (
		ECHO sequential test
		CALL c_example
		CALL dsimpletest < input_simpletest_real
	)
)
IF %PRECISION%==s (
	ECHO single precision
	IF %PARALLEL%==y (
		ECHO parallel test
		CALL "%MS_MPI%" -n 2 c_example
		CALL "%MS_MPI%" -n 2 ssimpletest < input_simpletest_real
	)
		::"-n 4" leads to deadlock --> internal Bug of MUMPS ?!?!
		::"$MS_MPI" -n 4 ./c_example
		::"$MS_MPI" -n 4 ./ssimpletest < input_simpletest_real
	IF %PARALLEL%==n (
		ECHO sequential test
		CALL c_example
		CALL ssimpletest < input_simpletest_real
	)
)

ECHO ======================
ECHO build shared libraries
ECHO ======================

cd %MUMPS_VSPROJECT%

for %%i in (*.sln) do set SLN_NAME=%%~ni
SET PLATFORM=x64
SET CONFIG=Release

IF %MUMPS_TYPE%==SEQ (
ECHO sequential MUMPS build initiated
CALL msbuild /property:Configuration=%CONFIG% /property:Platform=%PLATFORM%  /property:SolutionName=%SLN_NAME% dmumps-seq.vcxproj
)
IF %MUMPS_TYPE%==OPENMP (
ECHO OpenMP MUMPS build initiated
CALL msbuild /property:Configuration=%CONFIG% /property:Platform=%PLATFORM% /property:SolutionName=%SLN_NAME% dmumps-openMP.vcxproj
)
IF %MUMPS_TYPE%==HYBRID (
ECHO OpenMP and MPI MUMPS build initiated
CALL msbuild /property:Configuration=%CONFIG% /property:Platform=%PLATFORM% /property:SolutionName=%SLN_NAME% dmumps-Hybrid.vcxproj
)
::check if build was successful

CD %MUMPS_VSPROJECT%\%PLATFORM%\%CONFIG%

set "CHECK="
IF EXIST dmumps.dll SET CHECK=1
IF DEFINED CHECK (
ECHO Build successful
) ELSE (
ECHO Build failed
IF DEFINED ERRORS set /a ERRORS=%ERRORS%+1
)

:EOF
cd %WORKINGDIR%

ECHO MUMPS finished, returning to working directory ...
ECHO =======================
ECHO ^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>
