#!/bin/bash
# Rip thumnails and archive them 

# shellcheck source=config
# shellcheck disable=SC1091
source "$ARM_CONFIG"
MAINDIR=$1
MOVIE=$2

mkdir  "$MAINDIR/IDFrames2"
#ffmpeg -i "$MOVIE"  -r .2 "$MAINDIR/IDFrames/frame-%03d.jpg"
ffmpeg -hide_banner -loglevel error -nostats -i "$MOVIE"  -vf "select='eq(pict_type,PICT_TYPE_I)'" -vsync vfr "$MAINDIR/IDFrames2/frame-%03d.jpg"

