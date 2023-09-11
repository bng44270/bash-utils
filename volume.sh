#!/bin/bash

######################
# Installation:
#   1) Create the following symbolic links to volume.sh
#       - volume-up.sh
#       - volume-down.sh
#       - volume-mute.sh
#
#   2) Modify the values of MIXER and VOLSTEP below to represent the
#      Alsa Mixer and volume step value respectively
#
#   3) Assign keyboard shortcuts to execute the specific shell scripts to
#      display informational notifications
######################



MIXER="Master"
VOLSTEP="10"

getvol() {
	amixer sget "$MIXER" | awk '/%/ { print gensub(/^.*\[([0-9]+)%\].*$/,"\\1",$0); exit; }' 2> /dev/null
}

ismuted() {
	amixer sget "$MIXER" | grep '\[off\]'
}

volume() {
	if [ "$1" == "up" ]; then
		[[ $(getvol) -lt 100 ]] && amixer sset "$MIXER" $[ $(getvol) + $([[ $(getvol) -lt $VOLSTEP && $(getvol) -ne 0 ]] && echo "$[ $VOLSTEP % $(getvol) ]" || echo "$VOLSTEP") ]% || amixer sget "$MIXER"
		notify-send "Volume" "$(getvol)%"
	fi

	if [ "$1" == "down" ]; then
		[[ $(getvol) -gt 0 ]] && amixer sset "$MIXER" $[ $(getvol) - $([[ $(getvol) -lt $VOLSTEP && $(getvol) -ne 0 ]] && echo "$[ $VOLSTEP % $(getvol) ]" || echo "$VOLSTEP") ]% || amixer sget "$MIXER"
		notify-send "Volume" "$(getvol)%"
	fi

	if [ "$1" == "mute" ]; then
		if [ -n "$(ismuted)" ]; then
			amixer sset "$MIXER" unmute
			notify-send "Volume" "Unmuted"
		else
			amixer sset "$MIXER" mute
			notify-send "Volume" "Muted"
		fi
	fi
}

volume $(basename $0 | sed 's/volume-\([^\.]\+\)\.sh$/\1/g')