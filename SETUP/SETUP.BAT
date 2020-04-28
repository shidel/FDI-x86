@echo off

rem FreeDOS 1.3+ Installer version 1.00.
rem Released Under GPL v2.0 License.
rem Copyright 2020 Jerome Shidel.

rem vecho /g /p /fDarkGray (%1 %2 %3 %4 %5 %6 %7 %8 %9) /fGray

if "%1" == "YES" goto AnswerYes
if "%1" == "NO" goto AnswerNo
if "%1" == "DBACK" goto DOSBackup
if "%1" == "MKDIR" goto MakeDirectory
if "%1" == "BBACK" goto BootBackup
if "%1" == "SUCCESS" goto SuccessExit
if "%1" == "FAIL" goto FailedExit

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

:MakeDirectory
set /e PARENT=vfdutil /d %2
vfdutil /u %PARENT%\????????.$$$ >NUL
if errorlevel 1 goto ERROR_MakeDir
set /e PARENT=vfdutil /p %2
vfdutil /u %PARENT%\????????.$$$ >NUL
if errorlevel 1 call %0 MKDIR %PARENT%
mkdir %2 >NUL
if errorlevel 1 goto ERROR_MakeDir
goto End

:BootBackup
if "%2" == "" goto End
if exist %TDRIVE%\%2 xcopy %TDRIVE%\%2 %BACKUP% /H /Y >NUL
if errorlevel 1 goto ErrorExit
shift
goto BootBackup

:DOSBackup
if "%2" == "" goto End
if exist %TDOSDIR%\%4\nul goto DOSBackupDir
xcopy %TDOSDIR%\%4 %BACKUP%\ /E /H /Y >NUL
goto DOSBackupCheck
:DOSBackupDir
call %0 MKDIR %BACKUP%\%4
if errorlevel 1 goto AbortExit
xcopy %TDOSDIR%\%4 %BACKUP%\%4\ /E /H /Y >NUL
:DOSBackupCheck
if errorlevel 1 goto ErrorExit
vprogres /fGreen %2 OF %3
goto End

REM ***************************************************************************
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
set PREVOS=
set LOADED=no
set BACKUP=yes
set LABEL=FreeDOS$YEAR$
set LAYOUT=
set FORCEMBR=yes
set SYSFILES=yes
set CFGFILES=yes

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

REM ***************************************************************************
:Install

set TCPU=8086
vinfo /M
if errorlevel 1 set TCPU=186
if errorlevel 2 set TCPU=286
if errorlevel 3 set TCPU=386
if errorlevel 4 set TCPU=486
if errorlevel 5 set TCPU=586
if errorlevel 6 set TCPU=686
if errorlevel 101 set TCPU=DOSBox
if errorlevel 102 set TCPU=QEMU
if errorlevel 103 set TCPU=VirtualBox
if errorlevel 104 set TCPU=VMware
if errorlevel 105 set TCPU=VM

rem Display Welcome Message and prompt to continue
if "%ADVANCED%" == "no" goto Welcome
vecho /g /T %LANGFILE% HRULE
vecho /g /T %LANGFILE% TITLE %OS_NAME% %OS_VERSION%
vecho /g /T %LANGFILE% COPYRIGHT %OS_NAME% %OS_VERSION%
vecho /g /T %LANGFILE% TRADEMARK %OS_NAME% %OS_VERSION%
vecho /g /T %LANGFILE% HRULE
vecho /g

:Welcome
vecho /g /T %LANGFILE% WELCOME_%MSG% %OS_NAME% %OS_VERSION%
for %%i in (0 1 2 3 4 5) do vecho /n /g /T %LANGFILE% WELCOME_%%i %OS_NAME% %OS_VERSION%

vecho /g /n /T %LANGFILE% CONTINUE
if "%AUTOMATIC%" == "yes" call %0 YES
if "%AUTOMATIC%" == "no"  choice
if errorlevel 2 goto UserAbortExit

vecho /g

rem Test Drive State
:TestDrive
rem Possible no pipe support yet, so uberdumb partition testing mode.
vfdutil /u %TDRIVE%\TEST????.$$$ >NUL
if not errorlevel 1 goto FileSystemTest
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
if errorlevel 2 goto UserAbortExit

vecho /g /n /fBlack /e
vpause /d1/t1 postal

goto ErrorExit

:NoPartitionAuto
vecho /g /r2 /c32 /T %LANGFILE% FAILED
if "%AUTOMATIC%" == "yes" goto ERROR_Partition
vecho /g
vdelay 1000

:PartitionManual
%FDISK% %TDRVID%
if errorlevel 1 goto ERROR_Partition
goto NeedReboot

:Format
vecho /g /T %LANGFILE% FORMAT %TDRIVE%
if "%AUTOMATIC%" == "yes" goto FormatNormal
if "%ADVANCED%" == "yes" goto FormatAdvanced

:FormatNormal
vecho /g /n /p /T %LANGFILE% FORMAT_DEF %TDRIVE%
if "%AUTOMATIC%" == "yes" call %0 YES
if "%AUTOMATIC%" == "no"  choice
if errorlevel 2 goto UserAbortExit
goto FormatQuick

:FormatAdvanced
vecho /g /n /p /T %LANGFILE% FORMAT_ADV %TDRIVE%
choice /c:FQN
if errorlevel 3 goto UserAbortExit
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
if errorlevel 1 goto ERROR_Format

REM ***************************************************************************

:FileSystemTest
vecho /g /n /T %LANGFILE% FILESYSTEM_TEST %TDRIVE%
vfdutil /u %TDRIVE%\TEST????.$$$ >NUL
if errorlevel 1 goto ERROR_FileSystem

if not "%TTMP%" == "" goto DriveDone

vfdutil /u %TDRIVE%\TEMP\TEST????.$$$ >NUL
if errorlevel 1 goto NoTempDir
set TEMP=%TDRIVE%\TEMP
:SubTempDir
set /e TTMP=vfdutil /u %TDRIVE%\TEMP\SETUP???.$$$
if "%TTMP%" == "" goto ERROR_FileSystem

mkdir %TTMP% >NUL
vfdutil /u %TTMP%\TEST????.$$$ >NUL
if errorlevel 1 goto ERROR_FileSystem
set TEMP=%TTMP%
goto DriveDone

:NoTempDir
mkdir %TDRIVE%\TEMP >NUL
vfdutil /u %TDRIVE%\TEMP\TEST????.$$$ >NUL
if errorlevel 1 goto ERROR_FileSystem
set TEMP=%TDRIVE%\TEMP
set TTMP=%TEMP%
goto DriveDone

:DriveDone
vecho /g /r2 /c32 /T %LANGFILE% SUCCESS

rem Final load of command line options.
if "%LOADED%" == "no" call %0 OPTION %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 goto Cleanup
set LOADED=yes

REM ***************************************************************************

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
vecho /g /fWhite /bBlack %REPLY% /e /fGray
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

vecho /g/p/n /T %LANGFILE% CHANGE_PATH %TDOSDIR%
choice
if errorlevel 2 goto TargetDone
goto SetTarget

:TargetDone

rem Check for OS boot files
:BackupCheck
set PREVOS=yes
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
set PREVOS=no
:BackupDisable
set BACKUP=no
goto BackupDone

:BackupQuery
vecho /g /p /n /T %LANGFILE% BACKUP_OLD %TDRIVE%
if "%AUTOMATIC%" == "yes" call %0 YES
if "%AUTOMATIC%" == "no"  choice
if errorlevel 2 goto BackupDisable

set /e BACKUP=vfdutil /u %TDRIVE%\BACKUP.???
if errorlevel 1 set /e BACKUP=vfdutil /u %TDRIVE%\FDBACKUP.???
if errorlevel 1 goto BackupSelect

if "%AUTOMATIC%" == "yes" goto BackupDone
if "%ADVANCED%" == "yes" goto BackupSelect
goto BackupDone

:BackupSelect
if "%AUTOMATIC%" == "yes" goto ERROR_CfgBackup

vecho /g /p /n /T %LANGFILE% BACKUP_ASK
set /e REPLY=vask /T %LANGFILE% TARGET_PROMPT %BACKUP%
set /e BACKUP=vfdutil /p %REPLY%\
vecho /g/fWhite /bBlack %BACKUP% /e /fGray

set /e REPLY=vfdutil /u %BACKUP%
if not errorlevel 1 goto BackupDone

vecho /g /p /T %LANGFILE% BACKUP_BAD
goto BackupSelect

:BackupDone

if "%PREVOS%" == "no" goto PrevOSDone
set PREVOS=overwrite

if "%AUTOMATIC%" == "yes" goto NoAdvOptions
if "%ADVANCED%" == "no" goto NoAdvOptions

vecho /g /p /n /T %LANGFILE% DELETE_OLD %TDOSDIR%
choice
if errorlevel 2 goto PrevOSDone
set PREVOS=delete
:PrevOSDone

if "%TCPU%" == "DOSBox" goto NoForceMBR
rem Force an update to the MBR?
vecho /g /p /n /T %LANGFILE% FORCE_MBR %TDRIVE%
choice
if not errorlevel 2 goto ForceMBRDone
:NoForceMBR
set FORCEMBR=no
:ForceMBRDone

rem Transfer System Files?
vecho /g /p /n /T %LANGFILE% SYS_FILES %TDRIVE%
choice
if not errorlevel 2 goto SYSFILESDone
set SYSFILES=no
:SYSFILESDone

rem Update Config Files?
vecho /g /p /n /T %LANGFILE% CFG_FILES %TDRIVE%
choice
if not errorlevel 2 goto CFGFILESDone
set CFGFILES=no
:CFGFILESDone

:NoAdvOptions

REM ***************************************************************************

rem Display Setings
:DisplaySettings
if "%ADVANCED%" == "no" goto InstallNow

vecho /p /g /T %LANGFILE% STATUS_MSG
vecho /g /T %LANGFILE% STATUS_CPU %TCPU%
vecho /g /T %LANGFILE% STATUS_DRV %TDRIVE%
vecho /g /T %LANGFILE% STATUS_DOS %TDOSDIR%
vecho /g /T %LANGFILE% STATUS_BAK %BACKUP%
vecho /g /T %LANGFILE% STATUS_POS %PREVOS%
vecho /g /T %LANGFILE% STATUS_MBR %FORCEMBR%
vecho /g /T %LANGFILE% STATUS_SYS %SYSFILES%
vecho /g /T %LANGFILE% STATUS_CFG %CFGFILES%

rem Reaty to Install, procede...
:InstallNow

vecho /g /p /T %LANGFILE% INSTALL_NOW %OS_NAME% %OS_VERSION%
vecho /g /n /T %LANGFILE% CONTINUE
if "%AUTOMATIC%" == "yes" call %0 YES
if "%AUTOMATIC%" == "no"  choice
if errorlevel 2 goto UserAbortExit

vecho /g /p /T %LANGFILE% HRULE

rem Do Backup

set TPRTID=0
set TDRVID=1
if "%TCPU%" == "DOSBox" goto NoFindPartID
%FDISK% %TDRVID% | vstr /f %TDRIVE% 2- | vstr /i/b/f ' ' 1 | set /p TPRTID=
if not "%TPRTID%" == "" goto NoFindPartID
set TDRVID=2
%FDISK% %TDRVID% | vstr /f %TDRIVE% 2- | vstr /i/b/f ' ' 1 | set /p TPRTID=
if not "%TPRTID%" == "" goto NoFindPartID
set TDRVID=3
%FDISK% %TDRVID% | vstr /f %TDRIVE% 2- | vstr /i/b/f ' ' 1 | set /p TPRTID=
if not "%TPRTID%" == "" goto NoFindPartID
set TDRVID=4
%FDISK% %TDRVID% | vstr /f %TDRIVE% 2- | vstr /i/b/f ' ' 1 | set /p TPRTID=
if not "%TPRTID%" == "" goto NoFindPartID
goto ERROR_NoPartition
:NoFindPartID

rem Make Backup directory
if "%BACKUP%" == "no" goto NoDoBackup
vecho /g /p /T %LANGFILE% DO_BACKUP %BACKUP%
vecho /g
vprogres /fGreen 0 of 1
call %0 MKDIR %BACKUP%
if errorlevel 1 goto ERROR_MakeDir

rem Backup Master Boot Record
if "%TCPU%" == "DOSBox" goto NoDoMBRBackup
pushd
vfdutil /c /p %BACKUP%\
%FDISK% %TDRVID% /SMBR >NUL
if errorlevel 1 goto FailedDoMBRBackup
popd
goto NoDoMBRBackup
:FailedDoMBRBackup
popd
goto ERROR_MBRBackup
:NoDoMBRBackup

rem Backup System and Configuration files.
rem yes, it would be a little faster to just test and do each file without
rem a callback. But, this is easier to read and maintain...
call %0 BBACK FDAUTO.BAT FDCONFIG.SYS AUTOEXEC.BAT CONFIG.SYS KERNEL.SYS COMMAND.COM
if errorlevel 1 goto ERROR_BackupCfg
call %0 BBACK IO.SYS MSDOS.SYS WINA20.386 IBMBIO.COM IBMDOS.COM DRDOS.386
if errorlevel 1 goto ERROR_BackupCfg

rem Backup Old OS Directory
if not exist %TDOSDIR%\NUL goto NoDoBackup
veach /A+ /D %TDOSDIR%\*.* /X %0 DBACK @ # *
if errorlevel 1 goto ERROR_BackupOS
call %0 SUCCESS

:NoDoBackup

rem Do Deletes
if "%PREVOS%" == "overwrite" goto NoDoErase
vecho /g /p /T %LANGFILE% DO_ERASE %TDOSDIR%
call %0 SUCCESS
:NoDoErase

rem Do System Transfer
if "%SYSFILES%" == "no" goto NoDoSysFiles
vecho /g /p /T %LANGFILE% DO_SYSFILES %TDRIVE%
call %0 SUCCESS
:NoDoSysFiles

rem Do MBR Update
if "%FORCEMBR%" == "no" goto NoDoForceMBR
vecho /g /p /T %LANGFILE% DO_FORCEMBR %TDRIVE%
call %0 SUCCESS
:NoDoForceMBR

rem Do Config File Transfer
if "%CFGFILES%" == "no" goto NoDoCfgFiles
vecho /g /p /T %LANGFILE% DO_CFGFILES %TDRIVE%
call %0 SUCCESS
:NoDoCfgFiles

rem Extract Files
vecho /g /p /T %LANGFILE% DO_INSTALL %OS_NAME% %TCPU%
call %0 SUCCESS

rem Adjust LST Files
vecho /g /p /T %LANGFILE% DO_ADJUST
call %0 SUCCESS

rem Done Reboot

vecho /g /p /T %LANGFILE% HRULE
vecho /g /p /T %LANGFILE% DONE_NOW %OS_NAME% %OS_VERSION%
vecho /g /p /n /T %LANGFILE% REBOOT_NOW
if "%AUTOMATIC%" == "yes" call %0 YES
if "%AUTOMATIC%" == "no"  choice
if errorlevel 2 goto NoDoReboot

vecho /g /p /T %LANGFILE% REMOVE_MEDIA

:NoDoReboot
vecho /g
goto Done

REM ***************************************************************************

:ERROR_Option
vecho /g /N /T %LANGFILE% ERROR_MINOR
vecho /g /T %LANGFILE% ERROR_Option %2
goto ErrorExit

:ERROR_CfgBackup
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /p /T %LANGFILE% ERROR_CfgBackup
goto AbortExit

:ERROR_FileSystem
rem set TTMP=
vecho /g /r2 /c32 /T %LANGFILE% FAILED
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /p /g /T %LANGFILE% ERROR_FileSystem %TDRIVE%
goto AbortExit

:ERROR_Partition
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_Partition
goto AbortExit

:ERROR_NoPartition
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_NoPartition %TDRIVE%
goto AbortExit

:ERROR_Format
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /p /g /T %LANGFILE% FORMAT_ERROR %TDRIVE%
goto AbortExit

:ERROR_NoCfgEnv
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_NoCfgEnv
goto AbortExit

:ERROR_NotFreeCOM
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_NotFreeCOM
goto AbortExit

:ERROR_MissingFreeCOM
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_MissingFreeCOM
goto AbortExit

:ERROR_MissingAUTOEXEC
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_MissingAUTOEXEC
goto AbortExit

:ERROR_MakeDir
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_MakeDir %2
goto AbortExit

:ERROR_MBRBackup
call %0 FAIL
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_MBRBackup %TDRVID%
goto AbortExit

:ERROR_BackupCfg
call %0 FAIL
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_BackupCfg
goto AbortExit

:ERROR_BackupOS
call %0 FAIL
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_BackupOS
goto AbortExit

:SuccessExit
vecho /g /n /fGray /e
vgotoxy /g eot right
vecho /g /r2 /c32 /T %LANGFILE% SUCCESS
goto End

:FailedExit
vecho /g /n /fGray /e
vgotoxy /g eot right
vecho /g /r2 /c32 /T %LANGFILE% FAILED
vecho /g
verrlvl 1
goto End

:UserAbortExit

:AbortExit
vecho /g /p /T %LANGFILE% ABORTED %OS_NAME% %OS_VERSION%

:ErrorExit
set EXITCODE=1
goto Cleanup

rem Batch completed, shutdown
:Done
set EXITCODE=0

:Cleanup
if "%TTMP%" == "" goto NoTempSpace
if not exist %TTMP%\NUL goto NoTempSpace

deltree /y %TTMP%\*.* >NUL
rmdir %TTMP% >NUL

:NoTempSpace
rem set >ENV.TXT
rem Internal and processing variables
set LANGFILE=
set SOURCE=
set AUTOMATIC=
set ADVANCED=
set FORCE=
set TDRVID=
set TPRTID=
set VAL=
set VALD=
set VALP=
set MSG=
set TTMP=
set LOADED=
set REPLY=
set PAERNT=
set SEARCH=

rem Install variables
set TDRIVE=
set TDOSDIR=
set TCPU=
set LAYOUT=
set BACKUP=
set LABEL=
set FDISK=
set PREVOS=
set FORCEMBR=
set SYSFILES=
set CFGFILES=

verrlvl %EXITCODE%
set EXITCODE=

rem Exit point
:End