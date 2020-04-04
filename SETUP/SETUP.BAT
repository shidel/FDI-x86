@echo off

if not exist FREEDOS\BIN\COMMAND.COM goto MissingFreeCOM

if "%1" == "BOOT" goto CheckState
if "%1" == "RELOAD" goto Reload

FREEDOS\BIN\COMMAND.COM /E:4096 /C %0 RELOAD %1 %2 %3 %4 %5 %6 %7 %8 %9
goto End

:Reload
if "%_CWD%" == "" goto NotFreeCOM

REM Reset Environment Variables using FDAUTO.BAT
SET AUTOFILE=
SET CFGFILE=
if not exist %_CWD%\FDAUTO.BAT goto MissingFDAUTO
call FDAUTO.BAT ENV_ONLY
if "%AUTOFILE%" == "" goto NoCfgEnv
if "%CFGFILE%" == "" goto NoCfgEnv

:CheckState


goto Done

:NoCfgEnv
echo Unable to determine basic system configuration and path settings.
goto End

:NotFreeCOM
echo This batch file requires the FreeCOM or compatible shell for FreeDOS.
goto End

:MissingFreeCOM
echo Unable to locate FreeDOS's command shell FreeCOM.
goto End

:MissingFDAUTO
echo Unable to locate FreeDOS's startup batch file FDAUTO.BAT.
goto End

:Done
echo Hello %1 %2 %3

:End