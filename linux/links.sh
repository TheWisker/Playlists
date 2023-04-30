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

read -p "Cookies [Y/n]: " cookies
urls=${urls:-"https://www.youtube.com/playlist?list=LL"}
cookies=${cookies:-"Y"}

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

./bin/yt-dlp --yes-playlist --skip-download --download-archive lks_metadata -N 3 -R 20 --buffer-size 10240 -P "$(dirname "$(realpath "$0")")/Output/Playlists" -o "%(playlist_title)s/%(title)s.%(ext)s" -o "thumbnail:%(playlist_title)s/thumbnails/%(title)s.%(ext)s" -o "infojson:%(playlist_title)s/jsons/%(title)s.%(ext)s" -o "subtitle:%(playlist_title)s/subtitles/%(title)s.%(ext)s" -o "description:%(playlist_title)s/descriptions/%(title)s.%(ext)s" -o "link:%(playlist_title)s/links/%(title)s.%(ext)s" --no-force-overwrites -c --write-url-link --write-desktop-link --progress --console-title --extractor-retries 5 ${cookies[@]} ${urls[@]} #--ffmpeg-location "./bin/"

find . -name "*.desktop" -exec mv {} ./Output/Links/Linux/ \;
find . -name "*.url" -exec mv {} ./Output/Links/Windows/ \;
find . -depth -type d -empty -exec rmdir {} \;
#mv ./Output/* ../Playlists/