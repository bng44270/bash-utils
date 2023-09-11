#!/bin/bash

######################################################
#
# Terminal-based web radio player (requires ffplay)
#
# Usage:
#
#    1) Create M3U playlist file using the following syntax:
#
#          #EXTINF:0,<Radio Station Name>
#          <Radio Station URL>
#
#    2) Repease step 1 for each radio station
#
#    3) Update the PLAYLIST variable below with the full
#       path to the M3U playlist you created
#
###################################################### 

PLAYLIST="/path/to/playlist.m3u"

CSSTR="$(awk 'BEGIN { FS="," } /^#EXTINF:/ { printf("%s ",$2); }' < $PLAYLIST)"

eval "CSAR=($CSSTR)"

timer() {
	counter="0"
	while true; do
		OC="$counter"
		hours="$[ $counter / 3600 ]"
		thisc="$[ $counter % 3600 ]"
		minutes="$[ $thisc / 60 ]"
		seconds="$[ $thisc % 60 ]"
		printf "                 \r%d:%02d:%02d" "$hours" "$minutes" "$seconds"
		sleep 1
		counter="$[ $OC + 1 ]"
	done
}

while true; do
	clear
	echo "************"
	echo "* Stations *"
	echo "************"
	for IDX in $(seq 0 $[ ${#CSAR[@]} - 1 ]); do
		echo "$[ $IDX + 1] - ${CSAR[$IDX]}"
	done
	echo ""
	read -p "> " CSIDX

	radiourl="$(awk 'BEGIN { FS="," } /^#EXTINF:.*'"${CSAR[$[ $CSIDX - 1 ]]}"'/ { getline; print $0 }' < $PLAYLIST)"
		
	if [ -n "$radiourl" ]; then
		echo "Playing ${CSAR[$[ $CSIDX - 1 ]]}..."
		timer &
		ffplay -loglevel 8 -nodisp "$radiourl"
	fi
done