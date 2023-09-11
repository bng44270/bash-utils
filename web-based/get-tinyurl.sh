#!/bin/bash

urlencode() {
	printf "$@" | hexdump -d  | grep '[0-9]* ' | awk '{ sub($1 FS,"");print}' | sed 's/[ \t]/\n/g' | grep -v '^$' | sed 's/^0*//g' | while read line; do 
		dbyteone=$(echo "$line/256" | bc)
                dbytetwo=$(echo "$line%256" | bc)
		numcheckone=$(echo $(seq 48 57) | grep $dbyteone)
	        upcheckone=$(echo $(seq 65 90) | grep $dbyteone)
	        lowcheckone=$(echo $(seq 97 122) | grep $dbyteone)
		numchecktwo=$(echo $(seq 48 57) | grep $dbytetwo)
	        upchecktwo=$(echo $(seq 65 90) | grep $dbytetwo)
	        lowchecktwo=$(echo $(seq 97 122) | grep $dbytetwo)
		if [ -z "$numcheckone" ] && [ -z "$upcheckone" ] && [ -z "$lowcheckone" ]; then
			byteone="%%$(echo "obase=16;$dbyteone" | bc)"
		else
			byteone=$(awk 'BEGIN {printf "%c",'"$dbyteone"'}')
		fi
		if [ -z "$numchecktwo" ] && [ -z "$upchecktwo" ] && [ -z "$lowchecktwo" ]; then
                        bytetwo="%%$(echo "obase=16;$dbytetwo" | bc)"
                else
                        bytetwo=$(awk 'BEGIN {printf "%c",'"$dbytetwo"'}')
                fi
		printf "$bytetwo$byteone"
	done | sed 's/%0$//g'
}

if [ -z "$1" ]; then
	echo "usage: get-tinyurl.sh <url>"
else
	encodedurl=$(urlencode $@)
	tinyurl=$(curl -s --data "url=$encodedurl" -X POST http://tinyurl.com/create.php | grep 'data-clipboard-text' | sed 's/^.*data-clipboard-text="//g;s/".*$//g')
	echo "Long URL: $@"
	echo "Tiny URL: $tinyurl"
fi