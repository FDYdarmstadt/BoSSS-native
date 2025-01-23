

@echo off


ECHO ^>^>^>^>^>^>Algoim BUILD^>^>^>^>^>^>
ECHO ========================
ECHO.


::check if all necessary variables are set
set "ErrorInput="
IF NOT DEFINED WORKINGDIR set ErrorInput=1
IF DEFINED ErrorInput (
ECHO some variables are not set. please set:
ECHO WORKINGDIR[path]
GOTO EOF
)


SET "ALGOIM_DIR=%WORKINGDIR%\Algoim\CppAlgoim"
CD %ALGOIM_DIR%

msbuild /property:Configuration=Release /property:Platform=x64  .\CppAlgoim.vcxproj



:EOF
cd %WORKINGDIR%

ECHO Algoim finished, returning to working directory ...
ECHO =======================
ECHO ^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>