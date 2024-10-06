@echo off

set spath=%~dp0

rd /s /q "%spath%\linux"
del "%spath%\linux.sh"
robocopy %spath%\windows\ "%spath%" /MOVE /E
tar -xf "%spath%\bin\ffmpeg.zip" -C "%spath%\bin" && del /f "%spath%\bin\ffmpeg.zip"
tar -xf "%spath%\bin\ffplay.zip" -C "%spath%\bin" && del /f "%spath%\bin\ffplay.zip"
tar -xf "%spath%\bin\ffprobe.zip" -C "%spath%\bin" && del /f "%spath%\bin\ffprobe.zip"
del "%spath%\windows.bat"