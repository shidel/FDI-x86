@echo off

SET DOSDIR=%_CWD%\FREEDOS
SET COMSPEC=%dosdir%\BIN\COMMAND.COM
SET LANG=EN

SET NLSPATH=%dosdir%\NLS
SET HELPPATH=%dosdir%\HELP

SET PATH=%dosdir%\BIN;%dosdir%\LINKS

SET DIRCMD=/P /OGN /Y
SET COPYCMD=/-Y

SET OS_NAME=$OSNAME$
SET OS_VERSION=$OSVER$
SET AUTOFILE=$AUTOEXEC$
SET CFGFILE=$CONFIG$

alias reboot=fdapm warmboot
alias reset=fdisk /reboot
alias halt=fdapm poweroff
alias shutdown=fdapm poweroff

if "%1" == "ENV_ONLY" goto Done

if exist %dosdir%\bin\fdassist.bat call %dosdir%\bin\fdassist.bat

if exist %DOSDIR%\BIN\FDBANNER.BAT call FDBANNER.BAT BOOT
if exist SETUP.BAT CALL SETUP.BAT BOOT
if exist %DOSDIR%\BIN\WELCOME.BAT call WELCOME.BAT BOOT

:Done