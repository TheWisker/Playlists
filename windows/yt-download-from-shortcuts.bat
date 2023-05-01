:: USAGE:
:: Param 1 is the type of download: -a / -v (AUDIO / VIDEO)
:: Input: set of URL shortcuts (.url, .website, .desktop). Works by dragging and dropping one or more shortcuts to be downloaded as Audio/Video files
@echo off

:: Set processing settings
set TARGETDIR=%USERPROFILE%\Downloads\YT-Downloads
if not exist %TARGETDIR% md %TARGETDIR%
set PGMPATH=%~dp0

:: Set mode (audio/video)
if "%~1"=="" goto ERROR1
if "%~1"=="-a" (set MODE=AUDIO) else (if "%~1"=="-v" (set MODE=VIDEO) else (goto ERROR1))
if "%~2"=="" goto ERROR2

:: set number of threads according to your CPU capacity
set THREADS=4

:: Display settings to show what's going to be done
echo [PGM] %~nx0
echo [MODE] %MODE%

:Loop
  set URL=
  echo -------------------------------------------
  if "%~2"=="" echo [FINISHED] & goto END
  echo [SHORTCUT] %2
  find /v "BASEURL=" < "%~2" | find /v "ORIGURL=" | find "URL" >%TARGETDIR%\tmp-file.tmp
  for /F %%a in (%TARGETDIR%\tmp-file.tmp) do set %%a
  echo [URL] "%URL%"
  echo.
  call :YT-Downloader "%~2"
  shift /2
goto Loop

:: ------------------------------
:YT-Downloader
if %MODE%==VIDEO (
"%PGMPATH%\bin\yt-dlp.exe" -N %THREADS% -R 10 --embed-chapters --embed-thumbnail  --embed-subs --embed-metadata --no-playlist --console-title --sponsorblock-api "https://sponsor.ajay.app" --download-archive "%PGMPATH%\yt-dlp_video.log" -P "%TARGETDIR%" -o "%~n1.%%(ext)s" --ffmpeg-location "%PGMPATH%/bin/" "%URL%"
)
if %MODE%==AUDIO (
"%PGMPATH%\bin\yt-dlp.exe" -N %THREADS% -R 10 -x --embed-thumbnail --embed-metadata --no-playlist --console-title --sponsorblock-api "https://sponsor.ajay.app" --download-archive "%PGMPATH%\yt-dlp_audio.log" -P %TARGETDIR% -o "%~n1.%%(ext)s" --ffmpeg-location "%PGMPATH%/bin/" "%URL%"
)
exit /b 0

:: ------------------------------
:ERROR1
color 4E
echo ERROR: Parameter 1 [%~1] is wrong or missing (audio/video)
goto ERROREND

:: ------------------------------
:ERROR2
color 4E
echo ERROR: No shortcuts to process (drag and drop URL shortcuts)
goto ERROREND

:: ------------------------------
:ERROREND
echo.
echo Usage: %~nx0 -a ^|-v [URL Shortcuts 1..N]
goto END

:: ------------------------------
:END
echo [END]
:: Cleaning trash
if exist %TARGETDIR%\tmp-file.tmp del %TARGETDIR%\tmp-file.tmp
timeout 6
exit
