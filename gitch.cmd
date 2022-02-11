@echo off
setlocal EnableDelayedExpansion
@rem GITCH
@rem (git + itch)
@rem "Mirroring" tool* (to be used with OneDrive, etc.)
@rem     *literally just does auto-copy-pasting

set command="%~1"
set input="%~2"
set local_path=!cd!
set mirror_path=!cd!

if not [%3]==[] (
    echo Invalid number of arguments. Enter gitch /? for help.
    pause
    exit /b 0
)

@rem Clone has its own thing for no argument
@rem and needs full path to work
if /i !command!=="clone" goto :main
if [!input!]==[] (
    for /f "tokens=*" %%a in ("!cd!") do set input=%%~na
    cd ..
)
for /f "tokens=*" %%a in ("!input!") do set input=%%~nxa

@rem Command switch
:main
    if /i !command!=="clone" goto :clone
    if /i !command!=="push" goto :push
    if /i !command!=="open" goto :open
    if /i !command!=="pull" goto :pull
    if /i !command!=="remove" goto :remove
    if /i !command!=="help" goto :help
    if !command!=="/?" goto :help
    echo Invalid command. Enter gitch /? for help.
    pause
    exit /b 0

@rem Commands
:clone
    if [!input!]==[] (
        echo No path passed
        set /p input="Source to clone: "
    )

    for /f "tokens=*" %%a in ("!input!") do set source_name=%%~na
    for /f "tokens=*" %%a in ("!input!") do set input=%%~a

    if not exist "!input!" (
        echo Source does not exist
        pause
        exit /b 0
    )

    mkdir "!source_name!"
    robocopy "!input!" "!cd!\!source_name!" /s

    @rem All files lost
    if !errorlevel! equ 16 goto :error || exit /b 0

    @rem No / not all files lost
    echo !input!>"!source_name!\gitch.txt"
    echo !cd!\!source_name!>"!input!\gitch.txt"
    if !errorlevel! geq 8 echo Error: Failed to copy at least 1 file or folder.

    for /f "tokens=*" %%a in ("!cd!") do echo Cloned !source_name! to %%~na
    goto :end

:push
    set local_file="!local_path!\!input!"
    for /f "tokens=*" %%a in ("!local_file!") do set local_file=%%~a

    if not exist "!local_file!" (
        echo File or directory does not exist in current directory
        pause
        exit /b 0
    )

    call :find || exit /b 0
    if not exist "!mirror_path!" mkdir "!mirror_path!"

    @rem Folders and files differ in arguments
    if exist "!local_file!\*" (
        @rem Just to see logs
        @echo on
        mkdir "!mirror_leaf!"
        robocopy "!local_file! " "!mirror_leaf! " /s
    ) else (
        @echo on
        robocopy "!local_path! " "!mirror_path! " "!input!"
    )
    @echo off

    if !errorlevel! equ 16 goto :error || exit /b 0
    if !errorlevel! geq 8 echo Error: Failed to copy at least 1 file or folder.

    cd "!local_path!"
    echo Pushed `!input!` to mirror
    goto :end

:open
    call :find || exit /b 0
    call :mirrorExist || exit /b 0

    if exist "!mirror_leaf!\*" (
        %systemroot%\explorer.exe "!mirror_leaf!"
    ) else (
        "!mirror_leaf!"
    )

    exit /b 0

:pull
    call :find || exit /b 0
    call :mirrorExist || exit /b 0

    if exist "!mirror_leaf!\*" (
        @echo on
        mkdir "!local_path!\!input!"
        robocopy "!mirror_leaf! " "!local_path!\!input! " /s /e
    ) else (
        @echo on
        robocopy "!mirror_path! " "!local_path! " "!input!"
    )
    @echo off

    if !errorlevel! equ 16 goto :error || exit /b 0
    if !errorlevel! geq 8 echo Error: Failed to copy at least 1 file or folder.

    echo Pulled `!input!` from mirror
    goto :end

:remove
    if "!input!"=="" (
        echo No file or directory specified
        pause
        exit /b 0
    )

    call :find
    call :mirrorExist || exit /b 0

    if exist "!mirror_leaf!\*" (
        @echo on
        rmdir "!mirror_leaf!\" /s /q
    ) else (
        @echo on
        del "!mirror_leaf!" /q
    )
    @echo off

    echo Deleted `!input!` from mirror
    goto :end

:help
    echo.
    echo GITCH is a script for mirroring folder structures
    echo that's meant to be used with OneDrive for my homeworks.
    echo.
    echo USAGE:
    echo.
    echo   GITCH ^<command^> [file/folder name]
    echo.
    echo     If no argument is passed, the current folder will be the argument.
    echo.
    echo ---
    echo.
    echo Commands:
    echo.
    echo   CLONE [path]     Copies the specified folder into the current folder
    echo                    and sets up gitch.txt files for other commands.
    echo                    If no argument is passed, user input will be
    echo                    prompted for.
    echo.
    echo   OPEN [name]      Opens the corresponding specified file or folder
    echo                    in the mirror using the default program.
    echo.
    echo   PULL [name]      Copies the specified file or folder from the mirror
    echo                    into the current folder.
    echo.
    echo   PUSH [name]      Copies the specified file or folder into the mirror.
    echo                    If the current folder does not exist in the mirror,
    echo                    the folder, and any parent folders that also do not
    echo                    exist, will be made in the mirror.
    echo.
    echo   REMOVE [name]    Deletes the specified file or folder from the mirror.
    echo.
    goto :end


@rem Functions
:find
    for /F %%a in ("!cd!") do set current_drive=%%~da\

    :findStartLoop
        set gitch_path="!cd!\gitch.txt"
        if exist !gitch_path! goto :findEndLoop
        if "!cd!"=="!current_drive!" (
            echo No gitch.txt file found in any parent folders.
            pause
            exit /b 1
        )
        cd ..
        goto findStartLoop

    :findEndLoop
    for /F "tokens=*" %%a in (gitch.txt) do set gitch_content=%%~a
    for /F "tokens=*" %%a in ("!cd!") do set mirror_path=!mirror_path:%%a=!

    set mirror_path=!gitch_content!!mirror_path!
    set mirror_leaf=!mirror_path!\!input!
    goto :eof

:mirrorExist
    if exist "!mirror_leaf!" goto :eof
    echo File or directory `!input!` does not exist in mirror
    pause
    exit /b 1

:error
    echo Fatal error: No files copied.
    pause
    exit /b 1

:end
    pause
    exit 0