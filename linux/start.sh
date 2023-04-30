#!/bin/bash

urls=()

if [ -n "$1" ]; then
	for arg in "$@"
	do
		if [[ $arg == *.desktop || $arg == *.url ]]; then

			if [ ! -f "$arg" ]; then
				echo "File not found: $arg"
				continue
			fi

			url=$(grep -oP '(?<=URL=).*' "$arg")
			url=$(sed 's/\r//' <<< "$url")
			urls+=("$url")
		else
			urls+=("$arg")
		fi
	done
else
	read -p "Address [LL]: " urls
fi

read -p "Only Audio [Y/n]: " audio
read -p "Cookies [Y/n]: " cookies
urls=${urls:-"https://www.youtube.com/playlist?list=LL"}
audio=${audio:-"Y"}
cookies=${cookies:-"Y"}
if [ ${audio^^} == "Y" ]; then
	audio=(-x --audio-quality 0 -f "bestaudio/bestaudio*/best" --match-filter "duration<600")
else
	audio=(-f "bestvideo+bestaudio/bestvideo*+bestaudio*/best")
fi

if [ ${cookies^^} == "Y" ]; then
	cookies=(--cookies "./cookies.txt")
	if [  ! -f ./cookies.txt ]; then
		echo "ERROR: ./cookies.txt does not exist. Create it or deactivate the cookies!"
		exit
	fi
else
	cookies=(--no-cookies)
fi

./bin/yt-dlp -U

mkdir -p ./Output/Playlists
mkdir -p ./Output/Links/{Linux,Windows}

./bin/yt-dlp --yes-playlist --download-archive metadata -N 3 -R 20 --buffer-size 10240 -P "$(dirname "$(realpath "$0")")/Output/Playlists" -o "%(playlist_title)s/%(title)s.%(ext)s" -o "thumbnail:%(playlist_title)s/thumbnails/%(title)s.%(ext)s" -o "infojson:%(playlist_title)s/jsons/%(title)s.%(ext)s" -o "subtitle:%(playlist_title)s/subtitles/%(title)s.%(ext)s" -o "description:%(playlist_title)s/descriptions/%(title)s.%(ext)s" -o "link:%(playlist_title)s/links/%(title)s.%(ext)s" --no-force-overwrites -c --write-description --write-info-json --write-playlist-metafiles --clean-info-json --cache-dir "./Cache" --write-thumbnail --write-url-link --write-desktop-link --progress --console-title --write-subs --write-auto-subs  --no-keep-video --post-overwrites --embed-subs --embed-thumbnail --embed-metadata --embed-chapters --embed-info-json --sponsorblock-api "https://sponsor.ajay.app" --extractor-retries 5 ${audio[@]} ${cookies[@]} ${urls[@]} #--ffmpeg-location "./bin/"

find . -name "*.desktop" -exec mv {} ./Output/Links/Linux/ \;
find . -name "*.url" -exec mv {} ./Output/Links/Windows/ \;
find ./Output/Playlists -mindepth 2 -maxdepth 2 -type d -exec rm -fr {} \;
find . -depth -type d -empty -exec rmdir {} \;
#mv ./Output/* ../Playlists/