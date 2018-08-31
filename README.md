===================================================
				DLL_Workflow
===================================================
workflow for creating Thirdparty DLL with Intel cmd

Information about versions
--------------------------
Software packages aquired:
-Intel(R) Parallel Studio XE 2018 Update 3 Cluster Edition for Windows
-CYGWIN_NT-6.1 pcmit32 2.10.0(0.325/5/3) 2018-02-02 15:16 x86_64 Cygwin
-Microsoft Visual Studio Community 2017 Version 15.7.4 

versions of involved executables:
-GNU Make 4.2.1 (from Cygwin)
-cmake 3.11.18040201-MSVC_2 (from MS Visual Studio)
-link 14.15.26726.0 (from MS Visual Studio)
-ifort Version 18.0.3.210 Build 20180410 for x64 (from Intel)
-cl Version 19.15.26726 for x64 (from MS Visual Studio)
-cmake-gui version 3.12.1.0 (not included in automatic build)

List of third party libraries
-----------------------------
This repository contains the description of the workflow to build third party libraries, such as ...
-metis
-dmumps
-pardiso (mkl)
-hypre (uses blas&lapack build)
-blas & lapack (mkl)

What is it all about?
---------------------
The workflows considers the suggested workflows from third-parties (taken from INSTALLS.txt,etc).
The *-config directories contain the describtion of workflows and Batchfiles to automatically build
the thirdparty-DLLs. Other directories are unzipped third-party directories or self-build visual studio 
solutions. Do not touch these directories, unless you know what you are doing! All necessary changes are 
made from within *-config directories! To execute all build-Batchfiles run BUILD_ALL.bat. With CLEAN_ALL.bat 
all temporary directories, which are created during build process, are removed. All builds will have the 
following properties: double precision, 32-bit Integers and x64-platform.

Customization
-------------
To customize the build you can set these variables:
MACHINE [HOME/JENKINS], ALL_TYPE[SER/PAR], BUILD_SPEED[SLOW/FAST]

MACHINE configures the PATH according to the machine the build process is running on. The default is JENKINS 
and should be used, if executed on JENKINS test server. HOME can be customized for your private machine.

ALL_TYPE specifies, which composition of DLLs will be build. There are two pre-settings: 
serial (SER) and parallel (PAR). Analog these you can add a custom one, but please notice, that not all
build types are supported. Check the batch-Files in *-config directories for that. The presettings are ...

serial:
Metis sequential, single precision
Mumps sequential
pardiso sequential
hypre with MPI support
BLAS & LAPACK sequential

parallel:
Metis sequential, single precision
Mumps with OpenMP support
pardiso with OpenMP support
hypre with MPI support
BLAS & LAPACK sequential

With BUILD_SPEED you can boost up the build process. With SLOW the build process will be run as single task.
With FAST every subcall of batch scripts will be run as separate task.

Annotations:
-If new versions have to be build, remember to adjust directories relative to working directory within
the batch-files. Never forget to put paths with spaces etc. in parenthesis: check Bugfixes.txt for details
-if make is not recognized adjust included packages of cygwin