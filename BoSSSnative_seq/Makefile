# Compiler setup
CC := gcc
CXX := g++ # For C++ compilation
SHELL := /bin/bash
CURRENTDIRECTORY := $(BOSSSNATIVESEQ)

# Algoim wrapper and source file locations
ALGOIMWRAPPER_DIR := ../Algoim/CppAlgoim
ALGOIM_SOURCE_DIR := ../Algoim/CppAlgoim/algoim/algoim

# Source files
WRAPPERS := $(wildcard $(WORKINGDIR)/$(CURRENTDIRECTORY)/wrapper/*.c)
ALGOIMWRAPPER_C_SOURCES := $(ALGOIMWRAPPER_DIR)/main.c # C source files
ALGOIMWRAPPER_CPP_SOURCES := $(ALGOIMWRAPPER_DIR)/Algoimwrapper.cpp # C++ source files
TARGET := libBoSSSnative_seq.so

# Libraries and dependencies
LIBINCLUDE :=$(INCLUDEDIR)/libpord_seq.a $(INCLUDEDIR)/libmpiseq.a $(INCLUDEDIR)/libmumps_common_seq.a \
             $(INCLUDEDIR)/libdmumps_seq.a $(INCLUDEDIR)/libsmumps_seq.a $(INCLUDEDIR)/libmetis.a \
             $(MKLROOT)/lib/intel64/libmkl_intel_lp64.a $(MKLROOT)/lib/intel64/libmkl_gf_lp64.a \
             $(MKLROOT)/lib/intel64/libmkl_sequential.a $(MKLROOT)/lib/intel64/libmkl_core.a \
             $(INCLUDEDIR)/libtecio.a

# Compiler flags for Algoimwrapper (C++ files)
CXXFLAGS := -std=c++17 -Wall -Wextra -g -fPIC \
            -fvisibility=default -DADD_ -DHAVE_LAPACK_CONFIG_H -DLAPACK_COMPLEX_STRUCTURE -D_CONSOLE \
            -I$(ALGOIM_SOURCE_DIR) -I$(ALGOIMWRAPPER_DIR)/include

# Compiler flags for C files
CFLAGS := -Wall -Wextra -g -DLINUX -fPIC -fvisibility=default \
          -I$(ALGOIM_SOURCE_DIR) -I$(ALGOIMWRAPPER_DIR)/include


# Algoim libraries
# ALGOIM_LIBS := -llapacke -llapack -lblas

# Object files
ALGOIMWRAPPER_C_OBJECTS := $(ALGOIMWRAPPER_C_SOURCES:.c=.o)
ALGOIMWRAPPER_CPP_OBJECTS := $(ALGOIMWRAPPER_CPP_SOURCES:.cpp=.o)
WRAPPER_OBJECTS := $(WRAPPERS:.c=.o)

# Final target
all: $(TARGET)

# Compile Algoimwrapper C++ object files
$(ALGOIMWRAPPER_CPP_OBJECTS): %.o: %.cpp
	@printf "\e[34mCompiling Algoimwrapper C++ $<...\e[0m\n"
	$(CXX) $(CXXFLAGS) -c $< -o $@
	@printf "\e[34mDone!\e[0m\n"

# Compile Algoimwrapper C object files
$(ALGOIMWRAPPER_C_OBJECTS): %.o: %.c
	@printf "\e[34mCompiling Algoimwrapper C $<...\e[0m\n"
	$(CC) $(CFLAGS) -c $< -o $@
	@printf "\e[34mDone!\e[0m\n"

# Compile and link BoSSSnative_seq including Algoimwrapper
$(TARGET): $(WRAPPER_OBJECTS) $(ALGOIMWRAPPER_C_OBJECTS) $(ALGOIMWRAPPER_CPP_OBJECTS)
	@printf "\e[34mTrying to link libBoSSSnative_seq.so (including Algoimwrapper) ...\e[0m\n"
	$(CC) $^ -shared -o $(LIBDIR)/$@ -Wl,--start-group $(LIBINCLUDE) -Wl,--end-group \
	       -Wl,--unresolved-symbols=report-all -Wl,--version-script=libBoSSSnative_seq.version \
	       -lpthread -lm -ldl -lstdc++ -lgfortran -Wl,-rpath,'$$ORIGIN'/dependencies
	@printf "\e[34mSuccess!\e[0m\n"

# Compile BoSSSnative_seq wrapper object files
%.o: %.c
	@printf "\e[34mCompiling $<...\e[0m\n"
	$(CC) -fPIC -c $< -o $@
	@printf "\e[34mDone!\e[0m\n\n"

# Clean the object files and the target
clean:
	cd "$(WORKINGDIR)/$(CURRENTDIRECTORY)/wrapper"; \
	rm -f $(WRAPPER_OBJECTS) $(ALGOIMWRAPPER_C_OBJECTS) $(ALGOIMWRAPPER_CPP_OBJECTS) $(TARGET)
