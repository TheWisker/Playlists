#!/bin/bash

rm -fr ./windows
mv ./linux/* .
unzip ./bin/ffmpeg.zip -d ./bin
rm -fr ./bin/ffmpeg.zip