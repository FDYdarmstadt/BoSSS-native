:: ECHO VS-Build of PARDISO.dll
cd c:\BoSSS-native\PARDISO
devenv PARDISO.sln /Clean
rmdir x64 /s /q
rmdir PARDISO\x64 /s /q
cd PARDISO
devenv PARDISO-seq.vcxproj /Build "Release|x64"
devenv PARDISO-openMP.vcxproj /Build "Release|x64"
CD ..\..\
