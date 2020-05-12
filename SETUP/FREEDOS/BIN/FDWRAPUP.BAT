@echo off

if "%1" == "CMD" goto DoWrapUp
if "%1" == "REBOOT" goto DoWrapUp
goto End

:DoWrapUp
%comspec%

:End