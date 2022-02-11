@echo off
setlocal enabledelayedexpansion

net session >nul 2>&1
if not %errorlevel% equ 0 goto :notAdmin

set key="HKCR\*\shell\Gitch"
reg query %key% >nul 2>nul
if %errorlevel% equ 0 goto :isInstalled

set selectMenu=Open Pull Push Remove
set backgroundMenu=Open Pull Push Remove Clone
set here=%~dp0
set here=%here:\context menu\=%
set script=%here%\gitch.cmd

set /a index=1

goto :main

:notAdmin
    echo Insufficient permissions. Please run in administrator mode.
    pause
    exit 0

:isInstalled
    echo Gitch has already been added to the context menu.
    pause
    exit 0

:files
    reg add HKCR\*\shell\Gitch\shell\flyout!index! /v "MUIVerb" /d "%1" /f >nul
    reg add HKCR\*\shell\Gitch\shell\flyout!index!\command /d "\"%script%\" %1 \"%%V\"" /f >nul
    goto :eof

:directoryShell
    reg add HKCR\Directory\shell\Gitch\shell\flyout!index! /v "MUIVerb" /d "%1" /f >nul
    reg add HKCR\Directory\shell\Gitch\shell\flyout!index!\command /d "\"%script%\" %1 \"%%V\"" /f >nul
    goto :eof

:directoryBackground
    reg add HKCR\Directory\Background\shell\Gitch\shell\flyout!index! /f >nul
    reg add HKCR\Directory\Background\shell\Gitch\shell\flyout!index! /v "MUIVerb" /d "%1" /f >nul
    reg add HKCR\Directory\Background\shell\Gitch\shell\flyout!index!\command /d "\"%script%\" %1" /f >nul
    goto :eof


:main
    reg add HKCR\*\shell\Gitch /v "MUIVerb" /d "Gitch" /f >nul
    reg add HKCR\*\shell\Gitch /v "SubCommands" /f >nul

    for %%a in (!selectMenu!) do (
        call :files %%a
        set /a index+=1
    )

    set /a index=1

    reg add HKCR\Directory\shell\Gitch /v "MUIVerb" /d "Gitch" /f >nul
    reg add HKCR\Directory\shell\Gitch /v "SubCommands" /f >nul

    for %%a in (%selectMenu%) do (
        call :directoryShell %%a
        set /a index+=1
    )

    set /a index=1

    reg add HKCR\Directory\Background\shell\Gitch /v "MUIVerb" /d "Gitch" /f >nul
    reg add HKCR\Directory\Background\shell\Gitch /v "SubCommands" /f >nul

    for %%a in (%backgroundMenu%) do (
        call :directoryBackground %%a
        set /a index+=1
    )

    echo Gitch has been added to the context menu.
    pause
    exit 0