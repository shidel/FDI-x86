@echo off

rem FreeDOS 1.3+ Installer version 1.00.
rem Released Under GPL v2.0 License.
rem Copyright 2020 Jerome Shidel.

rem vecho /g /p /fDarkGray (%1 %2 %3 %4 %5 %6 %7 %8 %9) /fGray

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
if "%1" == "OPTION" goto Option
if "%1" == "PRELOAD" goto Option
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
goto LangFileDone

:SetEnglish
set LANGFILE=FREEDOS\NLS\SETUP.%LANG%
if exist %LANGFILE% goto LangFileDone
set LANGFILE=%0.BAT
if exist %LANGFILE% goto LangFileDone
set LANGFILE=%0

:LangFileDone
goto Startup

:ChangeLangFile
set LANG=%2
set LANGFILE=FREEDOS\NLS\SETUP.%LANG%
goto OptionNext

:Option
if "%2" == "" goto End
if "%2" == "auto" goto SetAutomatic
if "%2" == "AUTO" goto SetAutomatic
if "%2" == "adv" goto SetAdvanced
if "%2" == "ADV" goto SetAdvanced
if "%2" == "force" goto SetForced
if "%2" == "FORCE" goto SetForced
if exist FREEDOS\NLS\SETUP.%2 goto ChangeLangFile
if "%1" == "PRELOAD" goto OptionPreLoad
if "%TEMP%" == "" goto OptionPreLoad

set VAL=
set VALD=
echo %2| vstr /n /d | set /p VAL=
if "%VAL%" == "" goto Option

echo %VAL%| vstr /n /f : 1 | vstr /n /s ' ' '' | set /p VALD=
if "%VALD%" == "%VAL%" goto ERROR_Option
set /e VALD=vfdutil /d %VALD%:
set /e VALP=vfdutil /p %VAL%\

vfdutil /x /d %VALD%
if errorlevel 3 goto OptionDrive
goto ERROR_Option

:OptionDrive
if not "%VALD%" == "" set TDRIVE=%VALD%
if not "%VALP%" == "" set TDOSDIR=%VALP%
set VAL=
set VALD=
set VALP=

:OptionNext
verrlvl 0
if not "%3" == "" call %0 OPTION %3 %4 %5 %6 %7 %8 %9
goto End

:OptionPreload
if not "%TDRIVE%" == "" goto OptionNext
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
if not "%VAL%" == "" set TDRIVE=%VAL%
set VAL=
goto OptionNext

:SetAdvanced
set ADVANCED=yes
set MSG=ADV
goto OptionNext

:SetAutomatic
set AUTOMATIC=yes
goto OptionNext

:SetForced
set FORCE=yes
goto OptionNext

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
set FDISK=%DOSDIR%\bin\fdisk131.exe
if not exist %FDISK% set FDISK=%DOSDIR%\bin\fdisk.exe
set SOURCE=%_CWD%
set AUTOMATIC=no
set ADVANCED=no
set MSG=DEF
set FORCE=no
set TDRIVE=
set TDOSDIR=
set TTMP=
set LAYOUT=
set LOADED=no
set BACKUP=yes
set LABEL=FreeDOS$YEAR$

rem Pre-load some command line options.
if "%LOADED%" == "no" call %0 OPTION %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 goto Cleanup

if "%TDRIVE%" == "" set TDRIVE=C:
if "%TDOSDIR%" == "" set TDOSDIR=%TDRIVE%\FDOS

if not "%1" == "BOOT" goto Install

rem Boot only test for install
vinfo /d %TDRIVE%
if errorlevel 1 goto Install
fc /L FREEDOS\VERSION.FDI %TDOSDIR%\VERSION.FDI>NUL
if errorlevel 1 goto Install
goto Done

:Install
rem Display Welcome Message and prompt to continue
if "%ADVANCED%" == "no" goto Welcome
vecho /g /fGray /bBlack /e
vgotoxy /g up
vline
vecho /g /T %LANGFILE% TITLE %OS_NAME% %OS_VERSION%
vecho /g /T %LANGFILE% COPYRIGHT %OS_NAME% %OS_VERSION%
vecho /g /T %LANGFILE% TRADEMARK %OS_NAME% %OS_VERSION%
vecho /g /fGray /bBlack /e
vgotoxy /g up
vline
vecho /g
:Welcome
vecho /g /T %LANGFILE% WELCOME_%MSG% %OS_NAME% %OS_VERSION%
for %%i in (0 1 2 3 4 5) do vecho /n /g /T %LANGFILE% WELCOME_%%i %OS_NAME% %OS_VERSION%

vecho /g /n /T %LANGFILE% CONTINUE
if "%AUTOMATIC%" == "yes" call %0 YES
if "%AUTOMATIC%" == "no"  choice
if errorlevel 2 goto AbortExit

vecho /g

rem Test Drive State
:TestDrive
vinfo /d %TDRIVE%
if errorlevel 15 goto Partition
if errorlevel 5 goto Format
goto FileSystemTest

:Partition
if "%AUTOMATIC%" == "yes" goto PartitionAuto
if "%ADVANCED%" == "yes" goto PartitionManual

:PartitionAuto
vecho /g /n /T %LANGFILE% PARTITION_AUTO %TDRIVE%
set TDRVID=
if "%TDRIVE%" == "A:" goto NoPartitionAuto
if "%TDRIVE%" == "B:" goto NoPartitionAuto
if "%TDRIVE%" == "C:" set TDRVID=1
if "%TDRIVE%" == "D:" set TDRVID=2
if "%TDRIVE%" == "E:" set TDRVID=3
if "%TDRIVE%" == "F:" set TDRVID=4
if "%TDRIVE%" == "G:" set TDRVID=5
if "%TDRIVE%" == "H:" set TDRVID=6
if "%TDRIVE%" == "I:" set TDRVID=7
if "%TDRIVE%" == "J:" set TDRVID=8
if "%TDRVID%" == "" goto NoPartitionAuto
%FDISK% /info %TDRVID% >NUL
if errorlevel 1 goto NoPartitionAuto

%FDISK% /auto %TDRVID% >NUL
if errorlevel 1 goto NoPartitionAuto
vecho /g /r2 /c32 /T %LANGFILE% SUCCESS

vecho /g /n /T %LANGFILE% PARTITION_MBR %TDRIVE%
%FDISK% /mbr %TDRVID% >NUL
if errorlevel 1 goto NoPartitionAuto
vecho /g /r2 /c32 /T %LANGFILE% SUCCESS

vecho /g /n /T %LANGFILE% PARTITION_ACTIVE %TDRIVE%
%FDISK% /activate:1 %TDRVID% >NUL
if errorlevel 1 goto ManualPartition
vecho /g /r2 /c32 /T %LANGFILE% SUCCESS

:NeedReboot
vecho /g /T %LANGFILE% PARTITION_DONE
vecho /g /n /T %LANGFILE% REBOOT
if "%AUTOMATIC%" == "yes" call %0 YES
if "%AUTOMATIC%" == "no"  choice
if errorlevel 2 goto AbortExit

vecho /n /g /fBlack /e
vpause /d1/t1 postal

goto AbortExit

:NoPartitionAuto
vecho /g /r2 /c32 /T %LANGFILE% FAILED
if "%AUTOMATIC%" == "yes" goto NoPartitionManual
vecho /g
vdelay 1000

:PartitionManual
%FDISK% %TDRVID%
if errorlevel 1 goto NoPartitionManual
goto NeedReboot

:NoPartitionManual
vecho /g /T %LANGFILE% PARTITION_ERROR
goto ErrorExit

:Format
vecho /g /T %LANGFILE% FORMAT %TDRIVE%
if "%AUTOMATIC%" == "yes" goto FormatNormal
if "%ADVANCED%" == "yes" goto FormatAdvanced

:FormatNormal
vecho /n /p /g /T %LANGFILE% FORMAT_DEF %TDRIVE%
if "%AUTOMATIC%" == "yes" call %0 YES
if "%AUTOMATIC%" == "no"  choice
if errorlevel 2 goto AbortExit
goto FormatQuick

:FormatAdvanced
vecho /n /p /g /T %LANGFILE% FORMAT_ADV %TDRIVE%
choice /c:FQN
if errorlevel 3 goto AbortExit
if errorlevel 2 goto FormatQuick

:FormatLong
vecho /g
format %TDRIVE% /V:%LABEL% /U /Z:seriously
goto FormatDone

:FormatQuick
vecho /g
format %TDRIVE% /V:%LABEL% /Q /U /Z:seriously
goto FormatDone

:FormatDone
if errorlevel 1 goto FormatError

:FileSystemTest
vecho /n /g /T %LANGFILE% FILESYSTEM_TEST %TDRIVE%
vfdutil /u %TDRIVE%\TEST????.$$$ >NUL
if errorlevel 1 goto DriveError

if not "%TTMP%" == "" goto DriveDone

vfdutil /u %TDRIVE%\TEMP\TEST????.$$$ >NUL
if errorlevel 1 goto NoTempDir
set TEMP=%TDRIVE%\TEMP
:SubTempDir
set /e TTMP=vfdutil /u %TDRIVE%\TEMP\SETUP???.$$$
if "%TTMP%" == "" goto DriveError

mkdir %TTMP% >NUL
vfdutil /u %TTMP%\TEST????.$$$ >NUL
if errorlevel 1 goto DriveError
set TEMP=%TTMP%
goto DriveDone

:NoTempDir
mkdir %TDRIVE%\TEMP >NUL
vfdutil /u %TDRIVE%\TEMP\TEST????.$$$ >NUL
if errorlevel 1 goto DriveError
set TEMP=%TDRIVE%\TEMP
set TTMP=%TEMP%
goto DriveDone

:DriveDone
vecho /g /r2 /c32 /T %LANGFILE% SUCCESS

rem Final load of command line options.
if "%LOADED%" == "no" call %0 OPTION %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 goto Cleanup
set LOADED=yes

rem Set Language & Keyboard Layout (unused at present, maybe later, maybe not)
:SetLanguage
if "%LANG%" == "" set LANG=EN

:SetKeyboard
if "%LAYOUT%" == ""  set LAYOUT=EN

rem Reset installer language translation file
:ResetLangFile
set LANGFILE=
call %0 LANG %LANG%

rem Configure Target drive and directory (unused at present, can set from
rem the command line)
:SetTarget
if "%AUTOMATIC%" == "yes" goto TargetCheck
if "%ADVANCED%" == "no" goto TargetCheck
vecho /g /p /n /T %LANGFILE% TARGET_ASK %OS_NAME% %OS_VERSION%
set /e REPLY=vask /T %LANGFILE% TARGET_PROMPT %TDOSDIR%
set /e REPLY=vfdutil /p %REPLY%\
vecho /fWhite /bBlack %REPLY% /e /fGray
if "%REPLY%" == "%TDOSDIR%" goto TargetCheck
set /e VALD=vfdutil /d %REPLY%
set /e VALP=vfdutil /p %REPLY%\
if "%VALD%" == "%TDRIVE%" goto SetDOSDIR
:SetDrive
set TDRIVE=%VALD%
set TDOSDIR=%VALP%
set VALD=
set VALP=
vecho /g
vfdutil /x /d %TDOSDIR%
if errorlevel 3 goto TestDrive
vecho /g /n /T %LANGFILE% TARGET_BAD
vecho /g
goto SetTarget

:SetDOSDIR
set TDOSDIR=%VALP%
set VALD=
set VALP=

rem Check for existing Operating System Directory
:TargetCheck
if not exist %TDOSDIR%\NUL goto TargetDone
if "%AUTOMATIC%" == "yes" goto TargetDone
if "%ADVANCED%" == "no" goto TargetDone

vecho /p/g/n /T %LANGFILE% CHANGE_PATH %TDOSDIR%
choice
if errorlevel 2 goto TargetDone
goto SetTarget

:TargetDone


rem Check for OS boot files
:BackupCheck
if exist %TDOSDIR%\NUL goto BackupQuery
if exist %TDRIVE%\FDAUTO.BAT goto BackupQuery
if exist %TDRIVE%\FDCONFIG.SYS goto BackupQuery
if exist %TDRIVE%\AUTOEXEC.BAT goto BackupQuery
if exist %TDRIVE%\CONFIG.SYS goto BackupQuery
if exist %TDRIVE%\KERNEL.SYS goto BackupQuery
if exist %TDRIVE%\COMMAND.COM goto BackupQuery
if exist %TDRIVE%\DRDOS.386 goto BackupQuery
if exist %TDRIVE%\WINA20.386 goto BackupQuery
if exist %TDRIVE%\IBMBIO.COM goto BackupQuery
if exist %TDRIVE%\IBMDOS.COM goto BackupQuery
if exist %TDRIVE%\IO.SYS copy goto BackupQuery
if exist %TDRIVE%\MSDOS.SYS goto BackupQuery
set BACKUP=no
goto BackupDone

:BackupQuery


:BackupDone


goto Done

:DriveError
rem set TTMP=
vecho /g /r2 /c32 /T %LANGFILE% FAILED
vecho /p /g /T %LANGFILE% FILESYSTEM_ERROR %TDRIVE%
goto ErrorExit

:FormatError
vecho /p /g /T %LANGFILE% FORMAT_ERROR %TDRIVE%
goto ErrorExit

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
if "%TTMP%" == "" goto NoTempSpace
if not exist %TTMP%\NUL goto NoTempSpace

deltree /y %TTMP%\*.* >NUL
rmdir %TTMP% >NUL

:NoTempSpace
set LANGFILE=
set LAYOUT=
set SOURCE=
set AUTOMATIC=
set ADVANCED=
set FORCE=
set TDRIVE=
set TDOSDIR=
set TDRVID=
set VAL=
set VALD=
set VALP=
set MSG=
set TTMP=
set LOADED=
set REPLY=
set BACKUP=
set LABEL=
set FDISK=

rem Exit point
:End