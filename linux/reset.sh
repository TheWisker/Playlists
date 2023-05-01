#!/bin/bash

#Script path variable
rd=$(dirname "$(realpath "$0")")

#Removes files
rm -fr "$rd/log"
rm -fr "$rd/Cache"
rm -fr "$rd/Output"
rm -fr "$rd/yt-dlp.archive"
rm -fr "$rd/yt-dlp-ln.archive"
