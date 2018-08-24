# Install script for directory: C:/BoSSS-native/hypre-2.11.2/src

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "C:/BoSSS-native/hypre-2.11.2/src/hypre")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY OPTIONAL FILES "C:/BoSSS-native/hypre-2.11.2/src/cmbuild/Debug/HYPRE.lib")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY OPTIONAL FILES "C:/BoSSS-native/hypre-2.11.2/src/cmbuild/Release/HYPRE.lib")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY OPTIONAL FILES "C:/BoSSS-native/hypre-2.11.2/src/cmbuild/MinSizeRel/HYPRE.lib")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY OPTIONAL FILES "C:/BoSSS-native/hypre-2.11.2/src/cmbuild/RelWithDebInfo/HYPRE.lib")
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "C:/BoSSS-native/hypre-2.11.2/src/cmbuild/Debug/HYPRE.dll")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "C:/BoSSS-native/hypre-2.11.2/src/cmbuild/Release/HYPRE.dll")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "C:/BoSSS-native/hypre-2.11.2/src/cmbuild/MinSizeRel/HYPRE.dll")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "C:/BoSSS-native/hypre-2.11.2/src/cmbuild/RelWithDebInfo/HYPRE.dll")
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES
    "C:/BoSSS-native/hypre-2.11.2/src/cmbuild/HYPRE_config.h"
    "C:/BoSSS-native/hypre-2.11.2/src/HYPREf.h"
    "C:/BoSSS-native/hypre-2.11.2/src/HYPRE.h"
    "C:/BoSSS-native/hypre-2.11.2/src/utilities/HYPRE_utilities.h"
    "C:/BoSSS-native/hypre-2.11.2/src/utilities/_hypre_utilities.h"
    "C:/BoSSS-native/hypre-2.11.2/src/utilities/hypre_hopscotch_hash.h"
    "C:/BoSSS-native/hypre-2.11.2/src/utilities/HYPRE_error_f.h"
    "C:/BoSSS-native/hypre-2.11.2/src/utilities/fortran.h"
    "C:/BoSSS-native/hypre-2.11.2/src/utilities/fortran_matrix.h"
    "C:/BoSSS-native/hypre-2.11.2/src/multivector/csr_matmultivec.h"
    "C:/BoSSS-native/hypre-2.11.2/src/multivector/interpreter.h"
    "C:/BoSSS-native/hypre-2.11.2/src/multivector/multivector.h"
    "C:/BoSSS-native/hypre-2.11.2/src/multivector/par_csr_matmultivec.h"
    "C:/BoSSS-native/hypre-2.11.2/src/multivector/par_csr_pmvcomm.h"
    "C:/BoSSS-native/hypre-2.11.2/src/multivector/par_multivector.h"
    "C:/BoSSS-native/hypre-2.11.2/src/multivector/seq_multivector.h"
    "C:/BoSSS-native/hypre-2.11.2/src/multivector/temp_multivector.h"
    "C:/BoSSS-native/hypre-2.11.2/src/krylov/HYPRE_krylov.h"
    "C:/BoSSS-native/hypre-2.11.2/src/krylov/HYPRE_lobpcg.h"
    "C:/BoSSS-native/hypre-2.11.2/src/krylov/HYPRE_MatvecFunctions.h"
    "C:/BoSSS-native/hypre-2.11.2/src/krylov/krylov.h"
    "C:/BoSSS-native/hypre-2.11.2/src/krylov/lobpcg.h"
    "C:/BoSSS-native/hypre-2.11.2/src/seq_mv/HYPRE_seq_mv.h"
    "C:/BoSSS-native/hypre-2.11.2/src/seq_mv/seq_mv.h"
    "C:/BoSSS-native/hypre-2.11.2/src/parcsr_mv/HYPRE_parcsr_mv.h"
    "C:/BoSSS-native/hypre-2.11.2/src/parcsr_mv/_hypre_parcsr_mv.h"
    "C:/BoSSS-native/hypre-2.11.2/src/parcsr_block_mv/par_csr_block_matrix.h"
    "C:/BoSSS-native/hypre-2.11.2/src/parcsr_block_mv/csr_block_matrix.h"
    "C:/BoSSS-native/hypre-2.11.2/src/distributed_matrix/distributed_matrix.h"
    "C:/BoSSS-native/hypre-2.11.2/src/IJ_mv/HYPRE_IJ_mv.h"
    "C:/BoSSS-native/hypre-2.11.2/src/IJ_mv/_hypre_IJ_mv.h"
    "C:/BoSSS-native/hypre-2.11.2/src/matrix_matrix/HYPRE_matrix_matrix_protos.h"
    "C:/BoSSS-native/hypre-2.11.2/src/distributed_ls/pilut/HYPRE_DistributedMatrixPilutSolver_protos.h"
    "C:/BoSSS-native/hypre-2.11.2/src/distributed_ls/pilut/HYPRE_DistributedMatrixPilutSolver_types.h"
    "C:/BoSSS-native/hypre-2.11.2/src/parcsr_ls/HYPRE_parcsr_ls.h"
    "C:/BoSSS-native/hypre-2.11.2/src/parcsr_ls/_hypre_parcsr_ls.h"
    "C:/BoSSS-native/hypre-2.11.2/src/struct_mv/HYPRE_struct_mv.h"
    "C:/BoSSS-native/hypre-2.11.2/src/struct_mv/_hypre_struct_mv.h"
    "C:/BoSSS-native/hypre-2.11.2/src/struct_ls/HYPRE_struct_ls.h"
    "C:/BoSSS-native/hypre-2.11.2/src/struct_ls/_hypre_struct_ls.h"
    "C:/BoSSS-native/hypre-2.11.2/src/sstruct_mv/HYPRE_sstruct_mv.h"
    "C:/BoSSS-native/hypre-2.11.2/src/sstruct_mv/_hypre_sstruct_mv.h"
    "C:/BoSSS-native/hypre-2.11.2/src/sstruct_ls/HYPRE_sstruct_ls.h"
    "C:/BoSSS-native/hypre-2.11.2/src/sstruct_ls/_hypre_sstruct_ls.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "C:/BoSSS-native/hypre-2.11.2/src/cmbuild/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
