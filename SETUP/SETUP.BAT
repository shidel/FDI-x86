@echo off

rem FreeDOS 1.3+ Installer, version 2022.
rem GNU General Public License, (any version)
rem Copyright 2020-2022 Jerome Shidel.

set XBAT=%0
if exist %0.BAT set XBAT=%0.BAT

REM ***************************************************************************
REM Some FreeCOM Tests
if "%_CWD%" == "" goto NotFreeCOM
if /I "A" == "a" goto ProbabyFreeCOM
goto NotFreeCOM
:ProbabyFreeCOM

REM ***************************************************************************
REM internal commands recursively executed by the installer itself
if "%1" == "OPTION" goto Option
if "%1" == "YES" goto AnswerYes
if "%1" == "NO" goto AnswerNo
if "%1" == "DBACK" goto DOSBackup
if "%1" == "ULST" goto UpdateLST
if "%1" == "MKDIR" goto MakeDirectory
if "%1" == "BBACK" goto BootBackup
if "%1" == "CATTR" goto ClearAttributes
if "%1" == "DEL" goto DeleteFiles
if "%1" == "XFR" goto CopyConfigFiles
if "%1" == "SUCCESS" goto SuccessExit
if "%1" == "FAIL" goto FailedExit
if "%1" == "EXTRACT" goto ExtractFiles
if "%1" == "PRELOAD" goto OptionPreload
if "%1" == "PERMS" goto AdjustPermissions

REM ***************************************************************************
REM make sure batch was executed from current Directory. Does not guarantee it
REM is in the PATHSPEC somewhere. :-(
if /I "%0" == "SETUP.BAT" goto GoodCWD
if /I "%0" == "SETUP" goto GoodCWD
echo ERROR: The Setup program must only be executed from it's directory.
echo Please change directories and re-launch the SETUP program.
goto End
:GoodCWD

REM When booted we want to draw an HRULE bellow the banner
if /I "%1" == "BOOT" goto BootMode
goto NotBootMode
:BootMode
set BOOTED=yes
shift
:NotBootMode

if not exist FREEDOS\BIN\COMMAND.COM goto ERROR_MissingFreeCOM
if /I "%1" == "HELP" goto ShowHelp

REM ***************************************************************************
REM if needed, set the NLS translation file for the installer
if "%LANG%" == "" SET LANG=EN
if not "%LANGFILE%" == "" goto LangFileDone
if not exist FREEDOS\NLS\SETUP.%LANG% goto SetEnglish
set LANGFILE=FREEDOS\NLS\SETUP.%LANG%
goto LangFileDone

:SetEnglish
set LANGFILE=FREEDOS\NLS\SETUP.EN
if exist %LANGFILE% goto LangFileDone
set LANGFILE=%XBAT%
:LangFileDone

rem Reset Environment Variables using FDAUTO.BAT
set AUTOFILE=
set CFGFILE=
if not exist %_CWD%\FDAUTO.BAT goto ERROR_MissingAUTOEXEC
call %_CWD%\FDAUTO.BAT ENV_ONLY
if "%AUTOFILE%" == "" goto ERROR_NoCfgEnv
if "%CFGFILE%" == "" goto ERROR_NoCfgEnv

rem Initialize installer variables
set FDISK=FDISK.EXE
set AUTOMATIC=no
set ADVANCED=no
set MSG=DEF
set FORCE=no
set USBMODE=no
set TDRIVE=
set TDOSDIR=
set TBHD=C:
set TSRC=%_CWD%
set TSLICE=%_CWD%\SLICED
if exist %TSLICE%\FREEDOS.SAF goto NoSliceSearch
set TSLICE=%_CWD%
:NoSliceSearch
set TTMP=
set TSWAP=
set PREVOS=
set BACKUP=yes
set LABEL=$OS_VOLUME$
set LAYOUT=
set FORCEMBR=maybe
set SYSFILES=yes
set CFGFILES=yes
set XOPTS=/Y /R /H /Q
set COPTS=/Y /B
rem Boots 8086 Kernel and it is in same dir as SETUP.BAT
set KERNL=KERNEL.SYS
set TMODE=
set OCPU=
set TDONE=

if "%1" == "" goto NoUserOptions
call %XBAT% PRELOAD %1 %2 %3 %4 %5 %6 %7 %8 %9
call %XBAT% OPTION %1 %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 goto Cleanup
:NoUserOptions

goto Configure

REM ***************************************************************************
:Option
if "%2" == "" goto End
if /I "%2" == "AUTO" goto SetAutomatic
if /I "%2" == "ADV" goto SetAdvanced
if /I "%2" == "FORCE" goto SetForced
if /I "%2" == "INFO" goto SetInfoMode
if /I "%2" == "MBR" goto SetMBRMode
if /I "%2" == "USB" goto SetUSBMode
if "%2" == "8086" goto OptionCPU
if "%2" == "186" goto OptionCPU
if "%2" == "286" goto OptionCPU
if "%2" == "386" goto OptionCPU
if "%2" == "486" goto OptionCPU
if "%2" == "586" goto OptionCPU
if "%2" == "686" goto OptionCPU
if /I "%2" == "DBX" goto OptionCPU
if /I "%2" == "QEM" goto OptionCPU
if /I "%2" == "VBX" goto OptionCPU
if /I "%2" == "VMW" goto OptionCPU
if /I "%2" == "EMU" goto OptionCPU

if exist FREEDOS\NLS\SETUP.%2 goto ChangeLangFile

REM no temp dir so cannot pipe stuff, yet.
if not "%TEMP%" == "" goto End

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

:AnswerYes
vecho /g /T %LANGFILE% AUTO_YES
verrlvl 1
goto End

:AnswerNo
vecho /g /T %LANGFILE% AUTO_NO
verrlvl 2
goto End

:ChangeLangFile
set LANG=%2
set LANGFILE=FREEDOS\NLS\SETUP.%LANG%
goto OptionNext

:OptionCPU
set OCPU=%2
goto OptionNext

:OptionDrive
if not "%VALD%" == "" set TDRIVE=%VALD%
if not "%VALP%" == "" set TDOSDIR=%VALP%
set VAL=
set VALD=
set VALP=

:OptionNext
verrlvl 0
if not "%3" == "" call %XBAT% OPTION %3 %4 %5 %6 %7 %8 %9
goto End

:OptionPreload
if not "%TDRIVE%" == "" goto OptionNext
set VAL=
vinfo /k 2 %2
if errorlevel 59 goto OptionNext
if errorlevel 58 goto OptionCheckDrive
goto OptionNext
:OptionCheckDrive
vinfo /k 1 %2
if errorlevel 65 set VAL=A:
if errorlevel 66 set VAL=B:
if errorlevel 67 set VAL=C:
if errorlevel 68 set VAL=D:
if errorlevel 69 set VAL=E:
if errorlevel 70 set VAL=F:
if errorlevel 71 set VAL=G:
if errorlevel 72 set VAL=H:
if errorlevel 73 set VAL=I:
if errorlevel 74 set VAL=J:
if errorlevel 75 set VAL=
if not "%VAL%" == "" set TDRIVE=%VAL%
set VAL=
goto OptionNext

:SetAdvanced
set ADVANCED=yes
set MSG=ADV
set SHR=
goto OptionNext

:SetAutomatic
set AUTOMATIC=yes
goto OptionNext

:SetForced
set FORCE=yes
goto OptionNext

:SetInfoMode
set TMODE=INFO
goto OptionNext

:SetUSBMode
set USBMODE=yes
if "%_CWD%" == "C:\" set TDRIVE=D:
goto OptionNext

:SetMBRMode
if "%TMODE%" == "" set TMODE=MBR
set FORCEMBR=yes
goto OptionNext

:ShowHelp
vecho /g /T %LANGFILE% TITLE %OS_NAME% %OS_VERSION%
vecho /g /T %LANGFILE% COPYRIGHT
for %%i in (0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15) do vecho /g /T %LANGFILE% HELP_%%i
vecho /g /T %LANGFILE% TRADEMARK
goto ErrorExit

REM ***************************************************************************
:MakeDirectory
vfdutil /u %2\????????.$$$ >NUL
if errorlevel 1 goto NeedDirectory
goto End
:NeedDirectory
set /e PARENT=vfdutil /d %2
vfdutil /u %PARENT%\????????.$$$ >NUL
if errorlevel 1 goto ERROR_MakeDir
set /e PARENT=vfdutil /p %2
vfdutil /u %PARENT%\????????.$$$ >NUL
if errorlevel 1 call %XBAT% MKDIR %PARENT%
mkdir %2 >NUL
if not exist %2\nul goto ERROR_MakeDir
goto End

:AdjustPermissions
if not exist %TDOSDIR%\NUL goto AdjustPermTEMP
echo tempfile >%TDOSDIR%\FDI-X86.TMP
attrib -r -s -h /s /d %TDOSDIR% >nul
deltree /y %TDOSDIR%\FDI-X86.TMP >NUL
:AdjustPermTEMP
verrlvl 0
if not exist %TEMP%\NUL goto End
echo tempfile >%TEMP%\FDI-X86.TMP
attrib -r -s -h /s /d %TEMP% >nul
deltree /y %TEMP%\FDI-X86.TMP >NUL
verrlvl 0
goto End

:BootBackup
verrlvl 0
if "%2" == "" goto End
if exist %TDRIVE%\%2 xcopy %TDRIVE%\%2 %BACKUP% %XOPTS% >NUL
if errorlevel 1 goto ErrorEnd
shift
goto BootBackup

:DOSBackup
if "%2" == "" goto End
if exist %TDOSDIR%\%4\nul goto DOSBackupDir
xcopy %TDOSDIR%\%4 %BACKUP%\ /E %XOPTS% >NUL
goto DOSBackupCheck
:DOSBackupDir
call %XBAT% MKDIR %BACKUP%\%4
if errorlevel 1 goto AbortExit
vfdutil /a %TDOSDIR%\%4
if errorlevel 1 goto SkipEmptyDir
xcopy %TDOSDIR%\%4 %BACKUP%\%4\ /E %XOPTS% >NUL
:DOSBackupCheck
if errorlevel 1 goto ErrorEnd
:SkipEmptyDir
vprogres /fGreen %2 OF %3
goto End

:UpdateLST
if "%2" == "" goto End
if not exist %TDOSDIR%\PACKAGES\%4 goto NextLST
type %TDOSDIR%\PACKAGES\%4 | vstr /n /s C:\FreeDOS "%TDOSDIR%">%TEMP%\%4
xcopy /r /y %TEMP%\%4 %TDOSDIR%\PACKAGES\ >NUL
:NextLST
if errorlevel 1 goto ErrorEnd
if "USBMODE" == "no" goto NotUSBMode
type %TDOSDIR%\PACKAGES\%4 | vstr /n /s %TDRIVE% "C:">%TEMP%\%4
xcopy /r /y %TEMP%\%4 %TDOSDIR%\PACKAGES\ >NUL
if errorlevel 1 goto ErrorEnd
:NotUSBMode
vprogres /fGreen %2 OF %3
goto End

:ClearAttributes
if "%2" == "" goto End
if exist %TDRIVE%\%2 attrib -r -s -h %TDRIVE%\%2 >NUL
if errorlevel 1 goto ErrorEnd
shift
goto ClearAttributes

:DeleteFiles
if "%2" == "" goto End
if exist %TDRIVE%\%2 del %TDRIVE%\%2 >NUL
if errorlevel 1 goto ErrorEnd
shift
goto DeleteFiles

:CopyConfigFiles
if "%2" == "" goto End
set FIN=
echo %TDOSDIR%|vstr /n/s %TDRIVE% C:|set /p FDOS=
if "%2" == "FDAUTO" set FFILE=AUTOEXEC
if "%2" == "FDCONFIG" set FFILE=CONFIG
if "%2" == "FDAUTO" set FOUT=%2.BAT
if "%2" == "FDCONFIG" set FOUT=%2.SYS
if exist FREEDOS\CONFIGS\%FFILE%.%FEXT% set FIN=%FFILE%.%FEXT%
if not "%FIN%" == "" goto DoCopyConfigFiles
if exist FREEDOS\CONFIGS\%FFILE%.DEF set FIN=%FFILE%.DEF
if not "%FIN%" == "" goto DoCopyConfigFiles
:CopyConfigFilesFail
verrlvl 1
goto CopyConfigFilesNext

:DoCopyConfigFiles
rem echo translate and copy %FIN% to %FOUT%
rem set language variable
type FREEDOS\CONFIGS\%FIN%|vstr /n/s $FLANG$ "%LANG%">%TEMP%\%2.TMP
if errorlevel 1 goto CopyConfigFilesNext
if not exist %TEMP%\%2.TMP goto CopyConfigFilesFail

if "%LANG%" == "" goto SetForEnglish
if /I "%LANG%" == "EN" goto SetForEnglish
type %TEMP%\%2.TMP|vstr /n/s $LANG_SET$ "CALL %DOSDIR%\BIN\SETLANG.BAT %LANG%">%TEMP%\%2.OUT
goto SetForAnyLang
:SetForEnglish
type %TEMP%\%2.TMP|vstr /n/s $LANG_SET$ "rem CALL %DOSDIR%\BIN\SETLANG.BAT EN">%TEMP%\%2.OUT
:SetForAnyLang
copy /y %TEMP%\%2.OUT %TEMP%\%2.TMP >NUL
if errorlevel 1 goto CopyConfigFilesNext
del %TEMP%\%2.OUT >NUL
if errorlevel 1 goto CopyConfigFilesNext
:DoneSetForLang

rem set OS name
type %TEMP%\%2.TMP|vstr /n/s $OS_NAME$ %OS_NAME%>%TEMP%\%2.OUT
copy /y %TEMP%\%2.OUT %TEMP%\%2.TMP >NUL
if errorlevel 1 goto CopyConfigFilesNext
del %TEMP%\%2.OUT >NUL
if errorlevel 1 goto CopyConfigFilesNext

rem set OS version
type %TEMP%\%2.TMP|vstr /n/s $OS_VERSION$ %OS_VERSION%>%TEMP%\%2.OUT
copy /y %TEMP%\%2.OUT %TEMP%\%2.TMP >NUL
if errorlevel 1 goto CopyConfigFilesNext
del %TEMP%\%2.OUT >NUL
if errorlevel 1 goto CopyConfigFilesNext

rem set dos drive
type %TEMP%\%2.TMP|vstr /n/s $FDRIVE$ C:>%TEMP%\%2.OUT
copy /y %TEMP%\%2.OUT %TEMP%\%2.TMP >NUL
if errorlevel 1 goto CopyConfigFilesNext
del %TEMP%\%2.OUT >NUL
if errorlevel 1 goto CopyConfigFilesNext

rem set dos directory
vfdutil /p %TDOSDIR%\ | vstr /s %TDRIVE% C: | set /p XDOSDIR=
type %TEMP%\%2.TMP|vstr /n/s $FTARGET$ "%XDOSDIR%">%TEMP%\%2.OUT
set XDOSDIR=
copy /y %TEMP%\%2.OUT %TEMP%\%2.TMP >NUL
if errorlevel 1 goto CopyConfigFilesNext
del %TEMP%\%2.OUT >NUL
if errorlevel 1 goto CopyConfigFilesNext

rem config dos boot drive, legacy stuff, skip for NOW
goto SkipSetBootDrive
if "%TDRIVE%" == "A:" goto :SkipSetBootDrive
type %TEMP%\%2.TMP|vstr /n/s %TDRIVE% C:>%TEMP%\%2.OUT
copy /y %TEMP%\%2.OUT %TEMP%\%2.TMP >NUL
if errorlevel 1 goto CopyConfigFilesNext
del %TEMP%\%2.OUT >NUL
if errorlevel 1 goto CopyConfigFilesNext
:SkipSetBootDrive

rem set default menu
type %TEMP%\%2.TMP|vstr /n/s $FDEFMENU$ 1>%TEMP%\%2.OUT
copy /y %TEMP%\%2.OUT %TEMP%\%2.TMP >NUL
if errorlevel 1 goto CopyConfigFilesNext
del %TEMP%\%2.OUT >NUL
if errorlevel 1 goto CopyConfigFilesNext

rem set time zone
type %TEMP%\%2.TMP|vstr /n/s $TZ$ EST>%TEMP%\%2.OUT
copy /y %TEMP%\%2.OUT %TEMP%\%2.TMP >NUL
if errorlevel 1 goto CopyConfigFilesNext
del %TEMP%\%2.OUT >NUL
if errorlevel 1 goto CopyConfigFilesNext

rem set country US, part 1
type %TEMP%\%2.TMP|vstr /n/s $FCCC$ 001>%TEMP%\%2.OUT
copy /y %TEMP%\%2.OUT %TEMP%\%2.TMP >NUL
if errorlevel 1 goto CopyConfigFilesNext
del %TEMP%\%2.OUT >NUL
if errorlevel 1 goto CopyConfigFilesNext

rem set country US, part 2
type %TEMP%\%2.TMP|vstr /n/s $FCKC$ 858>%TEMP%\%2.OUT
copy /y %TEMP%\%2.OUT %TEMP%\%2.TMP >NUL
if errorlevel 1 goto CopyConfigFilesNext
del %TEMP%\%2.OUT >NUL
if errorlevel 1 goto CopyConfigFilesNext

rem fix any double slashes
type %TEMP%\%2.TMP|vstr /n/s \\ \>%TEMP%\%2.OUT
copy /y %TEMP%\%2.OUT %TEMP%\%2.TMP >NUL
if errorlevel 1 goto CopyConfigFilesNext
del %TEMP%\%2.OUT >NUL
if errorlevel 1 goto CopyConfigFilesNext

rem move into place
copy /y %TEMP%\%2.TMP %TDRIVE%\%FOUT% >NUL
if errorlevel 1 goto CopyConfigFilesNext
del %TEMP%\%2.TMP >NUL

:CopyConfigFilesNext
set FFILE=
set FOUT=
set FIN=
set FDOS=
if errorlevel 1 goto ErrorEnd
shift
goto CopyConfigFiles

REM ***************************************************************************
:Configure

rem test if Target drive is already set otherwise set it now.
if not "%TDRIVE%" == "" goto TDriveConfiged
set TDRIVE=C:
if "%TSRC%" == "C:\" set TDRIVE=D:
if "%TSRC%" == "C:\FDOS-x86" set TDRIVE=D:
if "%TSRC%" == "C:\FDOS_x86" set TDRIVE=D:
:TDriveConfiged
if "%TDOSDIR%" == "" set TDOSDIR=%TDRIVE%\FREEDOS

rem Only test for already installed when booted
if not "%BOOTED%" == "yes" goto NoCheckInstalled
vinfo /d %TDRIVE%
if errorlevel 1 goto NoCheckInstalled
fc /L FREEDOS\VERSION.FDI %TDOSDIR%\VERSION.FDI>NUL
if errorlevel 1 goto NoCheckInstalled
goto Done

:NoCheckInstalled

REM configure target CPU
set TCPU=8086
vinfo /M
REM vinfo detects some real hardware at lower machine level, if not overridden
REM assume anythine lower than a 386 is wrong.
if "%OCPU%" == "" goto Assume386orBetter
verrlvl 0
set TCPU=%OCPU%
if "%TCPU%" == "DBX" verrlvl 101
if "%TCPU%" == "QEM" verrlvl 102
if "%TCPU%" == "VBX" verrlvl 103
if "%TCPU%" == "VMW" verrlvl 104
if "%TCPU%" == "EMU" verrlvl 200
if "%TCPU%" == "686" verrlvl 6
if "%TCPU%" == "586" verrlvl 5
if "%TCPU%" == "486" verrlvl 4
if "%TCPU%" == "386" verrlvl 3
if "%TCPU%" == "286" verrlvl 2
if "%TCPU%" == "186" verrlvl 1
if "%TCPU%" == "8086" verrlvl 0
goto NoOverrideCPU

:Assume386orBetter
if errorlevel 3 goto NoOverrideCPU
verrlvl 3

:NoOverrideCPU
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
if errorlevel 105 set TCPU=Emulated

REM set type of FreeCOM to install
if not "%TSWAP" == "" goto NoSetCOMSwapType
set TSWAP=XSWAP
if "%TCPU%" == "286" set TSWAP=KSWAP
if "%TCPU%" == "186" set TSWAP=KSWAP
if "%TCPU%" == "8086" set TSWAP=KSWAP
:NoSetCOMSwapType

REM Update some more tags, Virtual machines are i686 and VirtualBox & VMware
REM also get networking.
set TTAGS=%TCPU%
if not errorlevel 101 set TTAGS=%TTAGS%
if errorlevel 101 set TTAGS=686,%TTAGS%
if errorlevel 105 goto TagsDone
if not errorlevel 103 goto TagsDone
set TTAGS=%TTAGS%,Network
:TagsDone

REM ***************************************************************************
:Install

if not "%TMODE%" == "" goto PrintHeader
rem Display Welcome Message and prompt to continue
if "%ADVANCED%" == "no" goto Welcome
:PrintHeader
vecho /g /T %LANGFILE% HRULE
vecho /g /T %LANGFILE% TITLE %OS_NAME% %OS_VERSION%
vecho /g /T %LANGFILE% COPYRIGHT %OS_NAME% %OS_VERSION%
vecho /g /T %LANGFILE% TRADEMARK %OS_NAME% %OS_VERSION%

:Welcome
vecho /g /T %LANGFILE% HRULE
if not "%TMODE%" == "" goto TestDrive
vecho /g /T %LANGFILE% WELCOME_%MSG% %OS_NAME% %OS_VERSION%
for %%i in (0 1 2 3 4 5) do vecho /n /g /T %LANGFILE% WELCOME_%%i %OS_NAME% %OS_VERSION%

vecho /g /n /T %LANGFILE% CONTINUE
if "%AUTOMATIC%" == "yes" call %XBAT% YES
if "%AUTOMATIC%" == "no"  vask /c /g /fGray /T %LANGFILE% PROMPT_YESNO
if errorlevel 2 goto UserAbortExit

vecho /g

rem Test Drive State
:TestDrive
if "%TCPU%" == "DOSBox" goto FileSystemTest
if "%TCPU%" == "DBX" goto FileSystemTest

rem Possible no pipe support yet, so uberdumb partition testing mode.
vfdutil /u %TDRIVE%\TEST????.$$$ >NUL
if not errorlevel 1 goto FileSystemTest
vinfo /d %TDRIVE%
if errorlevel 15 goto Partition
if errorlevel 5 goto Format
goto FileSystemTest

:Partition
if not "%TMODE%" == "" goto ERROR_NoHDD
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
if "%AUTOMATIC%" == "yes" goto PartitionAuto
if "%ADVANCED%" == "yes" goto PartitionManual

:PartitionAuto
vecho /g /n /T %LANGFILE% PARTITION_AUTO %TDRIVE%

%FDISK% /info %TDRVID% >NUL
if errorlevel 1 goto NoPartitionAuto

rem %FDISK% /auto %TDRVID% >NUL

set FDPRI=/PRIO:2000
vinfo /m
if errorlevel 100 set FDPRI=/PRI:100,100
verrlvl 0
%FDISK% %TDRVID% %FDPRI% >NUL

if errorlevel 1 goto NoPartitionAuto
vecho /g /r2 /c32 /T %LANGFILE% SUCCESS

rem Overwritting the MBR and activating the Parition should be done later
rem vecho /g /p /n /T %LANGFILE% PARTITION_MBR %TDRIVE%
rem %FDISK% /mbr %TDRVID% >NUL
rem if errorlevel 1 goto NoPartitionAuto
rem vecho /g /r2 /c32 /T %LANGFILE% SUCCESS

rem vecho /g /p /n /T %LANGFILE% PARTITION_ACTIVE %TDRIVE%
rem %FDISK% /activate:1 %TDRVID% >NUL
rem if not errorlevel 1 goto AutoPartitioned
rem fdisk /ACTIVATE:1 %TDRVID% >NUL
rem if errorlevel 1 goto NoPartitionAuto

:AutoPartitioned
rem vecho /g /r2 /c32 /T %LANGFILE% SUCCESS

:NeedReboot
vecho /g /T %LANGFILE% PARTITION_DONE
vecho /g /n /T %LANGFILE% REBOOT
if "%AUTOMATIC%" == "yes" call %XBAT% YES
if "%AUTOMATIC%" == "no"  vask /c /g /fGray /T %LANGFILE% PROMPT_YESNO
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
vcls /g /fGray /bBlack
rem vecho /g /t %LANGFILE% PARTITION_WARN
rem vecho /g /n /t %LANGFILE% PRESS_KEY
rem vpause /t 5
%FDISK% %TDRVID%
if errorlevel 1 goto ERROR_Partition
goto NeedReboot

:Format
if not "%TMODE%" == "" goto ERROR_NoHDD
vecho /g /T %LANGFILE% FORMAT %TDRIVE%
if "%AUTOMATIC%" == "yes" goto FormatNormal
if "%ADVANCED%" == "yes" goto FormatAdvanced

:FormatNormal
vecho /g /n /p /T %LANGFILE% FORMAT_DEF %TDRIVE%
if "%AUTOMATIC%" == "yes" call %XBAT% YES
if "%AUTOMATIC%" == "no"  vask /c /g /fGray /T %LANGFILE% PROMPT_YESNO
if errorlevel 2 goto UserAbortExit
goto FormatQuick

:FormatAdvanced
vecho /g /n /p /T %LANGFILE% FORMAT_ADV %TDRIVE%
vask /c /g /fGray /T %LANGFILE% PROMPT_FMT
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
vecho /g

REM ***************************************************************************

:FileSystemTest
set POSTOPT=
vecho /g /n /T %LANGFILE% FILESYSTEM_TEST %TDRIVE%
vfdutil /u %TDRIVE%\TEST????.$$$ >NUL
if errorlevel 1 goto ERROR_FileSystem

if not "%TTMP%" == "" goto DriveDone
set POSTOPT=yes

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
if "%POSTOPT%" == "" goto NoNeedReload
if "%1" == "" goto NoNeedReload
call %XBAT% OPTION %1 %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 goto Cleanup
:NoNeedReload
set POSTOPT=

REM ***************************************************************************

:SetTarget
if not "%TMODE%" == "" goto TargetDone
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
vask /c /g /fGray /T %LANGFILE% PROMPT_YESNO
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
if not "%TMODE%" == "" goto BackupSet
vecho /g /p /n /T %LANGFILE% BACKUP_OLD %TDRIVE%
if "%AUTOMATIC%" == "yes" call %XBAT% YES
if "%AUTOMATIC%" == "no"  vask /c /g /fGray /T %LANGFILE% PROMPT_YESNO
if errorlevel 2 goto BackupDisable

:BackupSet
set /e BACKUP=vfdutil /u %TDRIVE%\BACKUP.???
if errorlevel 1 set /e BACKUP=vfdutil /u %TDRIVE%\FDBACKUP.???
if not "%TMODE%" == "" goto BackupDone
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

if not "%TCPU%" == "DOSBox" goto AdvOptions
set FORCEMBR=no

:AdvOptions
if not "%TMODE%" == "" goto NoAdvOptions
if "%AUTOMATIC%" == "yes" goto NoAdvOptions
if "%ADVANCED%" == "no" goto NoAdvOptions

if "%PREVOS%" == "no" goto PrevOSDone
if not exist %TDOSDIR%\nul goto PrevOSDone
vecho /g /p /n /T %LANGFILE% DELETE_OLD %TDOSDIR%
vask /c /g /fGray /T %LANGFILE% PROMPT_YESNO
if errorlevel 2 goto PrevOSDone
set PREVOS=delete
:PrevOSDone

if "%TCPU%" == "DOSBox" goto NoForceMBR
rem Force an update to the MBR?
vecho /g /p /n /T %LANGFILE% FORCE_MBR %TDRIVE%
vask /c /g /fGray /T %LANGFILE% PROMPT_YESNO
if errorlevel 2 goto NoForceMBR
set FORCEMBR=yes
goto ForceMBRDone
:NoForceMBR
set FORCEMBR=no
:ForceMBRDone

rem Transfer System Files?
vecho /g /p /n /T %LANGFILE% SYS_FILES %TDRIVE%
vask /c /g /fGray /T %LANGFILE% PROMPT_YESNO
if not errorlevel 2 goto SYSFILESDone
set SYSFILES=no
:SYSFILESDone

rem Update Config Files?
vecho /g /p /n /T %LANGFILE% CFG_FILES %TDRIVE%
vask /c /g /fGray /T %LANGFILE% PROMPT_YESNO
if not errorlevel 2 goto CFGFILESDone
set CFGFILES=no
:CFGFILESDone

:NoAdvOptions
if "%PREVOS%" == "yes" set PREVOS=overwrite

rem Detect BIOS Drive and Partition
set TPRTID=0
set TDRVID=0
if "%TCPU%" == "DOSBox" goto NoFindPartID
set TDRVID=1
%FDISK% /info %TDRVID% | vstr /f %TDRIVE% 2- | vstr /i/b/f ' ' 1 | set /p TPRTID=
if not "%TPRTID%" == "" goto FoundPartID
set TDRVID=2
%FDISK% /info %TDRVID% | vstr /f %TDRIVE% 2- | vstr /i/b/f ' ' 1 | set /p TPRTID=
if not "%TPRTID%" == "" goto FoundPartID
set TDRVID=3
%FDISK% /info %TDRVID% | vstr /f %TDRIVE% 2- | vstr /i/b/f ' ' 1 | set /p TPRTID=
if not "%TPRTID%" == "" goto FoundPartID
set TDRVID=4
%FDISK% /info %TDRVID% | vstr /f %TDRIVE% 2- | vstr /i/b/f ' ' 1 | set /p TPRTID=
if not "%TPRTID%" == "" goto FoundPartID
goto ERROR_NoPartition

:FoundPartID

:NoFindPartID

REM ***************************************************************************
if "%TMODE%" == "MBR" set FORCEMBR=yes

goto SkipMBRCodeTest
if not "%FORCEMBR%" == "maybe" goto SkipMBRCodeTest
vinfo /E %TDRVID%
if errorlevel 10 goto AssumeNoMBRWrite
set FORCEMBR=yes
goto SkipMBRCodeTest
:AssumeNoMBRWrite
set FORCEMBR=no
:SkipMBRCodeTest

rem Display Settings
:DisplaySettings
if not "%TMODE%" == "" goto PrintSettings
if "%ADVANCED%" == "no" goto InstallNow
:PrintSettings
vecho /p /g /T %LANGFILE% STATUS_MSG
vecho /g /T %LANGFILE% STATUS_CPU %TCPU% %TTAGS%
vfdutil /p %TSRC%\ | set /p XSRC=
vecho /g /T %LANGFILE% STATUS_FROM %XSRC%
set XSRC=
vecho /g /T %LANGFILE% STATUS_DRV %TDRIVE% %TDRVID% %TPRTID%
vecho /g /T %LANGFILE% STATUS_MBR %FORCEMBR%
if "%TMODE%" == "MBR" goto InstallNow
vecho /g /T %LANGFILE% STATUS_DOS %TDOSDIR%
vecho /g /T %LANGFILE% STATUS_BAK %BACKUP%
vecho /g /T %LANGFILE% STATUS_POS %PREVOS%
vecho /g /T %LANGFILE% STATUS_SYS %SYSFILES%
vecho /g /T %LANGFILE% STATUS_CFG %CFGFILES%

rem Reaty to Install, procede...
:InstallNow
vecho /g
if "%TMODE%" == "INFO" goto Done
if "%TMODE%" == "MBR" goto DoMBROnly

vecho /g /T %LANGFILE% INSTALL_NOW %OS_NAME% %OS_VERSION%
vecho /g /n /T %LANGFILE% CONTINUE
if "%AUTOMATIC%" == "yes" call %XBAT% YES
if "%AUTOMATIC%" == "no"  vask /c /g /fGray /T %LANGFILE% PROMPT_YESNO
if errorlevel 2 goto UserAbortExit

vecho /g /p /T %LANGFILE% HRULE

rem Make Backup directory
if "%BACKUP%" == "no" goto NoDoBackup
vecho /g /p /T %LANGFILE% DO_BACKUP %BACKUP%
vecho /g
vprogres /fGreen 0 of 1
call %XBAT% MKDIR %BACKUP%
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
call %XBAT% BBACK FDAUTO.BAT FDCONFIG.SYS AUTOEXEC.BAT CONFIG.SYS KERNEL.SYS COMMAND.COM
if errorlevel 1 goto ERROR_BackupCfg
call %XBAT% BBACK IO.SYS MSDOS.SYS WINA20.386 IBMBIO.COM IBMDOS.COM DRDOS.386
if errorlevel 1 goto ERROR_BackupCfg

rem Backup Old OS Directory
if not exist %TDOSDIR%\NUL goto NoDoBackupOS
veach /A+ /D %TDOSDIR%\*.* /X %XBAT% DBACK @ # *
if errorlevel 1 goto ERROR_BackupOS
:NoDoBackupOS
call %XBAT% SUCCESS

:NoDoBackup
call %XBAT% CATTR FDAUTO.BAT FDCONFIG.SYS AUTOEXEC.BAT CONFIG.SYS KERNEL.SYS COMMAND.COM
call %XBAT% CATTR IO.SYS MSDOS.SYS WINA20.386 IBMBIO.COM IBMDOS.COM DRDOS.386

rem Do Deletes
if "%PREVOS%" == "overwrite" goto NoDoErase
if "%PREVOS%" == "no" goto NoDoErase
vecho /g /p /T %LANGFILE% DO_ERASE %TDOSDIR%
deltree /y %TDOSDIR%\*.* >NUL
if errorlevel 1 goto ErasedFailed
call %XBAT% DEL FDAUTO.BAT FDCONFIG.SYS AUTOEXEC.BAT CONFIG.SYS KERNEL.SYS COMMAND.COM
if errorlevel 1 goto ErasedFailed
call %XBAT% DEL IO.SYS MSDOS.SYS WINA20.386 IBMBIO.COM IBMDOS.COM DRDOS.386
if errorlevel 1 goto ErasedFailed
call %XBAT% SUCCESS
goto NoDoErase
:ErasedFailed
call %XBAT% FAIL
rem Going to continue install anyway...
goto DoSysFiles
:NoDoErase

:DoSysFiles
rem Do System Transfer
if "%SYSFILES%" == "no" goto NoDoSysFiles
vecho /g /p /T %LANGFILE% DO_SYSFILES %TDRIVE% %TCPU%
vinfo /m
if errorlevel 3 set KERNL=FREEDOS\BIN\KERNL386.SYS
verrlvl 0
if not exist %TDOSDIR%\BIN\FREEDOS\%TSWAP%\CMD-%LANG%.COM goto NoLangSpecCOM
copy %TDOSDIR%\BIN\FREEDOS\%TSWAP%\CMD-%LANG%.COM %TDRIVE%\COMMAND.COM %COPTS% >NUL
if errorlevel 1 goto ERROR_SysFiles
goto SecondCommandCopy

:NoLangSpecCOM
if not exist %TDOSDIR%\BIN\FREEDOS\%TSWAP%\CMD-EN.COM goto NoFreeCOM
copy %TDOSDIR%\BIN\FREEDOS\%TSWAP%\CMD-EN.COM %TDRIVE%\COMMAND.COM %COPTS% >NUL
if errorlevel 1 goto ERROR_SysFiles
goto SecondCommandCopy

:NoFreeCOM
REM Use whatever command.com installer is using.
copy FREEDOS\BIN\COMMAND.COM %TDRIVE%\COMMAND.COM %COPTS% >NUL
if errorlevel 1 goto ERROR_SysFiles
goto NoSecondCopy

:SecondCommandCopy
REM Replace installed COMMAND.COM with Language Specific Version
copy %TDRIVE%\COMMAND.COM %TDOSDIR%\BIN\COMMAND.COM %COPTS% >NUL
if errorlevel 1 goto ERROR_SysFiles
:NoSecondCopy

:TransferKernel
copy %KERNL% %TDRIVE%\KERNEL.SYS %COPTS% >NUL
if errorlevel 1 goto ERROR_SysFiles
if "%TCPU%" == "DOSBox" goto DoSysFilesDone
if not "%FORCEMBR%" == "no" goto DoSysFilesDone
sys %TDRIVE% /BOOTONLY /OEM:FD /BACKUPBS %TEMP%\BOOT.BSS >NUL
if not errorlevel 1 goto DoSysFilesDone
goto ERROR_BootSector
:DoSysFilesDone
call %XBAT% SUCCESS
:NoDoSysFiles
goto DoMBRUpdate

:DoMBROnly
vecho /g /n /T %LANGFILE% FORCE_MBR %TDRIVE%
if "%AUTOMATIC%" == "yes" call %XBAT% YES
if "%AUTOMATIC%" == "no"  vask /c /g /fGray /T %LANGFILE% PROMPT_YESNO
if errorlevel 2 goto UserAbortExit

:DoMBRUpdate
rem Do MBR Update
if "%FORCEMBR%" == "no" goto NoDoForceMBR
vecho /g /p /T %LANGFILE% DO_FORCEMBR %TDRIVE%
sys %TDRIVE% /BOOTONLY /OEM:FD /BACKUPBS %TEMP%\MBR.BSS >NUL
if errorlevel 1 goto ERROR_BootSector
%FDISK% /MBR %TDRVID% >NUL
if errorlevel 1 goto ERROR_MBRUpdate
call %XBAT% SUCCESS
:NoDoForceMBR

if "%TCPU%" == "DOSBox" goto NoDoActivate
rem Activate DOS Partition
vecho /g /p /T %LANGFILE% DO_ACTIVATE %TDRVID% %TPRTID%
%FDISK% /ACTIVATE:%TPRTID% %TDRVID% >NUL
if errorlevel 1 goto TryAlternate
call %XBAT% SUCCESS
goto NoDoActivate
:TryAlternate
fdisk /ACTIVATE:%TPRTID% %TDRVID% >NUL
if errorlevel 1 goto ERROR_Activate
call %XBAT% SUCCESS

:NoDoActivate

if "%TMODE%" == "MBR" goto Done

rem Do Config File Transfer
if "%CFGFILES%" == "no" goto NoDoCfgFiles
vecho /g /p /T %LANGFILE% DO_CFGFILES %TDRIVE%
set FEXT=086
vinfo /m
if errorlevel 1 set FEXT=186
if errorlevel 2 set FEXT=286
if errorlevel 3 set FEXT=386
if errorlevel 4 set FEXT=486
if errorlevel 5 set FEXT=586
if errorlevel 6 set FEXT=686
if errorlevel 101 set FEXT=DBX
if errorlevel 102 set FEXT=QEM
if errorlevel 103 set FEXT=VBX
if errorlevel 104 set FEXT=VMW
if errorlevel 200 set FEXT=EMU

if not "%OCPU%" == "" set FEXT=%OCPU%
if "%OCPU%" == "8086" set FEXT=086

verrlvl 0
call %XBAT% XFR FDAUTO FDCONFIG
if errorlevel 1 goto ERROR_CfgFiles
call %XBAT% SUCCESS
:NoDoCfgFiles

rem Prepare to Extract Files
vecho /g /p /T %LANGFILE% DO_PREPARE %OS_NAME% %TCPU%

call %XBAT% PERMS

call %XBAT% MKDIR %TDOSDIR%\BIN
if errorlevel 1 goto ERROR_MakeDir
call %XBAT% MKDIR %TDOSDIR%\LINKS
if errorlevel 1 goto ERROR_MakeDir
call %XBAT% MKDIR %TDOSDIR%\NLS
if errorlevel 1 goto ERROR_MakeDir
call %XBAT% MKDIR %TDOSDIR%\TEMP
if errorlevel 1 goto ERROR_MakeDir
set PATH=%TDOSDIR%\BIN;%TDOSDIR%\LINKS;%PATH%
rem call %XBAT% MKDIR %TEMP%
rem if errorlevel 1 goto ERROR_MakeDir

rem copy minimal for continuance, archive extraction and shutdown
xcopy /r /y FREEDOS\VERSION.FDI %TEMP%\ >NUL
if errorlevel 1 goto ERROR_XfrFilesTEMP
xcopy /r /y FREEDOS\BIN\FDWRAPUP.BAT %TDOSDIR%\BIN\ >NUL
if errorlevel 1 goto ERROR_XfrFilesDOS
xcopy /r /y FREEDOS\BIN\V*.COM %TDOSDIR%\BIN\ >NUL
if errorlevel 1 goto ERROR_XfrFilesDOS
if not exist FREEDOS\BIN\GZIP.EXE goto HasNoGZIP
xcopy /r /y FREEDOS\BIN\GZIP.EXE %TDOSDIR%\BIN\ >NUL
if errorlevel 1 goto ERROR_XfrFilesDOS
:HasNoGZIP
xcopy /r /y FREEDOS\BIN\SLICEREX.EXE %TDOSDIR%\BIN\ >NUL
if errorlevel 1 goto ERROR_XfrFilesDOS
xcopy /r /y FREEDOS\NLS\SLICER.* %TDOSDIR%\NLS\ >NUL
if errorlevel 1 goto ERROR_XfrFilesDOS
xcopy /r /y FREEDOS\BIN\DELTREE.COM %TDOSDIR%\BIN\ >NUL
if errorlevel 1 goto ERROR_XfrFilesDOS
xcopy /r /y %XBAT% %TEMP%\ >NUL
if errorlevel 1 goto ERROR_XfrFilesTEMP

set /e FEXT=vfdutil /e %LANGFILE%
copy /y %LANGFILE% %TEMP%\SETUP.%FEXT% >NUL
if errorlevel 1 goto ERROR_XfrFilesTEMP
set LANGFILE=%TEMP%\SETUP.%FEXT%

call %XBAT% PERMS

set PATH=%TDOSDIR%\BIN;%TDOSDIR%\LINKS
set NLSPATH=%TDOSDIR%\NLS

vfdutil /c /p %TDOSDIR%\
if errorlevel 1 goto ERROR_WTF

%TEMP%\SETUP.BAT EXTRACT
goto AbortExit

REM ***************************************************************************
:ExtractFiles
call %XBAT% SUCCESS
rem set SLICER.LOG=%TDRIVE%\SLICER.LOG

rem Extract Files
vecho /g /p /T %LANGFILE% DO_INSTALL %OS_NAME% %TTAGS%

vecho /g /p

:Diskette
vfdutil /u %TSLICE%\????????.??? >nul
if errorlevel 1 goto InsertDiskette
if not exist %TSLICE%\FREEDOS.SAF goto InsertDiskette

set COMSPEC=%DOSDIR%\BIN\COMMAND.COM
slicerex /qoxf %TSLICE%\FREEDOS.SAF /g %TTAGS%
if errorlevel 1 goto ERROR_SAF

vecho /g /p /p /T %LANGFILE% EXTRACTION %OS_NAME% %OS_VERSION%
call %XBAT% SUCCESS

rem Update List files
if "%TDOSDIR%" == "C:\FREEDOS" goto NoLstUpdate

vecho /g /p /T %LANGFILE% UPDATE_LST
veach /D %TDOSDIR%\PACKAGES\*.LST /X %XBAT% ULST @ # *
call %XBAT% SUCCESS

:NoLstUpdate

rem Add OS ID Tag File
xcopy /r /y %TEMP%\VERSION.FDI %TDOSDIR%\ >NUL
if errorlevel 1 goto ERROR_XfrFilesDOS

set DOSDIR=%TDOSDIR%

rem Done Reboot

vecho /g /p /T %LANGFILE% HRULE
vecho /g /p /T %LANGFILE% DONE_NOW %OS_NAME% %OS_VERSION%
vecho /g /p /n /T %LANGFILE% REBOOT_NOW
if "%AUTOMATIC%" == "yes" call %XBAT% YES
if "%AUTOMATIC%" == "no"  vask /c /g /fGray /T %LANGFILE% PROMPT_YESNO
set TDONE=REBOOT
if errorlevel 2 set TDONE=CMD

vecho /g
goto Done

:InsertDiskette
vecho /g /p /T %LANGFILE% INSERT_DISKETTE 2 x86-DSK1 %TSRC%
vecho /g /n /t %LANGFILE% PRESS_KEY
if "%AUTOMATIC%" == "yes" vpause /D10 CTRL-C
if "%AUTOMATIC%" == "no" vpause CTRL-C
if errorlevel 200 goto LateAbortExit
goto Diskette

REM ***************************************************************************
:NotFreeCOM
echo The installer requires functions provided by the FreeCOM Shell.
goto ErrorEnd

:ERROR_Option
vecho /p /g /N /T %LANGFILE% ERROR_MINOR
vecho /g /T %LANGFILE% ERROR_Option %2
goto ErrorEnd

:ERROR_CfgBackup
vecho /p /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_CfgBackup
goto AbortExit

:ERROR_NoHDD
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_NoHDD
goto AbortExit

:ERROR_FileSystem
rem set TTMP=
vecho /g /r2 /c32 /T %LANGFILE% FAILED
vecho /p /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_FileSystem %TDRIVE%
goto AbortExit

:ERROR_SAF
vfdutil /f %TSLICE%\FREEDOS.SAF | set /p TSD=
vecho /g /r2 /c32 /T %LANGFILE% FAILED
vecho /p /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_SAF %TSD%
set TSD=
goto AbortExit

:ERROR_Partition
vecho /p /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_Partition
goto AbortExit

:ERROR_NoPartition
vecho /p /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_NoPartition %TDRIVE%
goto AbortExit

:ERROR_Format
vecho /p /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% FORMAT_ERROR %TDRIVE%
goto AbortExit

:ERROR_NoCfgEnv
vecho /p /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_NoCfgEnv
goto AbortExit

:ERROR_NotFreeCOM
vecho /p /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_NotFreeCOM
goto AbortExit

:ERROR_MissingFreeCOM
vecho /p /g /N /T %LANGFILE% ERROR_CRITICAL
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
call %XBAT% FAIL
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_MBRBackup %TDRVID%
goto AbortExit

:ERROR_BackupCfg
call %XBAT% FAIL
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_BackupCfg
goto AbortExit

:ERROR_BackupOS
call %XBAT% FAIL
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /T %LANGFILE% ERROR_BackupOS
goto AbortExit

:ERROR_SysFiles
call %XBAT% FAIL
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /N /T %LANGFILE% ERROR_SysFiles %TDRVID%
goto AbortExit

:ERROR_BootSector
call %XBAT% FAIL
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /N /T %LANGFILE% ERROR_BootSector %TDRVID%
goto AbortExit

:ERROR_MBRUpdate
call %XBAT% FAIL
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /N /T %LANGFILE% ERROR_MBRUpdate %TDRVID%
goto AbortExit

:ERROR_Activate
call %XBAT% FAIL
vecho /g /N /T %LANGFILE% ERROR_MINOR
vecho /g /N /T %LANGFILE% ERROR_Activate %TDRVID% %TPRTID%
goto NoDoActivate

:ERROR_CfgFiles
call %XBAT% FAIL
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /N /T %LANGFILE% ERROR_CfgFiles %TDRIVE%
goto AbortExit

:ERROR_XfrFilesDOS
call %XBAT% FAIL
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /N /T %LANGFILE% ERROR_XfrFiles %TDOSDIR%
goto AbortExit

:ERROR_XfrFilesTEMP
call %XBAT% FAIL
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /N /T %LANGFILE% ERROR_XfrFiles %TEMP%
goto AbortExit

:ERROR_WTF
call %XBAT% FAIL
vecho /g /N /T %LANGFILE% ERROR_CRITICAL
vecho /g /N /T %LANGFILE% ERROR_WTF
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
goto ErrorEnd

:LateAbortExit
cd \
vfdutil /c /p %TSRC%\ >NUL

:UserAbortExit

:AbortExit

vecho /g /p /T %LANGFILE% ABORTED %OS_NAME% %OS_VERSION%

:ErrorExit
set EXITCODE=1
goto Cleanup

:ErrorEnd
set EXITCODE=1
verrlvl 1
goto End

rem Batch completed, shutdown
:Done
set EXITCODE=0

if not "%TDONE%" == "" goto KeepSome
:Cleanup
if "%TTMP%" == "" goto NoTempSpace
if not exist %TTMP%\NUL goto NoTempSpace

deltree /y %TTMP%\*.* >NUL
rmdir %TTMP% >NUL

:NoTempSpace
rem Internal and processing variables
set TTMP=
:KeepSome
set LANGFILE=
set AUTOMATIC=
set ADVANCED=
set FORCE=
set TDRVID=
set TPRTID=
set VAL=
set VALD=
set VALP=
set MSG=
set LOADED=
set REPLY=
set PAERNT=
set SEARCH=
set XOPTS=
set COPTS=
set KERNL=
set FEXT=

rem Install variables
set TDRIVE=
set TDOSDIR=
set TSWAP=
set TBHD=
set TCPU=
set TTAGS=
set TSRC=
set LAYOUT=
set BACKUP=
set LABEL=
set FDISK=
set PREVOS=
set FORCEMBR=
set SYSFILES=
set CFGFILES=
set TMODE=
set SHR=
set BOOTED=
set TSLICE=
set POSTOPT=
set XBAT=
set FDPRI=

if not "%TDONE%" == "" goto WrapUp
if not "%EXITCODE%" == "" verrlvl %EXITCODE%
set EXITCODE=
goto End

:WrapUp
if exist %DOSDIR%\BIN\FDWRAPUP.BAT %DOSDIR%\BIN\FDWRAPUP.BAT %TDONE%
set TDONE=
goto Done

rem Exit point
:End
