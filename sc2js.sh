#!/bin/bash

#############################################################3
#
# sc2js.sh - Convert sc (spreadsheet calculator) files to JavaScript file
#
# Generates a dictionary where the key is the column letter and the value
# is an array representing the column data
#
# NOTE:  this conversion only works with the following operations:
# 
#          - Basic Math (addition, subtraction, multiplication, and division
#          - Exponents (caret operator)
#          - SC Functions:
#               - @sum, @prod, and @avg
#               - @min and @max
#               - @log, @ln, and @exp
#               - @stddevThe Modern Alternative (sc-im): Active enthusiasts revived the concept under sc-im, keeping a terminal-based spreadsheet alive with support for colors, undo/redo, Lua scripting, and basic file compatibility. 
#
# Usage:
#
#      sc2js.sh -f <sc-file>
#
# Optional usage (specify the number of rows each column, default is 100:
#
#      sc2js.sh -f <sc-file> -r 500
#
#############################################################3

getargs() {
	echo "$@" | sed 's/[ \t]*\(-[a-zA-Z][ \t]\+\)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }' | sed 's/""/"EMPTY"/g'
}

eval $(getargs $@)

if [ -z "$ARG_f" ]; then
	echo "usage:  conv.sh -f <sc-file> [-r <row-count>]"
    echo "             default <row-count> is 100"
	exit 1
fi

if [ ! -f $ARG_f ]; then
	echo "File not found ($ARG_f)"
	exit 1
fi

ROWS="$([[ -z "$ARG_r" ]] && echo "100" || echo "$ARG_r")"

AWK_LIB_SRC='function getCellData(line) {

    R = gensub(/^[^ \t]+[ \t]+([A-Z]+)([0-9]+)(.*)$/,"data[\"\\1\"][\\2]\\3","g",line);
    if (line ~ /"/ || !(line ~ /[\+-\/\*\^]/)) {
        R = convertRanges(R)
    }
    
    return R
}

function convertRanges(A) {
    CELLS = "";

    for (i = 1; i <= 26; i++) {
        ALPHA[i] = sprintf("%c",i+64);
    }

    if (A ~ /[A-Z]+[0-9]+:[A-Z]+[0-9]+/) {
        RAN = gensub(/^.*([A-Z]+)([0-9]+):([A-Z]+)([0-9]+).*$/,"\\1-\\2-\\3-\\4","g",A);
        count = split(RAN,rangenums,"-");
        LOWCOL = rangenums[1];
        HICOL = rangenums[3];
        LOWROW = rangenums[2] + 0;
        HIROW = rangenums[4] + 0;

        GOING = 0;

        if (LOWCOL == HICOL) {
            for (r = LOWROW; r <= HIROW; r++) {
                CELLS = CELLS LOWCOL r ",";
            }
        }
        else {
            for (i = 1; i <=26; i++) {
                if (LOWCOL == ALPHA[i]) {
                    GOING = 1;
                    for (r = LOWROW; r <= HIROW; r++) {
                        CELLS = CELLS ALPHA[i] r ",";
                    }
                    continue
                }

                if (HICOL == ALPHA[i]) {
                    for (r = LOWROW; r <= HIROW; r++) {
                        CELLS = CELLS ALPHA[i] r ",";
                    }
                    break
                }

                if (GOING == 1) {
                    for (r = LOWROW; r <= HIROW; r++) {
                        CELLS = CELLS ALPHA[i] r ",";
                    }
                }
            }
        }

        CELLS = gensub(/^(.*)[A-Z]+[0-9]+:[A-Z]+[0-9]+(.*)$/,"\\1" CELLS "\b \b" "\\2","g",A);
    }
    else {
        CELLS = A;
    }

    return CELLS;
}

function getArName(line) {
    return gensub(/^[^ \t]+[ \t]+([A-Z]+).*$/,"\\1","g",$0);
}'

AWK_DATA_SRC='/^let/ {
    print getCellData($0);
}

/^label/ { 
    print getCellData($0);
}

/^leftstring/ { 
    print getCellData($0);
}

/^rightstring/ { 
    print getCellData($0);
}'

AWK_DEF_SRC='/^let/ {
    print getArName($0);
}

/^label/ { 
    print getArName($0);
}

/^leftstring/ { 
    print getArName($0);
}

/^rightstring/ { 
    print getArName($0);
}'

REPL_CODE='
    s/\([A-Z]\+\)\([0-9]\+\)/data["\1"][\2]/g;
    s/\^/**/g;
    s/@sqrt/Math.sqrt/g
    s/@exp(\([^)]\+\))/(Math.E**\1)/g;
    s/@log/Math.log/g;
    s/@ln(\([^)]\+\))/(Math.log(\1)\/Math.log(Math.E))/g;
    s/@min/Math.min/g;
    s/@max/Math.max/g;
    s/@avg/average/g;
    s/@sum/sumnums/g;
    s/@prod/product/g;
    s/@stddev/stddev/g
'

cat <<HERE
/*
    Be sure to copy all of the lines
    including the constants defined below
*/
const average = (...args) => args.reduce((sum, num) => sum + num, 0) / args.length;
const sumnums = (...args) => args.reduce((sum, num) => sum + num, 0);
const product = (...args) => args.reduce((prod, num) => prod * num, 1);
const stddev = (...points) => Math.sqrt(points.reduce((sum, value) => sum + Math.pow(value - (points.reduce((sum, value) => sum + value, 0) / points.length), 2), 0) / (points.length - 1));
var data = {};
HERE

awk "$AWK_LIB_SRC $AWK_DEF_SRC" $ARG_f | sort | uniq | awk -v len="$ROWS" '{ printf("data[\"%s\"] = new Array(%d);\n",$0,len); }'

awk "$AWK_LIB_SRC $AWK_DATA_SRC" $ARG_f | sort | sed "$REPL_CODE"
