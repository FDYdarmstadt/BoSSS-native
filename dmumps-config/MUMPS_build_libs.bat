@echo off

set PATH=C:\cygwin64\bin;%PATH%

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
ECHO WORKINGDIR[path], MUMPS_TYPE[SEQ/OPENMP/HYBRID/MPI]
GOTO EOF
)
IF NOT DEFINED MS_MPI SET MS_MPI=c:\Program Files\Microsoft MPI\Bin\mpiexec.exe

::Define all pending directories
SET "MUMPS_THIRDPARTY=%WORKINGDIR%\MUMPS_5.0.2"
SET "MUMPS_BUILD=%WORKINGDIR%\MUMPS-VS"
SET "MUMPS_CONFIG=%WORKINGDIR%\dmumps-config"

ECHO Working directory ... "%WORKINGDIR%"
ECHO MUMPS build type ... %MUMPS_TYPE%
ECHO MS MPI path ... "%MS_MPI%"
ECHO MUMPS_THIRDPARTY ... "%MUMPS_THIRDPARTY%"
ECHO MUMPS_BUILD ... "%MUMPS_BUILD%"

CD %MUMPS_THIRDPARTY%

ECHO ========================
ECHO clean up MUMPS directory
ECHO ========================

CALL make clean
DEL Makefile.inc

IF %MUMPS_TYPE%==SEQ (
ECHO sequential MUMPS build initiated
COPY /y "%MUMPS_CONFIG%\Makefile.inc.seq" "%MUMPS_THIRDPARTY%\Makefile.inc"
)
IF %MUMPS_TYPE%==OPENMP (
ECHO OpenMP MUMPS build initiated
COPY /y "%MUMPS_CONFIG%\Makefile.inc.OpenMP" "%MUMPS_THIRDPARTY%\Makefile.inc"
)
IF %MUMPS_TYPE%==HYBRID (
ECHO OpenMP and MPI MUMPS build initiated
COPY /y "%MUMPS_CONFIG%\Makefile.inc.Hybrid" "%MUMPS_THIRDPARTY%\Makefile.inc"
)
IF %MUMPS_TYPE%==MPI (
ECHO MPI MUMPS build initiated
COPY /y "%MUMPS_CONFIG%\Makefile.inc.MPI" "%MUMPS_THIRDPARTY%\Makefile.inc"
)
MKDIR "%MUMPS_THIRDPARTY%\lib"

ECHO done.

ECHO ===========================
ECHO clean up MUMPS-VS directory
ECHO ===========================

rmdir "%MUMPS_BUILD%\x64" /s /q
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
		CALL "%MS_MPI% -n 2 c_example"
		CALL "%MS_MPI% -n 2 dsimpletest < input_simpletest_real"
	)
		::"-n 4" leads to deadlock --> internal Bug of MUMPS ?!?!
		::"$MS_MPI" -n 4 ./c_example
		::"$MS_MPI" -n 4 ./dsimpletest < input_simpletest_real
	IF %PARALLEL%==n (
		ECHO sequential test
		call c_example
		call dsimpletest < input_simpletest_real
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

cd %MUMPS_BUILD%

for %%i in (*.sln) do set SLN_NAME=%%~ni
SET PLATFORM=x64
SET CONFIG=Release

IF %MUMPS_TYPE%==SEQ (
SET "PROOFSTRING=dmumps-seq.dll"
ECHO sequential MUMPS build initiated
CALL msbuild /property:Configuration=%CONFIG% /property:Platform=%PLATFORM%  /property:SolutionName=%SLN_NAME% dmumps-seq.vcxproj
)
IF %MUMPS_TYPE%==OPENMP (
SET "PROOFSTRING=dmumps-openmp.dll"
ECHO OpenMP MUMPS build initiated
CALL msbuild /property:Configuration=%CONFIG% /property:Platform=%PLATFORM% /property:SolutionName=%SLN_NAME% dmumps-openmp.vcxproj
)
IF %MUMPS_TYPE%==HYBRID (
SET "PROOFSTRING=dmumps-hybrid.dll"
ECHO OpenMP and MPI MUMPS build initiated
CALL msbuild /property:Configuration=%CONFIG% /property:Platform=%PLATFORM% /property:SolutionName=%SLN_NAME% dmumps-hybrid.vcxproj
)
IF %MUMPS_TYPE%==MPI (
SET "PROOFSTRING=dmumps-mpi.dll"
ECHO MPI MUMPS build initiated
CALL msbuild /property:Configuration=%CONFIG% /property:Platform=%PLATFORM% /property:SolutionName=%SLN_NAME% dmumps-mpi.vcxproj
)
::check if build was successful

CD "%MUMPS_BUILD%\%PLATFORM%\%CONFIG%"

set "CHECK="
IF EXIST %PROOFSTRING% SET CHECK=1
IF DEFINED CHECK (
ECHO Build successful
) ELSE (
ECHO Build failed
)

:EOF
cd %WORKINGDIR%

ECHO MUMPS finished, returning to working directory ...
ECHO =======================
ECHO ^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>
