@echo off

if not exist FREEDOS\BIN\COMMAND.COM goto ERROR_MissingFreeCOM

if "%1" == "BOOT" goto CheckState
if "%1" == "RELOAD" goto Reload
if "%1" == "OPTION" goto Option

rem Unless we were told that it is boot time or we've already reloaded,
rem respawn ourself using FreeCOM to insure proper shell and preserve env table
FREEDOS\BIN\COMMAND.COM /E:4096 /C %0 RELOAD %1 %2 %3 %4 %5 %6 %7 %8 %9
goto End

:Option
set VAL=
echo %2| vstr /n /u | set /p VAL=
if "%VAL%" == "" goto Option

if "%VAL%" == "ADV" goto SetAdvanced
if "%VAL%" == "EXPERT" goto SetAdvanced
if "%VAL%" == "AUTO" goto SetAutomatic
if "%VAL%" == "FORCE" goto SetForced

echo %VAL%| vstr /n /f : 1 | vstr /n /s ' ' '' | set /p VALD=
if "%VALD%" == "%VAL%" goto ERROR_Option
vfdutil /d %VALD%: | set /p VALD=
vfdutil /p %VAL%\ | set /p VALP=

vfdutil /x /d %VALD%
if errorlevel 3 goto OptionDrive
goto ERROR_Option

:OptionDrive
echo %VALD% %VALP%

set VAL=
set VALD=
set VALP=

:NextOption
verrlvl 0
if not "%3" == "" call %0 OPTION %3 %4 %5 %6 %7 %8 %9
goto End

:SetAdvanced
set ADVANCED=yes
goto NextOption

:SetAutomatic
set AUTOMATIC=yes
goto NextOption

:SetForced
set FORCE=yes
goto NextOption

:Reload
if "%_CWD%" == "" goto ERROR_NotFreeCOM

rem Reset Environment Variables using FDAUTO.BAT
set AUTOFILE=
set CFGFILE=
if not exist %_CWD%\FDAUTO.BAT goto ERROR_MissingAUTOEXEC
call %_CWD%\FDAUTO.BAT ENV_ONLY
if "%AUTOFILE%" == "" goto ERROR_NoCfgEnv
if "%CFGFILE%" == "" goto ERROR_NoCfgEnv

rem Installer Defaults settings (User mode, manual launch only)
set SOURCE=%_CWD%
set AUTOMATIC=no
set ADVANCED=no
set FORCE=no
set TDRIVE=C:
set TDOSDIR=%TDRIVE%\FDOS

if not "%2" == "" call %0 OPTION %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 goto Cleanup

:CheckState

:Install
echo Target Drive %TDRIVE%

goto Done

rem Early stage untranslated error messages.
:ERROR_Option
echo Unknown or invalid command line option.
verrlvl 1
goto Cleanup

:ERROR_NoCfgEnv
echo Unable to determine basic system configuration and path settings.
goto Cleanup

:ERROR_NotFreeCOM
echo This batch file requires the FreeCOM or compatible shell for FreeDOS.
goto Cleanup

:ERROR_MissingFreeCOM
echo Unable to locate FreeDOS's command shell FreeCOM.
goto Cleanup

:ERROR_MissingAUTOEXEC
echo Unable to locate FreeDOS's startup batch file FDAUTO.BAT.
goto Cleanup

rem Batch completed, shutdown
:Done

:Cleanup
set SOURCE=
set AUTOMATIC=
set ADVANCED=
set FORCE=
set TDRIVE=
set TDOSDIR=
set VAL=
set VALD=
set VALP=

rem Exit point
:End