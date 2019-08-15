CC := gcc
CURRENTDIRECTORY := BoSSSnative_seq
WRAPPERS := $(wildcard $(WORKINGDIR)/$(CURRENTDIRECTORY)/wrapper/*.c)
TARGET := libBoSSSnative_seq.so
MKLROOT := /opt/intel/compilers_and_libraries_2019.4.243/linux/mkl
LIBINCLUDE := $(INCLUDEDIR)/libtecio.a $(MKLROOT)/lib/intel64/libmkl_intel_lp64.a $(MKLROOT)/lib/intel64/libmkl_sequential.a $(MKLROOT)/lib/intel64/libmkl_core.a

all: $(TARGET)
	cd $(WORKINGDIR)/BoSSSnative_seq/wrapper;

# Compile all functions targeted by the wrappers
# into one dynamic library
$(TARGET): $(patsubst %.c,%.o,$(WRAPPERS))
	$(CC) $^ -shared -o $(WORKINGDIR)/$(LIBDIR)/$@ -Wl,--start-group $(LIBINCLUDE) -Wl,--end-group -Wl,--unresolved-symbols=report-all  -lpthread -lm -ldl -lstdc++

# This generic target matches any file with the pattern BASENAME.o
# which is built from a dependency called BASENAME.c
%.o: %.c
	$(CC) -fPIC -c $< -o $@

clean:
	cd $(WORKINGDIR)/BoSSSnative_seq/wrapper; \
	rm -f *.o
