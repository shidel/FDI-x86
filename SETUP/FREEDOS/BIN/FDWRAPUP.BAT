@echo off

if "%1" == "CMD" goto DoWrapUp
if "%1" == "REBOOT" goto DoWrapUp
goto End

:DoWrapUp
set TDONE=
if "%TTMP%" == "" goto NoTempSpace
if not exist %TTMP%\NUL goto NoTempSpace
deltree /y %TTMP%\*.* >NUL
rmdir %TTMP% >NUL
:NoTempSpace
set TTMP=
if "%1" == "CMD" goto NoReboot
vpause /d 1 POSTAL
:NoReboot
%comspec% \%DOSDIR%\BIN /E:1024 /P

:End