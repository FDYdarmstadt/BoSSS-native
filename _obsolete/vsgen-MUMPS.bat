ECHO start MUMPS.lib build
set WORKINGDIR=c:/BoSSS-native
set MUMPS_TYPE=SEQ
set MS_MPI=n
C:\cygwin\bin\bash %WORKINGDIR%\dmumps-config\MUMPS_build_libs.bash
ECHO starting MUMPS.dll build
::exit