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

:: set number of threads according to CPU capacity
set THREADS=4
::if %COMPUTERNAME%=="YourToaster" set THREADS=2
::if %COMPUTERNAME%=="YourTank" set THREADS=8

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

:: #######################################################
:: SOBRAS/NOTAS ##########################################
:: #######################################################

Uso de SHIFT: Ver https://ss64.com/nt/shift.html

:: YT-DLP PARAMETERS:

:: -o [output file name . ".%%(ext)s" pone la ext adecuada según el tipo de archivo a descargar]
:: -x [downloads audio only] --audio-quality 0 -f 'bestaudio/bestaudio*/best' --match-filter 'duration<600'
:: --ffmpeg-location . [localización de la libraría ffmpeg]
:: --download-archive metadata [guarda lo que ha descargado y evita descargar lo mismo en el futuro]

:: .\bin\yt-dlp.exe %URL% -P .\output -o %~n1.%%(ext)s --no-playlist --ffmpeg-location .\bin --download-archive yt-dlp.log -N 4 -R 10 --console-title --write-description --write-thumbnail --embed-thumbnail --write-subs --embed-subs --embed-metadata --embed-chapters --write-info-json --embed-info-json --clean-info-json --write-playlist-metafiles --sponsorblock-api "https://sponsor.ajay.app"

::  .\bin\yt-dlp.exe %URL% -P .\output -o %~n1.%%(ext)s --ffmpeg-location .\bin --force-overwrite --no-playlist --download-archive yt-dlp.log -N 4 -R 10 --console-title  --sponsorblock-api "https://sponsor.ajay.app" 

:: #######################################################

