#!/bin/bash

#############################################################3
#
# sc2js.sh - Convert sc (spreadsheet calculator) files to JavaScript file
#
# Generates arrays represeting cells
#
# Usage:
#
#      sc2js.sh -f <sc-file>
#
# Optional usage (specify JS array length, default is 100:
#
#      sc2js.sh -f <sc-file> -l 500
#
#############################################################3

getargs() {
	echo "$@" | sed 's/[ \t]*\(-[a-zA-Z][ \t]\+\)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }' | sed 's/""/"EMPTY"/g'
}

eval $(getargs $@)

if [ -z "$ARG_f" ]; then
	echo "usage:  conv.sh -f <sc-file> [-l <array-length>]"
    echo "             default <array-length> is 100"
	exit 1
fi

if [ ! -f $ARG_f ]; then
	echo "File not found ($1)"
	exit 1
fi

ARLEN="$([[ -z "$ARG_l" ]] && echo "100" || echo "$ARG_l")"

grep '^let\|^label\|^leftstring\|^rightstring' $ARG_f | sed 's/^[^ \t]\+[ \t]\+\([A-Z]\+\).*$/\1/g' | sort | uniq | sed 's/^\(.*\)$/var \1 = new Array('"$ARLEN"');/g'

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
}' < $ARG_f
