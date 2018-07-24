xcopy gk_arch.h C:\BoSSS-native\metis-5.1.0\GKlib /y
rmdir build\windows /s /q
MKDIR build\windows
CD build\windows
:: cmake -DCMAKE_CONFIGURATION_TYPES="Release" ..\.. -G "Visual Studio 15 2017 Win64" -DSHARED=1 -DCMAKE_C_COMPILER=cl
cmake -DCMAKE_CONFIGURATION_TYPES="Release" ..\.. -G "Visual Studio 15 2017 Win64"
::cmake -DCMAKE_CONFIGURATION_TYPES="Release" ..\.. -G "Visual Studio 15 2017 Win64" -DSHARED=1
ECHO VS files have been generated in build\windows
devenv /Clean
devenv ALL_BUILD.vcxproj /Build "Release|x64"
CD ..\..\
