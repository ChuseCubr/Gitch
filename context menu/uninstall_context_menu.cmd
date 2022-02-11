@echo off
setlocal enabledelayedexpansion

net session >nul 2>&1
if not %errorlevel% equ 0 goto :notAdmin

set key="HKCR\*\shell\Gitch"
reg query %key% >nul 2>nul
if %errorlevel% equ 1 goto :isUninstalled
goto :main

:notAdmin
    echo Insufficient permissions. Please run in administrator mode.
    pause
    exit 0

:isUninstalled
    echo Gitch has not been added to the context menu.
    pause
    exit 0

:main
    reg delete "HKCR\*\shell\Gitch" /f >nul 2>nul
    reg delete "HKCR\Directory\shell\Gitch" /f >nul 2>nul
    reg delete "HKCR\Directory\Background\shell\Gitch" /f >nul 2>nul

    echo Gitch has been removed from the context menu.
    pause
    exit 0