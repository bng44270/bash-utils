#!/bin/bash

#################################################
#
# Create MP4 video file from a collection of image files
#
# Image files are combined sequentially based on the
# modified timestamp of the image files.
#
# Usage:
#
#    img2mp4.sh -i <input-filespec> -o <output-mp4-file>
#
#################################################

getargs() {
	echo "$@" | sed 's/[ \t]*\(-[a-zA-Z][ \t]\+\)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }' | sed 's/""/"EMPTY"/g'
}

eval $(getargs "$@")

if [ -z "$ARG_i" ] || [ -z "$ARG_o" ]; then
	echo "usage: img2mp4.sh -i <input-filespec> -o <output-mp4-file>"
else
	ID="$RANDOM"
	MP4TMP="/tmp/img2mp4-$ID.mp4"
	
	printf "Generating $ARG_o..."
	convert -delay 1 $(ls -tr $ARG_i) $MP4TMP
	ffmpeg -v quiet -i $MP4TMP -filter:v "setpts=25*PTS" $ARG_o
	rm $MP4TMP
	printf "done\n"
fi