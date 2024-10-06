#!/bin/bash

#Script path variable
rd=$(dirname "$(realpath "$0")")

#Declares fg, bg and sp as associative arrays
declare -A fg
declare -A bg
declare -A sp

#Foreground color names to escape codes
fg[black]=30
fg[red]=31
fg[green]=32
fg[yellow]=33
fg[blue]=34
fg[purple]=35
fg[cyan]=36
fg[gray]=90
fg[white]=97

#Background color names to escape codes
bg[black]=40
bg[red]=41
bg[green]=42
bg[yellow]=43
bg[blue]=44
bg[purple]=45
bg[cyan]=46
bg[gray]=100
bg[white]=107

#Special names to escape codes
sp[reset]=0
sp[bold]=1
sp[dim]=2
sp[italic]=3
sp[underlined]=4

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

eecho '[Playlists Installer] - (Linux)' blue
echo ""
echo ""

eecho 'This will remove the Windows version and expand the Linux version.' cyan
echo ""
eecho 'This will also remove the ffmpeg library, and yt-dlp binary thus it needs them installed in the system.' cyan
echo ""
echo ""


if [ "$1" != "noconfirm" ]; then
	#Asks to continue
	eecho 'Continue [Y/n]: ' purple
	read continue
	echo ""
	if [ "${continue^^}" == "N" ]; then
		eecho 'Task aborted!' red
		echo ""
		exit
	else
		eecho 'Starting tasks!' green
		echo ""
	fi
	echo ""
fi

#Move, extract and remove to set up the linux version
rm -fr "$rd/windows"
rm -f "$rd/windows.bat"
mv "$rd/linux/"* "$rd"
rm -fr "$rd/bin/ffmpeg.zip"
rm -fr "$rd/bin/ffplay.zip"
rm -fr "$rd/bin/ffprobe.zip"
rm -fr "$rd/bin/yt-dlp"
rm -fr "$rd/linux"
rm -f "$rd/linux.sh"