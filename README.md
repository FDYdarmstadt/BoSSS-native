# DLL_Workflow
==============
workflow for creating a DLL from mixed fortran/C-code libraries
trial A	-- using cygwin (for 'make') out of intel-shell (for compilation) and link .libs with VS 2017

Software:
-Intel(R) Parallel Studio XE 2018 Update 3 Cluster Edition for Windows
-CYGWIN_NT-6.1 pcmit32 2.10.0(0.325/5/3) 2018-02-02 15:16 x86_64 Cygwin
-Microsoft Visual Studio Community 2017 Version 15.7.4 

1.	add path of Visual Studio link.exe to cygwin's PATH at the front
2.	start Intel-shell (C:\Windows\System32\cmd.exe /E:ON /V:ON /K ""C:\Program Files (x86)\IntelSWTools\compilers_and_libraries_2018.3.210\windows\bin\ipsxe-comp-vars.bat" intel64 vs2017")
3.	load cygwin Batchskript: c:\cygwin\Cygwin.bat
4.	adjust Makefile.inc: use https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor/ if you are not sure, which .lib fits
5.	execute 'make' in directory, where Makefile.inc is
6.	Open VS-project "dmumps"
7.	Set "dmumps"-Properties\Linker\General\Additional Library Directories\ and "dmumps"-Properties\Linker\Input\Additional Dependencies\:
	Attention: put 64 before 32 under ~\Additional Library Directories
8.	Build solution & be happy

Annotations:
-To globally set the PATH-variable for cygwin: write ...
export PATH="/cygdrive/c/Program Files (x86)/Microsoft Visual Studio/2017/Community/VC/Tools/MSVC/14.14.26428/bin/HostX64/x64":$PATH
export PATH="/cygdrive/c/Program Files/Microsoft MPI/Bin":$PATH
... into C:\cygwin\home\weber\.bash_profile