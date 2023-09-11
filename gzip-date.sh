#!/bin/bash

#########################################
#
# gzip-date.sh  - extract server date/time from GZIPed HTTP Date
#
#  based on https://github.com/jcarlosn/gzip-http-time/blob/master/time.php
#
#  usage:  ./gzip-date.sh <url>
#
#########################################

if [ -z "$1" ]; then
	echo "usage: gzip-date.sh <FILE | URL>"
else
	toprow=""

	if [ -f "$1" ]; then
		toprow=$(cat $2 | hexdump -C | head -n 1)
	else
		toprow=$(curl -sL0 --raw --compressed -k $2 | hexdump -C | head -n 1)
	fi
	
	if [ -n "$toprow" ]; then	
		checkbyte=$(printf "$toprow" | awk '{ print $2 $3 }')
		if [ "$checkbyte" == "1f8b" ]; then
			time=$(printf "$toprow" | awk '{ print $9 $8 $7 $6 }')
		        if [ "$time" == "00000000" ]; then
				echo "GZIP time is not availble"
			else
				echo "GZIP Date:  $(date -d @$((16#$time)))"
			fi
		else
			echo "web server does not use GZIP"
		fi
	else
		echo "Invalid option"
	fi
fi