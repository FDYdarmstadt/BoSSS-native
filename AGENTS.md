# BoSSS Native library package for Windows and Linux

## Purpose
- This repository bundles the build scripts, third-party sources, generated project files, and helper assets required to produce the native BoSSS libraries on Windows and Linux.
- The C#-package BoSSS loads the native libraries built from this repository at runtime, 
  and uses them accordingly via wrapper functions. 
  Therefore, libraries have to be build as shared libraries (DLLs on Windows, `.so` files on Linux). 
- The native package supports three parallelization levels:
  - serial (`_seq`): single-threaded
  - OpenMP (`_omp`): shared-memory parallelization on one machine
  - MPI (`_mpi`): distributed-memory parallelization across processes
- Not every dependency supports every mode. 
  For example, Metis is built only in sequential mode, while the BoSSS shared libraries are built in all three variants.

## Details on library organization
- The libraries are organized as follows:
  - For Linux (for AMD64), which is, historically, the newer target platform for BoSSS
    (and therefore, more cleanly organized), there are three main files:
    - `libBoSSSnative_seq.so`: essential parts are BLAS, LAPACK, PARDISO from the sequential Intel MKL;
    - `libBoSSSnative_omp.so`: essential parts are BLAS, LAPACK, PARDISO from the OpenMP-parallel Intel MKL;
    - `libBoSSSnative_mpi.so`: e.g, parallel MUMPS
  - Windows, currently (2024-06) is more fractured: 
    - `PARDISO_seq.dll`: sequential BLAS, LAPACK and PARDISO from Intel MKL
    - `PARDISO_omp.dll`: OpenMP-parallel BLAS, LAPACK and PARDISO from Intel MKL
    - MPI-parallel libraries: e.g., `HYPRE.dll`, `dmumps-mpi.dll`
    - this might be cleaned up in future, and agents are especially encouraged to update this document
      if, e.g., the DLLs are renamed or re-organized.
- BLAS and LAPACK have a very central role:
  - they are required by BoSSS itself, but also by several dependencies such as UMFPACK, PARDISO, and MUMPS
  - one should use highly optimized implementations for performance reasons, therefore we currently rely on Intel MKL for both Windows and Linux builds on x64/AMD64 platforms
  - if some library is MPI-parallelized, it must link to single-threaded BLAS/LAPACK
  - typically, the MKL libraries are rather large, around 100 MB. Therefore, 
    MPI-parallel libraries like e.g., Hypre or MUMPS, 
    should be linked against the single-threaded MKL libraries **which are already used for BoSSS itself**
    - Linux: Hypre and MUMPS are in `libBoSSSnative_mpi.so` and 
      link against the single-threaded MKL libraries in `libBoSSSnative_seq.so`
    - Windows: Hypre (`HYPRE.dll`) and MUMPS (`dmumps-mpi.dll`) are in separate DLLs 
      and link against the sequential DLLs `PARDISO_seq.dll` which contain the BLAS and LAPACK

## Repository layout
- Windows entry points: `BUILD_ALL.bat`, `CLEAN_ALL.bat`, `SET_PATHS.bat`
- Linux entry point: `BUILD_ALL_LINUX.sh`
- Linux cleanup in practice is handled via `BUILD_ALL_LINUX.sh --clean`; `CLEAN_ALL_LINUX.sh` currently only contains a stub.
- Windows output directory: `BUILDS`
- Linux output directory: `lib`
- Linux intermediate third-party archive directory: `thirdpartylibs`
- Prebuilt Windows runtime DLLs shipped with the repository: `WinDlls`

## Windows build
- Target platform: AMD64 / `x64`
- MPI stack: Microsoft MPI
- Current script assumptions are not fully portable. The batch files still contain several hard-coded installation roots and expect a fairly specific build machine layout.
- The current Windows flow is built around:
  - Visual Studio 2022
  - Intel oneAPI Fortran and MKL, currently referenced as version `2024.0`
  - Cygwin `make`
  - `msbuild`, `cmake`, `link`, `ifort`
  - Microsoft MPI headers and libraries
- `SET_PATHS.bat` auto-discovers most tools and writes the resolved paths to `addpath.txt`, `variables.txt`, and `PropertySheet.props`.
- A normal Windows build sequence is:
  ```bat
  call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" intel64 vs2022
  set "WORKINGDIR=%CD%"
  call CLEAN_ALL.bat
  call BUILD_ALL.bat
  ```
- `BUILD_ALL.bat` currently drives these builds:
  - SuiteSparse / UMFPACK helper generation
  - PARDISO
  - Algoim wrapper
  - HYPRE
  - Metis
  - MUMPS in sequential and MPI variants
- After the build, the script copies the generated DLLs plus extra runtime DLLs from `WinDlls` and the Intel redistribution directory into `BUILDS`.

## Linux build
- Target platform: `x86_64` Linux
- MPI stack: OpenMPI-compatible runtime provided by the current build image
- The Linux build expects Intel MKL to be made available through `/opt/intel/bin/compilervars.sh`.
- `BUILD_ALL_LINUX.sh` builds third-party static archives into `thirdpartylibs` and then links:
  - `libBoSSSnative_seq.so`
  - `libBoSSSnative_omp.so`
  - `libBoSSSnative_mpi.so`
- The script also creates `lib/dependencies`, copies selected runtime dependencies there, and adjusts their rpath with `patchelf`.
- Supported command-line flags of `BUILD_ALL_LINUX.sh`:
  - `--clean` / `-c`
  - `--quiet` / `-q`
  - `--verbose` / `-v`
  - `--help` / `-h`

## Docker-based Linux workflow
- The currently verified Linux build path uses the prebuilt image `floriankummer81/bosssbuild-ubuntu18.04`.
- Although the repository contains `Dockerfile-Ubuntu18.04/Dockerfile`, it is currently not sufficient to reproduce the full working build environment by itself. The image contains additional configuration steps that are not yet captured in the checked-in Dockerfile.
- Updating the Dockerfile so the external image is no longer required is a future maintenance task.
- The build command currently known to work on the build server is:
  ```bash
  docker pull floriankummer81/bosssbuild-ubuntu18.04
  docker run --rm -v `pwd`:/host-repo floriankummer81/bosssbuild-ubuntu18.04 /bin/bash -c "cd ~ && git clone /host-repo ./BoSSS-native && cd BoSSS-native && ./BUILD_ALL_LINUX.sh && cp -r ./lib/* /host-repo/lib/"
  ```
- To remove Linux build outputs again:
  ```bash
  ./BUILD_ALL_LINUX.sh --clean
  ```

## Practical notes for agents
- Prefer documenting behavior from the root build scripts over older prose in auxiliary text files.
- Treat version statements in older notes as historical unless they are still reflected in `SET_PATHS.bat`, `BUILD_ALL.bat`, `BUILD_ALL_LINUX.sh`, or the verified build image workflow.
- When updating build documentation, keep the distinction between Windows artifacts in `BUILDS` and Linux artifacts in `lib` explicit.
