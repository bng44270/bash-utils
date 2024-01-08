#!/bin/bash

################################################
# st.sh - Symbol Translation
#
# Background:  I ran into some issues using m4 to translate
#              labels in Python code (due to the "len" function
#              being intercepted by m4 and thereby damaging
#              the Python code.
#
# Usage:
#
#   st.sh "<KEY1>=<VALUE1>" ["<KEY2>=<VALUE2>" ...] < INPUT-FILE > OUTPUT-FILE
#
# Example:
#
#   st.sh "LABEL1=This is value 1" "LABEL2=This is value 2" < /path/to/input-file > /path/to/output-file
#
#      This command will replace all instances of LABEL1 
#      with "This is value 1" and all instances of LABEL2
#      with "This is value 2" in /path/to/input-file and
#      output the modified text to /path/to/output-file
#
################################################

getpairs() {
	for arg in $(seq 1 ${#@}); do
		THISARG="$(sed 's/\//\\\//g' <<< "${!arg}")"
		K="$(sed 's/^\([^=]\+\)=.*$/\1/g' <<< "$THISARG")"
		V="$(sed 's/^[^=]\+=\(.*\)$/\1/g' <<< "$THISARG")"
		echo -n "s/$K/$V/g;"
	done
}

if [ -z "$1" ]; then
	echo "usage: st.sh \"<key1>=<value1>\" [\"<key2>=<value2>\" ...]"
else
	sed "$(getpairs "$@")"
fi
