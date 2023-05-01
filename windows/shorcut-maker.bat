@echo off

set SCRIPT="%~dp0shorcut-maker-temp.vbs"

echo Set WS = WScript.CreateObject("WScript.Shell") >> %SCRIPT%

echo Set LinkO1 = WS.CreateShortcut("%~dp0YT-DLP Audio D+D.lnk") >> %SCRIPT%
echo LinkO1.TargetPath = "%~dp0yt-download-from-shortcuts.bat" >> %SCRIPT%
echo LinkO1.Arguments = "-a" >> %SCRIPT%
echo LinkO1.WorkingDirectory = "%~dp0" >> %SCRIPT%
echo LinkO1.Save >> %SCRIPT%

echo Set LinkO2 = WS.CreateShortcut("%~dp0YT-DLP Video D+D.lnk") >> %SCRIPT%
echo LinkO2.TargetPath = "%~dp0yt-download-from-shortcuts.bat" >> %SCRIPT%
echo LinkO2.Arguments = "-v" >> %SCRIPT%
echo LinkO2.WorkingDirectory = "%~dp0" >> %SCRIPT%
echo LinkO2.Save >> %SCRIPT%

cscript /nologo %SCRIPT%
del %SCRIPT%

timeout /t 6