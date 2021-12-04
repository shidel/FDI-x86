@echo off

SET DOSDRV=%_CWD%
for %%i in ( A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ) do if "%_CWD%" == "%%i:\" set DOSDRV=%%i:

SET DOSDIR=%DOSDRV%\FREEDOS
SET COMSPEC=%dosdir%\BIN\COMMAND.COM
SET LANG=EN

SET NLSPATH=%dosdir%\NLS
SET HELPPATH=%dosdir%\HELP

SET PATH=%dosdir%\BIN;%dosdir%\LINKS

SET DIRCMD=/P /OGN /Y
SET COPYCMD=/-Y

SET OS_NAME=$OS_NAME$
SET OS_VERSION=$OS_VERSION$
SET CFGPATH=
SET AUTOFILE=%DOSDRV%\$AUTOEXEC$
SET CFGFILE=%DOSDRV%\$CONFIG$
SET DOSDRV=

alias reboot=fdapm warmboot
alias reset=fdisk /reboot
alias halt=fdapm poweroff
alias shutdown=fdapm poweroff

if "%1" == "ENV_ONLY" goto Done

if not exist %dosdir%\bin\lbacache.com goto NoLBACache
vecho /g
LBACACHE.COM buf 20 flop
if errorlevel 1 goto NoLBACache
if not exist %dosdir%\bin\tickle.com goto NoLBACache
TICKLE.COM
:NoLBACache

if exist %dosdir%\bin\fdassist.bat call %dosdir%\bin\fdassist.bat

if exist %DOSDIR%\BIN\FDBANNER.COM FDBANNER.COM
if exist SETUP.BAT CALL SETUP.BAT BOOT
if exist %DOSDIR%\BIN\WELCOME.BAT call WELCOME.BAT BOOT

:Done