@echo off

REM FreeDOS 1.3+ Installer version 1.00.
REM Released Under GPL v2.0 License.
REM Copyright 2020 Jerome Shidel.

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

if "%1" == "YES" goto AnswerYes
if "%1" == "NO" goto AnswerNo
if "%1" == "LANG" goto End
if "%1" == "PRELOAD" goto Preload
if "%1" == "OPTION" goto Option
if "%1" == "BOOT" goto Configure
if "%1" == "RELOAD" goto Reload
if "%1" == "help" goto ShowHelp
if "%1" == "HELP" goto ShowHelp

if not exist FREEDOS\BIN\COMMAND.COM goto ERROR_MissingFreeCOM

rem Unless we were told that it is boot time or we've already reloaded,
rem respawn ourself using FreeCOM to insure proper shell and preserve env table
FREEDOS\BIN\COMMAND.COM /E:4096 /C %0 RELOAD %1 %2 %3 %4 %5 %6 %7 %8 %9
set LANGFILE=
goto End

:AnswerYes
vecho /g /T %LANGFILE% AUTO_YES
verrlvl 1
goto End

:AnswerNo
vecho /g /T %LANGFILE% AUTO_NO
verrlvl 2
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
if "%2" == "auto" goto SetAutomatic
if "%2" == "AUTO" goto SetAutomatic
if "%2" == "adv" goto SetAdvanced
if "%2" == "ADV" goto SetAdvanced
if "%2" == "force" goto SetForced
if "%2" == "FORCE" goto SetForced
if "%TEMP%" == "" goto NextOption

set VAL=
echo %2| vstr /n /l | set /p VAL=
if "%VAL%" == "" goto Option

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

:Preload
if not "%TDRIVE%" == "" goto End
set VAL=
vfdutil /x /d %2
if errorlevel 3 set VAL=C:
if errorlevel 4 set VAL=D:
if errorlevel 5 set VAL=E:
if errorlevel 6 set VAL=F:
if errorlevel 7 set VAL=G:
if errorlevel 8 set VAL=H:
if errorlevel 9 set VAL=I:
if errorlevel 10 set VAL=J:
if errorlevel 11 set VAL=K:
if errorlevel 12 set VAL=L:
if errorlevel 13 set VAL=M:
if errorlevel 14 set VAL=N:
if errorlevel 15 set VAL=O:
if errorlevel 16 set VAL=P:
if errorlevel 17 set VAL=Q:
if errorlevel 18 set VAL=R:
if errorlevel 19 set VAL=S:
if errorlevel 20 set VAL=T:
if errorlevel 21 set VAL=U:
if errorlevel 22 set VAL=V:
if errorlevel 23 set VAL=W:
if errorlevel 24 set VAL=X:
if errorlevel 25 set VAL=Y:
if errorlevel 26 set VAL=Z:
if not "%VAL%" == "" set TDRIVE=%VAL%
set VAL=
verrlvl 0
if not "%3" == "" call %0 PRELOAD %3 %4 %5 %6 %7 %8 %9
goto End

:SetAdvanced
set ADVANCED=yes
set MSG=ADV
goto NextOption

:SetAutomatic
set AUTOMATIC=yes
goto NextOption

:SetForced
set FORCE=yes
goto NextOption

:ShowHelp
vecho /g /T %LANGFILE% TITLE %OS_NAME% %OS_VERSION%
vecho /g /T %LANGFILE% COPYRIGHT
for %%i in (0 1 2 3 4 5 6 7 8 9 10) do vecho /g /T %LANGFILE% HELP_%%i
vecho /g /T %LANGFILE% TRADEMARK
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

:Configure
set SOURCE=%_CWD%
set AUTOMATIC=no
set ADVANCED=no
set MSG=DEF
set FORCE=no
set TDRIVE=
set TDOSDIR=

REM Pre-load some command line options.
if not "%2" == "" call %0 PRELOAD %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 goto Cleanup
if not "%2" == "" call %0 OPTION %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 goto Cleanup

if "%TDRIVE%" == "" set TDRIVE=C:
if "%TDOSDIR%" == "" set TDOSDIR=%TDRIVE%\FDOS

if not "%1" == "BOOT" goto Install

REM Boot only test for install
vinfo /d %TDRIVE%
if errorlevel 1 goto Install
fc /L FREEDOS\VERSION.FDI %TDOSDIR%\VERSION.FDI>NUL
if errorlevel 1 goto Install
goto Done

:Install
REM Display Welcome Message and prompt to continue
vecho /g /T %LANGFILE% TITLE %OS_NAME% %OS_VERSION%
vecho /g
vecho /g /T %LANGFILE% WELCOME_%MSG% %OS_NAME% %OS_VERSION%
for %%i in (0 1 2 3 4 5) do vecho /n /g /T %LANGFILE% WELCOME_%%i %OS_NAME% %OS_VERSION%

vecho /g /n /T %LANGFILE% CONTINUE
if "%AUTOMATIC%" == "yes" call %0 YES
if "%AUTOMATIC%" == "no"  choice
if errorlevel 2 goto AbortExit

REM Test Drive State
vinfo /d %TDRIVE%
if errorlevel 15 goto Partition
if errorlevel 5 goto Format
goto DriveReady

:Partition
if "%AUTOMATIC%" == "yes" goto PartitionAuto
if "%ADVANCED%" == "yes" goto PartitionManual

:PartitionAuto

:PartitionManual

:Format

:DriveReady
goto Done

:ERROR_Option
vecho /g /T %LANGFILE% ERROR_Option %2
goto ErrorExit

:ERROR_NoCfgEnv
vecho /g /T %LANGFILE% ERROR_NoCfgEnv
goto ErrorExit

:ERROR_NotFreeCOM
vecho /g /T %LANGFILE% ERROR_NotFreeCOM
goto ErrorExit

:ERROR_MissingFreeCOM
vecho /g /T %LANGFILE% ERROR_MissingFreeCOM
goto ErrorExit

:ERROR_MissingAUTOEXEC
vecho /g /T %LANGFILE% ERROR_MissingAUTOEXEC
goto ErrorExit

:AbortExit
vecho /g /T %LANGFILE% ABORTED %OS_NAME%

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
set MSG=

rem Exit point
:End