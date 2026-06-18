# BoSSS Native Build Repository

This repository contains the scripts, third-party source trees, generated project files, and helper assets used to build the native BoSSS libraries for Windows and Linux.

## Build targets

The native package is built in three variants:

- `*_seq`: sequential, single-threaded
- `*_omp`: OpenMP, shared-memory parallel
- `*_mpi`: MPI, distributed-memory parallel

Not every third-party dependency exists in every mode. For example, Metis is only built sequentially, while the Linux BoSSS shared libraries are produced in all three variants.

## Repository structure

Important root-level entry points:

- `BUILD_ALL.bat`: main Windows build driver
- `CLEAN_ALL.bat`: removes Windows build outputs and generated helper files
- `SET_PATHS.bat`: discovers tool installations and writes derived build settings
- `BUILD_ALL_LINUX.sh`: main Linux build driver
- `Dockerfile-Ubuntu18.04/Dockerfile`: reproducible Linux build environment based on Ubuntu 18.04

Important output locations:

- Windows output bundle: `BUILDS`
- Linux shared libraries: `lib`
- Linux third-party static archives: `thirdpartylibs`

## Windows workflow

The current batch files reflect a Windows build environment centered on:

- Visual Studio 2022
- Intel oneAPI compiler and MKL, currently referenced as version `2024.0`
- Microsoft MPI
- Cygwin `make`

The scripts are not fully portable. They still assume specific installation roots and rely on `SET_PATHS.bat` to find or derive the necessary paths.

### What `BUILD_ALL.bat` does

`BUILD_ALL.bat` expects `WORKINGDIR` to point to the repository root. It then calls `SET_PATHS.bat`, populates `PATH`, writes `variables.txt` and `PropertySheet.props`, and drives the Windows builds for:

- SuiteSparse / UMFPACK helper generation
- BoSSSnative (`BoSSSnative_win`)
- Algoim
- HYPRE
- Metis
- MUMPS in sequential mode
- MUMPS in MPI mode

At the end, it copies generated DLLs plus runtime dependencies from `WinDlls` and the Intel redistribution directory into `BUILDS`.

### Typical Windows build sequence

```bat
call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" intel64 vs2022
set "WORKINGDIR=%CD%"
call CLEAN_ALL.bat
call BUILD_ALL.bat
```

### Notes on configuration

- Older repository notes mention `MACHINE`, `ALL_TYPE`, and older Visual Studio / Intel versions. Those notes are historical and no longer describe the current root scripts well.
- `BUILD_ALL.bat` currently sets `BUILD_SPEED` to `SLOW` by default if it is not already defined.
- Several paths in `SET_PATHS.bat` are still hard-coded to Intel oneAPI `2024.0`, so version upgrades usually require touching that file.

## Linux workflow

The Linux build produces shared objects for the three BoSSS variants and stores them in `lib`.

### What `BUILD_ALL_LINUX.sh` does

The script:

- verifies that it is running on `x86_64` Linux
- sources Intel MKL environment settings from `/opt/intel/bin/compilervars.sh`
- creates `lib`, `lib/dependencies`, and `thirdpartylibs` as needed
- builds missing third-party static archives for MUMPS, Metis, and TECIO
- builds `libfakeintel.so`
- links `libBoSSSnative_seq.so`, `libBoSSSnative_omp.so`, and `libBoSSSnative_mpi.so`
- copies selected runtime dependencies into `lib/dependencies` and adjusts their rpath with `patchelf`

Supported flags:

- `-c`, `--clean`: remove Linux build outputs from `lib` and `thirdpartylibs`
- `-q`, `--quiet`: suppress most command output
- `-v`, `--verbose`: echo executed commands
- `-h`, `--help`: show usage text

Although `CLEAN_ALL_LINUX.sh` exists, the actual cleanup logic currently lives in `BUILD_ALL_LINUX.sh --clean`.

### Docker-based Linux build

The currently working Linux build path uses the prebuilt image `floriankummer81/bosssbuild-ubuntu18.04`.

The repository also contains `Dockerfile-Ubuntu18.04/Dockerfile`, but that Dockerfile is currently incomplete as a reproduction of the real build environment. The image contains additional configuration that is not yet captured there.

Bringing the Dockerfile up to the point where it can replace the external image is a future maintenance task.

The build command currently verified on the build server is:

```bash
docker pull floriankummer81/bosssbuild-ubuntu18.04
docker run --rm -v "$PWD":/host-repo floriankummer81/bosssbuild-ubuntu18.04 /bin/bash -c "cd ~ && git clone /host-repo ./BoSSS-native && cd BoSSS-native && ./BUILD_ALL_LINUX.sh && cp -r ./lib/* /host-repo/lib/"
```

To remove Linux build outputs again:

```bash
./BUILD_ALL_LINUX.sh --clean
```

## Third-party components present in this repository

The current top-level scripts and directories cover at least these third-party components:

- MUMPS
- Metis
- HYPRE
- BoSSSnative (Windows BLAS/LAPACK/PARDISO/UMFPACK DLL bundle)
- TECIO
- Algoim
- SuiteSparse / UMFPACK helpers
- BLAS / LAPACK support assets

## Maintenance notes

- When updating versions, prefer the root scripts over older prose files as the source of truth.
- If paths with spaces are changed in batch files, preserve the existing quoting style carefully. `Bugfixes.txt` documents several historical pitfalls.
- If a new machine layout is introduced, `SET_PATHS.bat` is usually the first file that needs adjustment.
- If Linux build portability is improved, update both the Dockerfile and the image-based workflow notes together so the docs make clear which path is actually supported.