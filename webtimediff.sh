#!/bin/bash

abs() {
	[[ $[ $@ ] -lt 0 ]] && echo "$[ ($@) * -1 ]" || echo "$[ $@ ]"
}

gethosttime() {
	curl -v "$@" 2>&1 | awk '/^< Date:/ { print gensub(/^<[ \t]+Date:[ \t]+/,"","g",$0); }' | date +%s
}

if [ -z "$1" ] && [ -z "$2" ]; then
	echo "usage: webtimediff.sh	<url-1> <url-2>"
else
	H1="$(gethosttime "$1")"
	H2="$(gethosttime "$2")"
	HDIF="$(abs $H1-$H2)"
	if [ $H1 -gt $H2 ]; then
		echo "$1 is $HDIF seconds ahead of $2"
	elif [ $H2 -gt $H1 ]; then
		echo "$2 is $HDIF seconds ahead of $1"
	else
		echo "Time is in sync"
	fi
fi
