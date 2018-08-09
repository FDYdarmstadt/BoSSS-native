# DLL_Workflow
==============
workflow for creating Thirdparty DLL with Intel cmd

Software aquired:
-Intel(R) Parallel Studio XE 2018 Update 3 Cluster Edition for Windows
-CYGWIN_NT-6.1 pcmit32 2.10.0(0.325/5/3) 2018-02-02 15:16 x86_64 Cygwin
-Microsoft Visual Studio Community 2017 Version 15.7.4 

This repository contains the description of the workflow to build third party libraries, such as ...
-metis
-dmumps
-pardiso (mkl)
-hypre
-blas & lapack (mkl)

The workflows consider the suggested workflows from third-parties (taken from INSTALLS.txt,etc).
The *-config directories contain Batchfiles to execute the complete workflows for DLL generation.
The SharedLib directory contains ...
Other directories are unzipped third-party stuff or self build visual studio solutions.
Do not touch these directories! All necessary changes are made from within *-config directories!
To execute all Batch files run the ... Batch-file.

Annotations:
-