# system dependent flags for CUDA
# CUDA sdk path
CUDA_SDK?=/usr/local/cuda/sdk
# CUDA path
CUDA_PATH?=/usr/local/cuda

# C compiler
CC = gcc
CCFLAGS = -std=c99 -Wall

# C++ compiler
CXX = g++
CXXFLAGS = -I$(CUDA_SDK)/common/inc \
	   -I$(CUDA_PATH)/include

# CUDA compiler
NVCC = nvcc
NVCCFLAGS = -ccbin /usr/bin/gcc \
	    -I$(CUDA_SDK)/common/inc \
	    -I$(CUDA_PATH)/include -arch=sm_20 -m64

# linker and linker options
LD = gcc
LFLAGS = -L$(CUDA_PATH)/lib64 -lcuda -lcudart -lm
LDXX = g++

PROJ = qr_serial qr_cuda
.PHONY: clean

all: $(PROJ) $(clean)
# C source
%.o: %.c
	@echo C compiling $@
	$(CC) -c $(CCFLAGS) -o $@ $<


# CUDA source
%.o: %.cu
	@echo CUDA compiling $@
	$(NVCC) -c $(NVCCFLAGS) -o $@ $<

# linking
qr_serial:
	@echo linking $@
	$(LD) $(LFLAGS) -o $@ $^

qr_cuda:
	@echo linking $@
	$(LDXX) $(LFLAGS) -o $@ $^


clean:
	rm -f *.o $(PROJ)

# DEPENDENCIES
qr_serial: qr_serial.o
qr_serial.o: qr_serial.c

qr_cuda: qr_cuda.o
qr_cuda.o: qr_cuda.cu
