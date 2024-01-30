#!/bin/bash

############################
# dockerpsname.sh
#
# Runs docker ps while displaying
# the image name along with the ID
#
# Requires sudo access
############################

sudo docker ps -a | while read line; do
	PSIMG="$(awk '{ print $2 }' <<< "$line")"
	if [ "$PSIMG" == "ID" ]; then
		echo "$line"
	else
		IMGNAME="$(sudo docker image ls | awk -v psimg="$PSIMG" 'NR>1 { if ($3 == psimg) print $1 }')"
		sed 's/'"$PSIMG"'/'"$PSIMG ($IMGNAME)"'/g' <<< "$line"
	fi
done
