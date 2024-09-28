CC := gcc
SHELL := /bin/bash
CURRENTDIRECTORY := $(BOSSSNATIVESEQ)
WRAPPERS := $(wildcard $(WORKINGDIR)/$(CURRENTDIRECTORY)/wrapper/*.c)
TARGET := libBoSSSnative_seq.so
LIBINCLUDE :=$(INCLUDEDIR)/libpord_seq.a $(INCLUDEDIR)/libmpiseq.a $(INCLUDEDIR)/libmumps_common_seq.a $(INCLUDEDIR)/libdmumps_seq.a $(INCLUDEDIR)/libsmumps_seq.a $(INCLUDEDIR)/libmetis.a $(MKLROOT)/lib/intel64/libmkl_intel_lp64.a $(MKLROOT)/lib/intel64/libmkl_gf_lp64.a $(MKLROOT)/lib/intel64/libmkl_sequential.a $(MKLROOT)/lib/intel64/libmkl_core.a $(INCLUDEDIR)/libtecio.a

all: $(TARGET)

# Compile all functions targeted by the wrappers
# into one dynamic library
$(TARGET): $(patsubst %.c,%.o,$(WRAPPERS))
	@printf "\e[34mTrying to link ...\e[0m\n"
	$(CC) $^ -shared -o $(LIBDIR)/$@ -Wl,--start-group $(LIBINCLUDE) -Wl,--end-group -Wl,--unresolved-symbols=report-all -Wl,--version-script=libBoSSSnative_seq.version  -lpthread -lm -ldl -lstdc++ -lgfortran -Wl,-rpath,'$$ORIGIN'/dependencies
	@printf "\e[34mSuccess!\e[0m\n"

# This generic target matches any file with the pattern BASENAME.o
# which is built from a dependency called BASENAME.c
%.o: %.c
	@printf "\e[34mCompiling $<\e[0m\n"
	$(CC) -fPIC -c $< -o $@
	@printf "\e[34mDone!\e[0m\n\n"

clean:
	cd "$(WORKINGDIR)/$(CURRENTDIRECTORY)/wrapper"; \
	rm -f $(WORKINGDIR)/$(CURRENTDIRECTORY)/wrapper/*.o
