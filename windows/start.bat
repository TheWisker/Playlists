@echo off
setlocal enabledelayedexpansion

set urls=()

if "%~1" neq "" (
    for %%a in (%*) do (
        set ext=%%~xa
        if /i "!ext!"==".desktop" || /i "!ext!"==".url" (
            for /f "tokens=2 delims==" %%b in ('type "%%~a" ^| findstr "^URL="') do (
                set "urls[!urls.length!]=%%b"
            )
        )
    )

)


if %idx%==0 (
    echo No .desktop or .url files found.
) else (
    echo Found %idx% .desktop or .url files.
    for /l %%i in (1,1,%idx%) do (
        echo URL %%i: !urls[%%i]!
    )
)
