#!/bin/bash
# Wrapper utility for managing playlists and dropping urls to be downloaded with yt-dlp
# Work scheme:
# ·· Initializes variables
# ·· Declares functions
# ·· Outputs the title
# ·· Checks if there are parameters:
# .... (false) Asks for an url
# .... (true) Checks for each parameter if it is a file or an url:
# ......... (file) Extracts the URL field and adds it to the urls array
# ......... (url) Adds it to the urls array
# ·· Asks for the format (video/audio) if not previously defined
# ·· Asks for cookies (yes/no) if not previously defined
# ·· Prints a summary and asks to continue
# ·· Updates yt-dlp if it was not used for more than one day if using it self-contained
# ·· Makes output directories
# ·· Constructs the command and executes it
# ·· Sorts the output files and cleans
# ·· Prints a summary of the output
# ·· Gives a successful message
# ·· Exits

#Duplicate all output to a log file
mkdir -p $(dirname "$(realpath "$0")")/log
exec &> >(tee $(dirname "$(realpath "$0")")/log/$(basename "${0%.*}").log)

#Starts bash unofficial strict mode: [http://redsymbol.net/articles/unofficial-bash-strict-mode/]
#set -euo pipefail
IFS=$'\n\t'

#Initialize array of urls to download
urls=()

#Script path variable
rd=$(dirname "$(realpath "$0")")

#Output path
out=${out:-"$rd/Output"}

#Sources the color definitions
source "$rd/bin/colors.sh"

#Output formating function:
# $1 --> Output text
# $2 --> Foreground color
# $3 --> Other flags
function eecho {
	#Sets defaults
	fc=${2:-white}
	sc=${3:-bold}

	#Echoes the colorized output
	echo -ne "\e[${fg[$fc]};${sp[$sc]}m$1\e[${sp[reset]}m"
	return 0
}

#Outputs the title
eecho '[Playlists Manager]' blue
echo ""
echo ""

#Checks if parameters were passed and if not it asks for an url
if [ -z "$1" ]; then
	#Asks for an URL defaulting to the Liked Videos playlist
	eecho 'Target [LL]: ' purple
	read urls
	urls=${urls:-"https://www.youtube.com/playlist?list=LL"}
else
	#Loops trough all the parameters and extracts the urls to the urls array
	for arg in "$@"
	do
		#Discerns if the paramter is a file or an url
		if [[ $arg == *.desktop || $arg == *.url || $arg == *.website ]]; then
			#Extracts the url if the parameter is a .desktop, .url or .website file
			if [ ! -f "$arg" ]; then
				eecho "Error: file not found ($arg)" red
				echo ""
				continue
			fi

			url=$(grep -oP '(?<=URL=).*' "$arg")
			url=$(sed 's/\r//' <<< "$url")
			urls+=("$url")
		else
			#Adds the parameter to the array assuming it is an url
			urls+=("$arg")
		fi
	done
fi

if [ ! -z "$audio" ]; then
	#Asks if it should download only audio defaulting to yes
	eecho 'Audio only [Y/n]: ' purple
	read audio
	audio=${audio:-"Y"}
fi

if [ ! -z "$cookies" ]; then
	#Asks if it should use cookies defaulting to yes
	eecho 'Cookies [Y/n]: ' purple
	read cookies
	cookies=${cookies:-"Y"}
	echo ""
fi

#Prints out the summary of the task
eecho '[Summary]' blue
echo ""

#Prints out the download targets (urls)
eecho '· [Targets]' blue
echo ""
for url in "${urls[@]}"; do
	eecho "··· $url" cyan
	echo ""
done

#Prints out the output folder
eecho '· [Output]' blue
echo ""
eecho "··· $out/" cyan
echo ""

#Prints out if it is going to use an archive file
eecho '· [Archive]' blue
echo ""
if [ -f "$out/Playlists/yt-dlp.archive" ]; then
	eecho '··· Status: Found' cyan
	echo ""
	eecho "··· Path: $out/Playlists/yt-dlp.archive" cyan
else
	eecho '··· Status: Not found' cyan
fi
echo ""

#Prints out the format it is going to use
eecho '· [Format]' blue
echo ""
if [ ${audio^^} == "Y" ]; then
	eecho '··· Audio only' cyan
else
	eecho '··· Video + Audio' cyan
fi
echo ""

#Prints out if it is going to use cookies
eecho '· [Cookies]' blue
echo ""
if [ ${cookies^^} == "Y" ]; then
	eecho '··· Enabled' cyan
else
	eecho '··· Disabled' cyan
fi
echo ""
echo ""

#Asks to continue
eecho 'Continue [y/N]: ' purple
read continue
echo ""
if [ ! "${continue^^}" == "Y" ]; then
	eecho 'Task aborted!' red
	echo ""
	exit
else
	eecho 'Starting tasks!' green
	echo ""
fi
echo ""

if [ -f "$rd/bin/yt-dlp" ]; then
	#Updates yt-dlp if it was not used for more than one day
	if ! [[ $(find "$rd/bin/" -type f -name "yt-dlp" -atime +0) ]]; then
		eecho 'Updating yt-dlp!' green
		echo ""
		"$rd/bin/yt-dlp" -U
	fi
fi

#Makes output directories
mkdir -p "$out/Playlists"
mkdir -p "$out/Links/"{Linux,Windows}
eecho "mkdir: $out/Playlists" green
echo ""
eecho "mkdir: $out/Links/Linux" green
echo ""
eecho "mkdir: $out/Links/Windows" green
echo ""
echo ""

#Sets the ffmpeg flags needed depending on self-contained usage
if [ -f "$rd/bin/ffmpeg" ]; then
	ffmpeg=(--ffmpeg-location "$rd/bin/")
else
	ffmpeg=()
fi

#Sets the yt-dlp binary to use depending on self-contained usage
if [ -f "$rd/bin/yt-dlp" ]; then
	ytdlp="$rd/bin/yt-dlp"
else
	ytdlp="yt-dlp"
fi

#Sets the audio flags needed depending on its own value
if [ ${audio^^} == "Y" ]; then
	audio=(-x --audio-quality 0 -f "bestaudio/bestaudio*/best" --match-filter "duration<600")
else
	audio=(-f "bestvideo+bestaudio/bestvideo*+bestaudio*/best")
fi

#Sets the cookies flags needed depending on its own value
if [ ${cookies^^} == "Y" ]; then
	cookies=(--cookies "./cookies.txt")
	if [ ! -f "$rd/cookies.txt" ]; then
		eecho 'Error: ./cookies.txt does not exist. Create it or deactivate the cookies!' red
		echo ""
		exit
	fi
else
	cookies=(--no-cookies)
fi

#Performs the downloads
eecho "Starting downloads!" green
echo ""
echo ""
"$ytdlp" --download-archive "$out/Playlists/yt-dlp.archive" -N $(nproc) -R 12 --no-playlist --buffer-size 10240 \
-P "$out/Playlists" -o "%(playlist_title)s/%(title)s.%(ext)s" -o "thumbnail:%(playlist_title)s/thumbnails/%(title)s.%(ext)s" \
-o "infojson:%(playlist_title)s/jsons/%(title)s.%(ext)s" -o "subtitle:%(playlist_title)s/subtitles/%(title)s.%(ext)s" \
-o "description:%(playlist_title)s/descriptions/%(title)s.%(ext)s" -o "link:%(playlist_title)s/links/%(title)s.%(ext)s" \
--no-force-overwrites -c --write-description --write-info-json --write-playlist-metafiles --clean-info-json --cache-dir "~/.cache/yt-playlist" \
--write-thumbnail --write-url-link --write-desktop-link --progress --console-title --write-subs --write-auto-subs --no-keep-video \
--post-overwrites --embed-subs --embed-thumbnail --embed-metadata --embed-chapters --embed-info-json --sponsorblock-api "https://sponsor.ajay.app" \
--extractor-retries 5 ${ffmpeg[@]} ${audio[@]} ${cookies[@]} ${urls[@]}

#Sorts the output files and cleans
find "$out/Playlists" -name "*.desktop" -exec mv -nf {} "$out/Links/Linux/" \;
find "$out/Playlists" -name "*.url" -exec mv -nf {} "$out/Links/Windows/" \;
find "$out/Playlists" -mindepth 2 -maxdepth 2 -type d -exec rm -fr {} \;
find "$rd" -depth -type d -empty -exec rmdir {} \;

#Prints an output summary
echo ""
eecho '[Output]' blue
echo ""

#Prints the playlists path and names
eecho '·[Playlists]' blue
echo ""
eecho "·· Path: $out/Playlists/" cyan
echo ""
for dir in $(find "$out/Playlists/" -mindepth 1 -maxdepth 1 -type d ! -name . -printf '%f\n'); do
    eecho "··· $dir ($(ls -1 "$dir" | wc -l))" cyan
	echo ""
done

#Prints the links paths
eecho '·[Links]' blue
echo ""
eecho '··[Linux]' blue
echo ""
eecho "··· Path: $out/Links/Linux/" cyan
echo ""
eecho '··[Windows]' blue
echo ""
eecho "··· Path: $out/Links/Windows/" cyan
echo ""
echo ""

#Outputs that the task was successful
eecho 'Successfully performed all tasks!' green
echo ""

exit
