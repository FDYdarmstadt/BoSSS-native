CC := gcc
SHELL := /bin/bash
CURRENTDIRECTORY := $(BOSSSNATIVEMPI)
WRAPPERS := $(wildcard $(WORKINGDIR)/$(CURRENTDIRECTORY)/wrapper/*.c)
TARGET := libBoSSSnative_mpi.so
LIBINCLUDE :=$(INCLUDEDIR)/libpord_mpi.a $(INCLUDEDIR)/libmumps_common_mpi.a $(INCLUDEDIR)/libdmumps_mpi.a $(INCLUDEDIR)/libsmumps_mpi.a $(MKLROOT)/lib/intel64/libmkl_intel_lp64.a $(MKLROOT)/lib/intel64/libmkl_gf_lp64.a $(MKLROOT)/lib/intel64/libmkl_blacs_openmpi_lp64.a $(MKLROOT)/lib/intel64/libmkl_scalapack_lp64.a $(MKLROOT)/lib/intel64/libmkl_core.a $(MKLROOT)/lib/intel64/libmkl_sequential.a

all: $(TARGET)

# Compile all functions targeted by the wrappers
# into one dynamic library
$(TARGET): $(patsubst %.c,%.o,$(WRAPPERS))
	@printf "\e[34mTrying to link ...\e[0m\n"
	$(CC) $^ -shared -o $(LIBDIR)/$@ -I$(MKLROOT)/include -Wl,--start-group  $(LIBINCLUDE) -Wl,--end-group -Wl,--unresolved-symbols=report-all -lmpi -lmpi_mpifh -lpthread -lm -ldl -lstdc++ -lgfortran
	@printf "\e[34mSuccess!\e[0m\n"

# This generic target matches any file with the pattern BASENAME.o
# which is built from a dependency called BASENAME.c
%.o: %.c
	@printf "\e[34mCompiling $<\e[0m\n"
	$(CC) -fPIC -c $< -o $@
	@printf "\e[34mDone!\e[0m\n\n"

clean:
	@cd $(WORKINGDIR)/$(CURRENTDIRECTORY)/wrapper; \
	rm -f *.o 1>/dev/null 2>&1
