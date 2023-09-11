#!/bin/bash

#####################################
# Correct Horse Battery Staple Random Password Generator
#
#  Usage:
#       chbs.sh <word-count> <password-length>
#####################################

if [ -z "$1" ]; then
	echo "usage: chbs.sh <word-count> <password-length>"
else
	WORDLIST="$(curl -s http://correcthorsebatterystaple.net/data/wordlist.txt | sed 's/,/\n/g;s/ //g' | awk '{ print length, $0 }')"
	while true; do
		NEWPASS="$(echo "$WORDLIST" | sort -R | head -n$1 | awk '{ printf("%s",$2); }')"
		if [ ${#NEWPASS} -eq $2 ]; then
			echo "$NEWPASS"
			break
		fi
	done
fi