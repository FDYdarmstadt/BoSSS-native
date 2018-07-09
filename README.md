# DLL_Workflow
==============
workflow for creating a DLL from mixed fortran/C code
trial A	-- using cygwin out of intel-shell
versions:
Intel(R) Parallel Studio XE 2018 Update 3 Cluster Edition for Windows
cygwin ...

1.	delete link.exe from cygwin installation (ugly workaround, otherwise conflict with link from Intel-shell)
2.	Intel-shell verwenden (C:\Windows\System32\cmd.exe /E:ON /V:ON /K ""C:\Program Files (x86)\IntelSWTools\compilers_and_libraries_2018.3.210\windows\bin\ipsxe-comp-vars.bat" intel64 vs2017")
3.	cygwin Batchskript laden: c:\cygwin\Cygwin.bat
	(delete mkl_intel_c.lib in Makefile.inc, )
4.	execute 'make' on ~/MUMPS/Makefile.inc (edited Makefile.inc according to vendor-README)
5.	

