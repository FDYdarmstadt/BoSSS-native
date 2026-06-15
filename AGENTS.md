# BoSSS Native library package for Windows and Linux




## Preliminaries
- The BoSSS native library package supports three different levels of parallelization
  - serial (suffix `_seq`): no parallelization, only one thread is used
  - OpenMP (suffix `_omp`): shared memory parallelization, 
    multiple threads are used on a single machine
  - MPI (suffix `_mpi`): distributed memory parallelization, 
    multiple processes are used on multiple machines
- Obviously, not all libraries support all three levels of parallelization, 
  for example, the Metis library only supports serial execution, 
  BLAS and LAPACK libraries support serial and OpenMP execution


## Windows 
- For Microsoft MPI, for AMD64
- the Windows compilation is **not** fully portable,
  but is requires an specific setup and build environment,
  we currently use the FDYGITRUNNER server for this,
  which is running Windows Server 2019 and has Visual Studio 2022 installed
- from an normal command prompt, the compilation can be performed by the following commands:
  ```
  call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" intel64 vs2022
  set "WORKINGDIR=%WORKSPACE%"
  call CLEAN_ALL.bat
  call BUILD_ALL.bat
  ```
- the Windows-package also contains several pre-compiled dlls,
  which are found in the `WinDlls` directory
- the resulting DLLs are located in the `BUILDS` subdirectory (not part of the repository, 
  but created during the build process)
## Linux
- For OpenMPI, for AMD64
- the Linux compilation is performed using Docker
- it is based on a fairly old Ubuntu 18.04 image, 
  which is used to ensure that the resulting binaries are compatible 
  with a wide range of Linux distributions
  (might be upgraded in the future)
- there exists currently no dockerfile
- on a Linux host with docker, the compilation can be performed by the following commands:
  ```
  docker pull floriankummer81/bosssbuild-ubuntu18.04
  docker run --rm -v `pwd`:/host-repo floriankummer81/bosssbuild-ubuntu18.04 /bin/bash -c "cd ~ && git clone /host-repo ./BoSSS-native && cd BoSSS-native && ./BUILD_ALL_LINUX.sh && cp -r ./lib/* /host-repo/lib/
  ```
