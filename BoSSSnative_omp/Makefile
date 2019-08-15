CC := gcc
WRAPPERS := $(wildcard *.c)
TARGET := libBoSSSnative_seq.so
MKLROOT := /opt/intel/compilers_and_libraries_2019.4.243/linux/mkl

all: $(TARGET)

# Compile all functions targeted by the wrappers
# into one dynamic library
$(TARGET): $(patsubst %.c,%.o,$(WRAPPERS))
	$(CC) $^ -shared -o $@ -Wl,--start-group $(MKLROOT)/lib/intel64/libmkl_intel_lp64.a $(MKLROOT)/lib/intel64/libmkl_intel_thread.a $(MKLROOT)/lib/intel64/libmkl_core.a -Wl,--end-group -Wl,--unresolved-symbols=report-all  -lpthread -lm -ldl

# This generic target matches any file with the pattern BASENAME.o
# which is built from a dependency called BASENAME.c
%.o: %.c
	$(CC) -fPIC -c $< -o $@

clean:
	@rm -f *.o *.so
