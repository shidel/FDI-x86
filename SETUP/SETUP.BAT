@echo off

if "%0" == "SETUP" goto GoodCWD
if "%0" == "setup" goto GoodCWD
if "%0" == "SETUP.BAT" goto GoodCWD
if "%0" == "setup.bat" goto GoodCWD

echo ERROR: The Setup program must only be executed from it's directory.
echo Please change directories and re-launch the SETUP program.
goto End

:GoodCWD

if "%LANGFILE%" == "" goto SetLangFile

:Startup

if "%1" == "LANG" goto End
if "%1" == "OPTION" goto Option
if "%1" == "BOOT" goto CheckState
if "%1" == "RELOAD" goto Reload
if "%1" == "help" goto ShowHelp
if "%1" == "HELP" goto ShowHelp

if not exist FREEDOS\BIN\COMMAND.COM goto ERROR_MissingFreeCOM

rem Unless we were told that it is boot time or we've already reloaded,
rem respawn ourself using FreeCOM to insure proper shell and preserve env table
FREEDOS\BIN\COMMAND.COM /E:4096 /C %0 RELOAD %1 %2 %3 %4 %5 %6 %7 %8 %9
set LANGFILE=
goto End


:SetLangFile
if "%LANG%" == "" goto SetEnglish
if not exist FREEDOS\NLS\SETUP.%LANG% goto SetEnglish
set LANGFILE=FREEDOS\NLS\SETUP.%LANG%
goto Startup

:SetEnglish
set LANGFILE=FREEDOS\NLS\SETUP.%LANG%
if exist %LANGFILE% goto Startup
set LANGFILE=%0.BAT
if exist %LANGFILE% goto Startup
set LANGFILE=%0
goto Startup

:Option
set VAL=
echo %2| vstr /n /u | set /p VAL=
if "%VAL%" == "" goto Option

if "%VAL%" == "ADV" goto SetAdvanced
if "%VAL%" == "EXPERT" goto SetAdvanced
if "%VAL%" == "AUTO" goto SetAutomatic
if "%VAL%" == "FORCE" goto SetForced
if "%VAL%" == "HELP" goto ShowHelp

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

:ShowHelp
for %%i in (0 1 2 3 4 5 6 7 8 9 10) do vecho /T %LANGFILE% HELP_%%i
goto ErrorExit

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

:ERROR_Option
vecho /T %LANGFILE% ERROR_Option %2
goto ErrorExit

:ERROR_NoCfgEnv
vecho /T %LANGFILE% ERROR_NoCfgEnv
goto ErrorExit

:ERROR_NotFreeCOM
vecho /T %LANGFILE% ERROR_NotFreeCOM
goto ErrorExit

:ERROR_MissingFreeCOM
vecho /T %LANGFILE% ERROR_MissingFreeCOM
goto ErrorExit

:ERROR_MissingAUTOEXEC
vecho /T %LANGFILE% ERROR_MissingAUTOEXEC
goto ErrorExit

:ErrorExit
verrlvl 1
goto Cleanup

rem Batch completed, shutdown
:Done

:Cleanup
set LANGFILE=
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