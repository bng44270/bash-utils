#!/bin/bash

###########################################
#
# Use ffplay to play musical notes
#
# Usage:
#
#    # Play Middle C
#    playnote.sh -N C -o 5
#
#    # Play Crazy Train Intro
#    playnote.sh -N FS -o 5 
#    playnote.sh -N FS -o 5 
#    playnote.sh -N CS -o 6 
#    playnote.sh -N FS -o 5 
#    playnote.sh -N D -o 6 
#    playnote.sh -N FS -o 5 
#    playnote.sh -N CS -o 6 
#    playnote.sh -N FS -o 5 
#    playnote.sh -N B -o 5
#    playnote.sh -N A -o 5
#    playnote.sh -N GS -o 5
#    playnote.sh -N A -o 5
#    playnote.sh -N B -o 5
#    playnote.sh -N A -o 5
#    playnote.sh -N GS -o 5 
#    playnote.sh -N E -o 5
#
###########################################

playnote() {
  NOTE="$1"
	OCT="$[ $2 - 1 ]"
	
	LOWC="16.35"
	declare -A NOTEMOD
	NOTEMOD=(["C"]="0" ["CS"]="0.97" ["DF"]="0.97" ["D"]="2" ["DS"]="3.1" ["EF"]="3.1" ["E"]="4.25" ["F"]="5.48" ["FS"]="6.77" ["GF"]="6.77" ["G"]="8.15" ["GS"]="9.61" ["AF"]="9.61" ["A"]="11.15" ["AS"]="12.79" ["BF"]="12.79" ["B"]="14.52")
	PLAYNOTE="$(bc <<< "scale=2;($LOWC+${NOTEMOD[$NOTE]})*(2^$OCT)")"
	ffplay -autoexit -nodisp -f lavfi -i "sine=f=$PLAYNOTE:d=0.3"
}

getargs() {
	echo "$@" | sed 's/[ \t]*\(-[a-zA-Z][ \t]\+\)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }' | sed 's/""/"EMPTY"/g'
}

eval $(getargs "$@")
echo "$@"

if [ -z "$ARG_N" ] || [ -z "$ARG_o" ]; then
	echo "usage: playnote.sh -N <NOTE> -o <OCTAVE>"
	echo "   Notes - C, CS, DF, D, DS, EF, E, F, FS, GF, G, GS, AF, A, AS, BF, B"
	echo "   Middle C is Octave 5"
else
	playnote $ARG_N $ARG_o
fi
