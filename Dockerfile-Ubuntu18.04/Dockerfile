# Use an older version of Ubuntu as the base image
# This is done to ensure compatibility with older versions of glibc.
# (E.g., Lichtenberg, by Jan. 2024 runs on Red Hat 9, which is quite old and uses glibc 2.28.
#  If we build on newer versions of Ubuntu, e.g. 20.04, we depend on glib  2.31 and the binaries do not work on Lichtenberg.
# Replace 'ubuntu:18.04' with the specific version you need.
FROM  intel/oneapi-basekit:2022.3.1-devel-ubuntu18.04
RUN apt-get update && apt-get install git gcc gfortran mpi-default-bin  mpi-default-dev patchelf -y
