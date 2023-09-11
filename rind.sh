#!/bin/bash

####################################
# rind.sh
#
# Template creation and rendering script
#
# Example:
#    Template file: 
#        greeting.txt.tpt (contents)
#            Greetings <<NAME>>>
#    Variable file
#        greeting.txt.var (contents)
#            NAME Silence Dogood
#
#    Render greeting.txt:
#        rind.sh -o file -f greeting.txt
#
#    Render greeting.txt to STDOUT
#        rind.sh -o stdout -f greeting.txt
#
# This is a very simple example but it can be expanded
# to do m4-style variable replacement on large files
####################################

getargs() {
	echo "$@" | sed 's/[ \t]\+\(-[a-zA-Z][ \t]\+\)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }'
}

[[ -n "$@" ]] && eval "$(getargs "$@")"

if [ -z "$ARG_f" ]; then
	echo "usage: rind.sh -o <file|stdout> -f <filename>"
	echo "    Required files:"
	echo "            <filename>.var - variable file"
	echo "            <filename>.tpt - template file"
else
	if [ ! -f ${ARG_f}.tpt ] || [ ! -f ${ARG_f}.var ]; then
		echo "Template or variable file not found ($1)"
		exit
	fi
	
	regexsub="$(awk 'BEGIN { 
		first = 0
	} 
	/^[^#\s\\]+/ { 
		if (first == 0) { 
			printf("s|<<%s>>|%s|g",gensub(/(\|)/,"\\\\\\1","g",$1),gensub(/(\|)/,"\\\\\\1","g",gensub(/^[^ \t]+[ \t]+/,"","g",$0)));
			first = 1; 
		} else { 
			printf(";s|<<%s>>|%s|g",gensub(/(\|)/,"\\\\\\1","g",$1),gensub(/(\|)/,"\\\\\\1","g",gensub(/^[^ \t]+[ \t]+/,"","g",$0))) 
		} 
	}' ${ARG_f}.var)"
	if [ "$ARG_o" == "file" ]; then
		sed "$regexsub" ${ARG_f}.tpt > $ARG_f
	elif [ "$ARG_o" == "stdout" ]; then
		sed "$regexsub" ${ARG_f}.tpt
	else
		echo "Invalid File output option ($ARG_o)"
	fi
fi
