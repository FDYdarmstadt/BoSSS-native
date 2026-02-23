# Install script for directory: C:/Users/kummer/Documents/BoSSS-native/SuiteSparse_7.12.2/CHOLMOD

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "C:/Program Files/SuiteSparse")
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

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "C:/Users/kummer/Documents/BoSSS-native/SuiteSparse_7.12.2_config_win_static_seq/CHOLMOD/Debug/cholmod_static.lib")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "C:/Users/kummer/Documents/BoSSS-native/SuiteSparse_7.12.2_config_win_static_seq/CHOLMOD/Release/cholmod_static.lib")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "C:/Users/kummer/Documents/BoSSS-native/SuiteSparse_7.12.2_config_win_static_seq/CHOLMOD/MinSizeRel/cholmod_static.lib")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "C:/Users/kummer/Documents/BoSSS-native/SuiteSparse_7.12.2_config_win_static_seq/CHOLMOD/RelWithDebInfo/cholmod_static.lib")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/suitesparse" TYPE FILE FILES "C:/Users/kummer/Documents/BoSSS-native/SuiteSparse_7.12.2/CHOLMOD/Include/cholmod.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/CHOLMOD/CHOLMODTargets_static.cmake")
    file(DIFFERENT _cmake_export_file_changed FILES
         "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/CHOLMOD/CHOLMODTargets_static.cmake"
         "C:/Users/kummer/Documents/BoSSS-native/SuiteSparse_7.12.2_config_win_static_seq/CHOLMOD/CMakeFiles/Export/495b850a4b4a7c9008b35f7038d8f066/CHOLMODTargets_static.cmake")
    if(_cmake_export_file_changed)
      file(GLOB _cmake_old_config_files "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/CHOLMOD/CHOLMODTargets_static-*.cmake")
      if(_cmake_old_config_files)
        string(REPLACE ";" ", " _cmake_old_config_files_text "${_cmake_old_config_files}")
        message(STATUS "Old export file \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/CHOLMOD/CHOLMODTargets_static.cmake\" will be replaced.  Removing files [${_cmake_old_config_files_text}].")
        unset(_cmake_old_config_files_text)
        file(REMOVE ${_cmake_old_config_files})
      endif()
      unset(_cmake_old_config_files)
    endif()
    unset(_cmake_export_file_changed)
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/CHOLMOD" TYPE FILE FILES "C:/Users/kummer/Documents/BoSSS-native/SuiteSparse_7.12.2_config_win_static_seq/CHOLMOD/CMakeFiles/Export/495b850a4b4a7c9008b35f7038d8f066/CHOLMODTargets_static.cmake")
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/CHOLMOD" TYPE FILE FILES "C:/Users/kummer/Documents/BoSSS-native/SuiteSparse_7.12.2_config_win_static_seq/CHOLMOD/CMakeFiles/Export/495b850a4b4a7c9008b35f7038d8f066/CHOLMODTargets_static-debug.cmake")
  endif()
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/CHOLMOD" TYPE FILE FILES "C:/Users/kummer/Documents/BoSSS-native/SuiteSparse_7.12.2_config_win_static_seq/CHOLMOD/CMakeFiles/Export/495b850a4b4a7c9008b35f7038d8f066/CHOLMODTargets_static-minsizerel.cmake")
  endif()
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/CHOLMOD" TYPE FILE FILES "C:/Users/kummer/Documents/BoSSS-native/SuiteSparse_7.12.2_config_win_static_seq/CHOLMOD/CMakeFiles/Export/495b850a4b4a7c9008b35f7038d8f066/CHOLMODTargets_static-relwithdebinfo.cmake")
  endif()
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/CHOLMOD" TYPE FILE FILES "C:/Users/kummer/Documents/BoSSS-native/SuiteSparse_7.12.2_config_win_static_seq/CHOLMOD/CMakeFiles/Export/495b850a4b4a7c9008b35f7038d8f066/CHOLMODTargets_static-release.cmake")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/CHOLMOD" TYPE FILE FILES
    "C:/Users/kummer/Documents/BoSSS-native/SuiteSparse_7.12.2_config_win_static_seq/CHOLMOD/target/CHOLMODConfig.cmake"
    "C:/Users/kummer/Documents/BoSSS-native/SuiteSparse_7.12.2_config_win_static_seq/CHOLMOD/CHOLMODConfigVersion.cmake"
    )
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "C:/Users/kummer/Documents/BoSSS-native/SuiteSparse_7.12.2_config_win_static_seq/CHOLMOD/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
