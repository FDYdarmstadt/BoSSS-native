CC := gcc
CURRENTDIRECTORY := BoSSSnative_mpi
WRAPPERS := $(wildcard $(WORKINGDIR)/$(CURRENTDIRECTORY)/wrapper/*.c)
TARGET := libBoSSSnative_mpi.so
LIBINCLUDE :=$(INCLUDEDIR)/libpord_mpi.a $(INCLUDEDIR)/libmumps_common_mpi.a $(INCLUDEDIR)/libdmumps_mpi.a $(INCLUDEDIR)/libsmumps_mpi.a $(MKLROOT)/lib/intel64/libmkl_intel_lp64.a $(MKLROOT)/lib/intel64/libmkl_gf_lp64.a $(MKLROOT)/lib/intel64/libmkl_blacs_openmpi_lp64.a $(MKLROOT)/lib/intel64/libmkl_scalapack_lp64.a $(MKLROOT)/lib/intel64/libmkl_core.a $(MKLROOT)/lib/intel64/libmkl_sequential.a

all: $(TARGET)
	cd $(WORKINGDIR)/BoSSSnative_mpi/wrapper;

# Compile all functions targeted by the wrappers
# into one dynamic library
$(TARGET): $(patsubst %.c,%.o,$(WRAPPERS))
	$(CC) $^ -shared -o $(LIBDIR)/$@ -I$(MKLROOT)/include -Wl,--start-group  $(LIBINCLUDE) -Wl,--end-group -Wl,--unresolved-symbols=report-all -lmpi -lmpi_mpifh -lpthread -lm -ldl -lstdc++ -lgfortran

# This generic target matches any file with the pattern BASENAME.o
# which is built from a dependency called BASENAME.c
%.o: %.c
	$(CC) -fPIC -c $< -o $@

clean:
	cd $(WORKINGDIR)/BoSSSnative_mpi/wrapper; \
	rm -f *.o
