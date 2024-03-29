@echo off

SET DOSDRV=%_CWD%
for %%i in ( A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ) do if "%_CWD%" == "%%i:\" set DOSDRV=%%i:

SET DOSDIR=%DOSDRV%\FREEDOS
rem SET COMSPEC=%dosdir%\BIN\COMMAND.COM
if "%1" == "ENV_ONLY"  goto SkipLocalize
SET LANG=EN
SET TZ=EST
:SkipLocalize

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

if not exist %dosdir%\bin\setlang.bat goto NoSetLang
if "%config%"=="1" set LANG=EN
if "%config%"=="2" set LANG=ES
if "%config%"=="3" set LANG=FR
if "%config%"=="4" set LANG=DE
if "%config%"=="5" set LANG=TR
if "%config%"=="6" set LANG=SV
call %dosdir%\bin\setlang.bat SIMPLE %LANG%
:NoSetLang

if exist %dosdir%\bin\fdassist.bat call %dosdir%\bin\fdassist.bat

if exist %DOSDIR%\BIN\FDBANNER.COM FDBANNER.COM
if exist SETUP.BAT CALL SETUP.BAT BOOT
if errorlevel 1 goto Done
if exist %DOSDIR%\BIN\WELCOME.BAT call WELCOME.BAT BOOT

:Done