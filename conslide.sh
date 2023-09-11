#!/bin/bash

################################################
#
# conslide.sh
#
# Display file-based text slides in the console
#
# Begin each slide in the file using #SLIDE
#
# Usage:
#   To view an existing slideshow:
#       conslide.sh -v <file>
#
#     To advance to next slide press any key
#
#     To move to previous slide press the "p" key
#
#   To create an new slideshow:
#       conslide.sh -c <file>

################################################

getslides() {
	(grep -n '^#SLIDE' "$@" ; wc -l "$@" ) | sed 's/^\([0-9]\+\).*$/\1/g' | awk 'BEGIN { first = 1; prev = 0; } { if (prev==0) { prev=$0+1 } else { thisone=$0-1; print prev " " thisone ; prev=$0+1 } }'
}

getlines () { 
	cat - <(seq 1 $[$2-$1] | sed 's/[0-9]//g') | head -n $(echo "$1+($2-$1)" | bc) | tail -n $(echo "$2-$1+1" | bc) | grep -v '^$'
}

getline() {
	head -n$1 | tail -n1
}

getslide() {
	getslides $2 | getline $1
}

if [ "$1" == "-c" ]; then
	if [ ! -f $2 ]; then
		FILE="$2"
		while true; do
			clear
			echo "Usage:"
			echo "  To save slide and advance to next slide press Ctrl-D"
			echo "  To exit leave slide blank and press Ctrl-D"
			echo "------------------------------------------------"
			SLIDE="$(cat)"
			[[ -z "$SLIDE" ]] && break
			echo "#SLIDE" >> $FILE
			echo -ne "$SLIDE\n\n" >> $FILE
		done
	else
		echo "File already exists ($2)"
	fi
elif [ "$1" == "-v" ]; then
	if [ -f $2 ]; then
		clear
		SLIDES="$(getslides "$2")"
		COUNT="$(wc -l <<< "$SLIDES" | awk '{ print $1 }')"
		for ((i=0; i < $COUNT; i++)); do
			THISSLIDE="$(getslide $[ $i+1 ] $2)"
			getlines $(awk '{ print $1 }' <<< "$THISSLIDE") $(awk '{ print $2 }' <<< "$THISSLIDE") < $2
			read -n1 -s goahead
			clear
			if [ "$goahead" == "p" ]; then
				if [ $i -eq 0 ]; then
					i=$[ $i-1 ]
				else
					i=$[ $i-2 ]
				fi
			fi
		done
	else
		echo "File not found ($1)"
	fi
else
	echo "usage:  conslide <-v | -c> <file>"
fi