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
	$(CC) $(OPTC) $(CDEFS) -I. $(AUXINC) -c $*.c $(OUTC)$*.o
clean:
	$(RM) *.o *$(LIBEXT)
