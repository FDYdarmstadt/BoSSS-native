#
#  This file is part of MUMPS 5.0.2, released
#  on Fri Jul 15 09:12:54 UTC 2016
#
all: libmpiseq

.PHONY: all libmpiseq clean

include ../Makefile.inc

libmpiseq: libmpiseq$(PLAT)$(LIBEXT)

libmpiseq$(PLAT)$(LIBEXT): mpi.o mpic.o elapse.o
	$(AR)$@ mpi.o mpic.o elapse.o
	$(RANLIB) $@
.f.o:
	$(FC) $(OPTF)              -c $*.f $(OUTF)$*.o
.c.o:
	Echo "$(PATH)"
	AUXINC=-I"C:\Program Files (x86)\Windows Kits\10\Include\10.0.17134.0\ucrt" -I"C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.14.26428\include"
	$(CC) $(OPTC) $(CDEFS) -I. $(AUXINC) -c $*.c $(OUTC)$*.o
clean:
	$(RM) *.o *$(LIBEXT)
