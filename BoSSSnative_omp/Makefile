CC := gcc
SHELL := /bin/bash
CURRENTDIRECTORY := $(BOSSSNATIVEOMP)
WRAPPERS := $(wildcard $(WORKINGDIR)/$(CURRENTDIRECTORY)/wrapper/*.c)
TARGET := libBoSSSnative_omp.so
LIBINCLUDE :=${MKLROOT}/lib/intel64/libmkl_gf_lp64.a $(MKLROOT)/lib/intel64/libmkl_intel_lp64.a $(MKLROOT)/lib/intel64/libmkl_gnu_thread.a $(MKLROOT)/lib/intel64/libmkl_core.a

all: $(TARGET)

# Compile all functions targeted by the wrappers
# into one dynamic library
$(TARGET): $(patsubst %.c,%.o,$(WRAPPERS))
	@printf "\e[34mTrying to link ...\e[0m\n"
	$(CC) $^ -fopenmp -shared -o $(LIBDIR)/$@ -Wl,--start-group $(LIBINCLUDE) -Wl,--end-group -Wl,--unresolved-symbols=report-all -Wl,--version-script=libBoSSSnative_omp.version  -lpthread -lm -ldl  -lgomp -Wl,-rpath,'$$ORIGIN'/dependencies
	@printf "\e[34mSuccess!\e[0m\n"

# This generic target matches any file with the pattern BASENAME.o
# which is built from a dependency called BASENAME.c
%.o: %.c
	@printf "\e[34mCompiling $<\e[0m\n"
	$(CC) -fopenmp -fPIC -c $< -o $@
	@printf "\e[34mDone!\e[0m\n\n"

clean:
	cd "$(WORKINGDIR)/$(CURRENTDIRECTORY)/wrapper"; \
	rm -f $(WORKINGDIR)/$(CURRENTDIRECTORY)/wrapper/*.o
