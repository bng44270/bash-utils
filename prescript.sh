#!/bin/bash

if [ -z "$@" ]; then
	echo "usage: $0 <python-script>"
else
	egrep '^import|^from' $@ | sed 's/^import //g;s/^from //g' | awk '{ print $1 }' | while read line; do
		python -c "import $line" 2> /dev/null
		if [ $? -ne 0 ]; then
			sudo pip install $line
		else
			echo "Module $line already installed"
		fi
	done
fi