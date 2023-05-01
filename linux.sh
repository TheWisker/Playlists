#!/bin/bash

#Script path variable
rd=$(dirname "$(realpath "$0")")

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
eecho 'This will also unzip the ffmpeg library thus it needs the unzip binary installed' cyan

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

#Move, extract and remove to set up the linux version
rm -fr "$rd/windows"
mv "$rd/linux/"* "$rd"
unzip "$rd/bin/ffmpeg.zip" "$rd/linux/bin"
unzip "$rd/bin/ffplay.zip" "$rd/linux/bin"
unzip "$rd/bin/ffprobe.zip" "$rd/linux/bin"
rm -fr "$rd/bin/ffmpeg.zip"
rm -fr "$rd/bin/ffplay.zip"
rm -fr "$rd/bin/ffprobe.zip"
rm -fr "$rd/linux"