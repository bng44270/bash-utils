#!/bin/bash

ZONEFILEDIR="/usr/share/zoneinfo"
ZONEFOLDERNAME=$(echo $ZONEFILEDIR | awk 'BEGIN { FS="/" }  { print $NF }')

usage() {
	echo "usage: change-timezone.sh <-l [SEARCH] | -s ZONE>"
        echo "     -l -> List available timezones and search for SEARCH"
        echo "     -s -> Set timezone to ZONE (requires sudo/root access)"
}

if [ -z "$1" ]; then
	usage
else
	if [ "$1" == "-l" ]; then
		if [ -z "$2" ]; then
			find -L $ZONEFILEDIR -type f | sed 's/^.*\/'"$ZONEFOLDERNAME"'\///g' | egrep -v '^right|^posix' | sort -d | more
		else
			find -L $ZONEFILEDIR -type f | sed 's/^.*\/'"$ZONEFOLDERNAME"'\///g' | egrep -v '^right|^posix' | sort -d | grep "$2" | more
		fi
	elif [ "$1" == "-s" ]; then
		if [ -f "$ZONEFILEDIR/$2" ]; then
			rm /etc/localtime
			ln -s $ZONEFILEDIR/$2 /etc/localtime
		else
			echo "Timezone $2 doesn't exist"
		fi
	else
		usage
	fi
fi