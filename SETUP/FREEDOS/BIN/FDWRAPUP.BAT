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
set TEMP=%DOSDIR%\TEMP
set PARENT=
set EXITCODE=0
set AUTOFILE=C:\$AUTOEXEC$
set CFGFILE=C:\$CONFIG$
alias reboot=%DOSDIR%\BIN\fdapm warmboot
alias reset=%DOSDIR%\BIN\fdisk /reboot
alias halt=%DOSDIR%\BIN\fdapm poweroff
alias shutdown=%DOSDIR%\BIN\fdapm poweroff
cd \
%comspec% %DOSDIR%\BIN /E:1024 /P=%DOSDIR%\BIN\FDWRAPUP.BAT

:End