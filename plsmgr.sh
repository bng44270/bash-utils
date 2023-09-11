#!/bin/bash

################################
# 
# plsmgr.sh
#
# Create/Manage PLS Playlist files
#
# Create new/modify existing playlist
#     plsmgr.sh -e <pls-file>
#
# Delete item from playlist
#     plsmgr.sh -d <index> <pls-file>
#
#     The <index> corresponds to "File<index>=URL"
#
################################

if [ -z "$1" ]; then
	echo "usage: $(basename $0) <-e | -d idx> <pls-file>"
else
	if [ "$1" == "-e" ]; then
		if [ -f $2 ]; then
			cp $2 $2.tmp
			rm $2
			echo "Enter URLs to add to file (one per line).  When you are finished press Ctrl-D on an empty line"
			while read url; do
				found=$(grep "$url" $2.tmp | wc -l)
				if [ $found -eq 0 ]; then
					echo $url
				fi
			done | cat <(grep '^File[0-9]*' $2.tmp | sed 's/^File[0-9]*=//g') - | grep '^[a-zA-Z]*://' | awk 'BEGIN { COUNT=0 } { print COUNT " " $0 ; COUNT++ }' | while read line; do
				plsidx=$(echo $line | awk '{ print $1 }')
	                        plsurl=$(echo $line | sed 's/^[0-9]* //g')
	                        echo "File$plsidx=$plsurl" | tee -a $2
	                done | wc -l | echo "NumberOfEntries=$(cat - | awk '{ print $0 "-1" }' | bc)" >>  $2
			rm $2.tmp
		else
			echo "Enter URLs for streaming audio (one per line).  When you are finished press Ctrl-D on an empty line"
			while read url; do
				echo $url
			done | grep '^[a-zA-Z]*://' | awk 'BEGIN { COUNT=0 } { print COUNT " " $0 ; COUNT++ }' | while read line; do
				plsidx=$(echo $line | awk '{ print $1 }')
				plsurl=$(echo $line | sed 's/^[0-9]* //g')
				echo "File$plsidx=$plsurl" | tee -a $2
			done | wc -l | echo "NumberOfEntries=$(cat - | awk '{ print $0 "-1" }' | bc)" >>  $2
		fi
	elif [ "$1" == "-d" ]; then
		if [ -f $3 ]; then
			cp $3 $3.tmp
			rm $3
			grep -v "^File${2}=" $3.tmp | sed 's/^File[0-9]*=//g' | grep '^[a-zA-Z]*://' | awk 'BEGIN { COUNT=0 } { print COUNT " " $0 ; COUNT++ }' | while read line; do
                                plsidx=$(echo $line | awk '{ print $1 }')
                                plsurl=$(echo $line | sed 's/^[0-9]* //g')
                                echo "File$plsidx=$plsurl" | tee -a $3
                        done | wc -l | echo "NumberOfEntries=$(cat - | awk '{ print $0 "-1" }' | bc)" >>  $3
			rm $3.tmp
		else
			echo "Error:  $3 does not exist"
		fi
	fi
fi