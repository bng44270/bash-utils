#!/bin/bash

filepath() {
	if [ -f "$1" ]; then 
		FDIR="$(dirname $1)"
		pushd . 2>&1 > /dev/null
		cd $FDIR
		pwd
		popd 2>&1 > /dev/null
	else
		echo "$1: file not found"
	fi
}

if [ -z "$1" ]; then
	echo "usage: flaskwsgi.sh <python-file>"
else
	if [ -f $1 ]; then
		APPNAME="$(awk '/=[ \t]*Flask/ { print gensub(/^(.*)[ \t]*=.*$/,"\\1","g",$0); }' < $1)"
		PYFILE="$(sed 's/\.py$//g' <<< "$(basename $1)")"
		APPPATH="$(filepath $1)"
		
		cat <<HERE > $APPPATH/${PYFILE}.wsgi
import sys
sys.path.append('$APPPATH')

from $PYFILE import $APPNAME as application
HERE
		
	else
		echo "$1: file not fount"
	fi
fi
