@echo off
setlocal enabledelayedexpansion

set urls=()

if "%~1" neq "" (
    for %%a in (%*) do (
        set ext=%%~xa
        if /i "!ext!"==".desktop" || /i "!ext!"==".url" (
            if not exist "%arg%" (
                echo File not found: %arg%
                continue
            )

            for /f "tokens=2 delims==" %%b in ('type "%%~a" ^| findstr "^URL="') do (
                set "urls[!urls.length!]=%%b"
            )
        ) else (
            set "urls[!urls.length!]=%%a"
        )
    )
) else (
    set /p "urls[0]=Address [LL]: "
)

set /p "audio=Only Audio [Y/n]: "
set /p "cookies=Cookies [Y/n]: "

if not defined urls[0] || "%urls[0]%"=="" set "urls[0]='https://www.youtube.com/playlist?list=LL'"
if not defined audio || "%audio%"=="" set "audio=Y"
if not defined cookies || "%cookies%"=="" set "cookies=Y"

if /i "%audio%"=="Y" (
    set "audio=-x --audio-quality 0 -f 'bestaudio/bestaudio*/best' --match-filter 'duration<600'"
) else (
    set "audio=-f 'bestvideo+bestaudio/bestvideo*+bestaudio*/best'"
)

if /i "%cookies%"=="Y" (
    set "cookies=--cookies '.\cookies.txt'"
    if not exist .\cookies.txt (
        echo ERROR: .\cookies.txt does not exist. Create it or deactivate the cookies!
        exit /b 1
    )
) else (
    set "cookies=--no-cookies"
)

.\bin\yt-dlp.exe -U

mkdir ".\Output\Playlists"
mkdir ".\Output\Links\Linux"
mkdir ".\Output\Links\Windows"

.\bin\yt-dlp.exe --yes-playlist --download-archive metadata -N 3 -R 20 --buffer-size 10240 -P "%~dp0Output\Playlists" -o "%(playlist_title)s\%(title)s.%(ext)s" -o "thumbnail:%(playlist_title)s\thumbnails\%(title)s.%(ext)s" -o "infojson:%(playlist_title)s\jsons\%(title)s.%(ext)s" -o "subtitle:%(playlist_title)s\subtitles\%(title)s.%(ext)s" -o "description:%(playlist_title)s\descriptions\%(title)s.%(ext)s" -o "link:%(playlist_title)s\links\%(title)s.%(ext)s" --no-force-overwrites -c --write-description --write-info-json --write-playlist-metafiles --clean-info-json --cache-dir ".\Cache" --write-thumbnail --write-url-link --write-desktop-link --progress --console-title --write-subs --write-auto-subs  --no-keep-video --post-overwrites --embed-subs --embed-thumbnail --embed-metadata --embed-chapters --embed-info-json --sponsorblock-api "https://sponsor.ajay.app" --extractor-retries 5 ${audio[@]} ${cookies[@]} ${urls[@]} #--ffmpeg-location ".\bin\"

for /r %%f in (*.desktop) do move "%%f" ".\Output\Links\Linux\"
for /r %%f in (*.url) do move "%%f" ".\Output\Links\Windows\"

for /d /r ".\Output\Playlists" %%d in (*) do (
    pushd "%%d"
    if /i not "%%~dpd"=="%cd%" ( rd /s /q "%%d" )
    popd
)

for /f "usebackq" %%d in (`"dir /ad/b/s | sort /R"`) do rd "%%d"