@echo off

if not "%OS_NAME%" == "$OS_NAME$" goto End

if "%1" == "" goto BOOT
goto %1

:BOOT
SET COLOR=/a0x1A
SET BIT=/c0xdb

vcursor hide
vline dumb hidden
vecho /g/a7/p/r9
vgotoxy /l sop
set /e WHEREY=vgotoxy /Qy
vframe /y%WHEREY% /x8/w63/h10/a0x1b single

vgotoxy /g right right
call %0 DrawF
call %0 DrawR
call %0 DrawE
call %0 DrawE
call %0 DrawD
call %0 DrawO
call %0 DrawS
goto Done

:DrawF
vecho %COLOR% /r7 %BIT% /n
vgotoxy down left left left left left left left
vecho %COLOR% /r2 %BIT% /n
vgotoxy down left left
vecho %COLOR% /r2 %BIT% /n
vgotoxy down left left
vecho %COLOR% /r5 %BIT% /n
vgotoxy down left left left left left
vecho %COLOR% /r2 %BIT% /n
vgotoxy down left left
vecho %COLOR% /r2 %BIT% /n
vgotoxy down left left
vecho %COLOR% /r2 %BIT% /n
vgotoxy down left left
vecho %COLOR% /r2 %BIT% /n
vgotoxy right right right right right right up up up up up up up
goto End

:DrawR
vgotoxy down down down
vecho %COLOR% /r2 %BIT% /c32 /r3 %BIT% /n
vgotoxy down left left left left left left
vecho %COLOR% /r3 %BIT% /r2 /c32 /r2 %BIT% /n
vgotoxy down left left left left left left left
vecho %COLOR% /r2 %BIT% /n
vgotoxy down left left
vecho %COLOR% /r2 %BIT% /n
vgotoxy down left left
vecho %COLOR% /r2 %BIT% /n
vgotoxy right right right right right right up up up up up up up
goto End

:DrawE
vgotoxy down down down
vecho %COLOR% /c32 /r5 %BIT% /n
vgotoxy down left left left left left left
vecho %COLOR% /r2 %BIT% /r3 /c32 /r2 %BIT% /n
vgotoxy down left left left left left left left
vecho %COLOR% /r6 %BIT% /n
vgotoxy down left left left left left left
vecho %COLOR% /r2 %BIT% /n
vgotoxy down left left
vecho %COLOR% /c32 /r5 %BIT% /n
vgotoxy right right right up up up up up up up
goto End

:DrawD
vecho %COLOR% /r5 %BIT% /n
vgotoxy down left left left left left
vecho %COLOR% /r2 %BIT% /r2 /c32 /r2 %BIT% /n
vgotoxy down left left left left left left
vecho %COLOR% /r2 %BIT% /r3 /c32 /r2 %BIT% /n
vgotoxy down left left left left left left left
vecho %COLOR% /r2 %BIT% /r3 /c32 /r2 %BIT% /n
vgotoxy down left left left left left left left
vecho %COLOR% /r2 %BIT% /r3 /c32 /r2 %BIT% /n
vgotoxy down left left left left left left left
vecho %COLOR% /r2 %BIT% /r3 /c32 /r2 %BIT% /n
vgotoxy down left left left left left left left
vecho %COLOR% /r2 %BIT% /r2 /c32 /r2 %BIT% /n
vgotoxy down left left left left left left
vecho %COLOR% /r5 %BIT% /n
vgotoxy right right right up up up up up up up
goto End

:DrawO
vecho %COLOR% /r2 /c32 /r3 %BIT% /n
vgotoxy down left left left left left
vecho %COLOR% /c32 /r2 %BIT% /c32 /r2 %BIT% /n
vgotoxy down left left left left left left
vecho %COLOR% /r2 %BIT% /r3 /c32 /r2 %BIT% /n
vgotoxy down left left left left left left left
vecho %COLOR% /r2 %BIT% /r3 /c32 /r2 %BIT% /n
vgotoxy down left left left left left left left
vecho %COLOR% /r2 %BIT% /r3 /c32 /r2 %BIT% /n
vgotoxy down left left left left left left left
vecho %COLOR% /r2 %BIT% /r3 /c32 /r2 %BIT% /n
vgotoxy down left left left left left left left
vecho %COLOR% /c32 /r2 %BIT% /c32 /r2 %BIT% /n
vgotoxy down left left left left left left
vecho %COLOR% /r2 /c32 /r3 %BIT% /n
vgotoxy right right right up up up up up up up
goto End

:DrawS
vecho %COLOR% /c32 /r5 %BIT% /n
vgotoxy down left left left left left left
vecho %COLOR% /r2 %BIT% /r3 /c32 /r2 %BIT% /n
vgotoxy down left left left left left left left
vecho %COLOR% /r2 %BIT% /n
vgotoxy down left left
vecho %COLOR% /c32 /r5 %BIT% /n
vgotoxy down left left left left left left
vecho %COLOR% /r5 /c32 /r2 %BIT% /n
vgotoxy down left left left left left left left
vecho %COLOR% /r5 /c32 /r2 %BIT% /n
vgotoxy down left left left left left left left
vecho %COLOR% /r2 %BIT% /r3 /c32 /r2 %BIT% /n
vgotoxy down left left left left left left left
vecho %COLOR% /c32 /r5 %BIT% /n
goto End

:Done
vgotoxy /g eot
vecho /g /a7 /p
vcursor small
SET COLOR=
SET BIT=
SET WHEREY=

:End