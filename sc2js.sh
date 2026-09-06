#!/bin/bash

if [ -z "$1" ]; then
	echo "usage:  conv.sh <sc-file>"
	exit 1
fi

if [ ! -f $1 ]; then
	echo "File not found ($1)"
	exit 1
fi

grep '^let\|^label\|^leftstring\|^rightstring' $1 | sed 's/^[^ \t]\+[ \t]\+\([A-Z]\+\).*$/\1/g' | sort | uniq | sed 's/^\(.*\)$/var \1 = new Array(200);/g'

awk 'function setTextVar(line) {
    R = ""

    if (!index(line,"\"") && (line ~ /[\+-\/\*]/)) {
        A = gensub(/^[^ \t]+[ \t]+([A-Z]+)([0-9]+)(.*)$/,"\\1\\2\\3","g",$0);
        R = gensub(/([A-Z]+)([0-9]+)/,"\\1[\\2]","g",A)
    }
    else {
        R = gensub(/^[^ \t]+[ \t]+([A-Z]+)([0-9]+)(.*)$/,"\\1[\\2]\\3","g",$0);
    }

    return R
}

function getArName(line) {
    return gensub(/^[^ \t]+[ \t]+([A-Z]+).*$/,"\\1","g",$0);
}

function arrayExists(list,char) {
    count = split(list,letters,"")
    return index(list,letters[count])
}

/^let/ {
    print setTextVar($0);
}

/^label/ { 
    print setTextVar($0);
}

/^leftstring/ { 
    print setTextVar($0);
}

/^rightstring/ { 
    print setTextVar($0);
}' < $1
