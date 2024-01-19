#!/bin/bash

##########################
#
# Console Music Keyboard (Key of C)
#
# Able to play two-note chords (with three the notes are played out of sync)
#
# Key mapping
#
#	Octave	Note	Key
#	4	C	q  \
#	4	D	w   \
#	4	E	e    \
#	4	F	r     \
#	4	G	t      \
#	4	A	y       \
#	4	B	u        \  Top keyboard row    \
#	5	C	Q        /                       \
#	5	D	W       /                         \
#	5	E	E      /                           \
#	5	F	R     /                             \
#	5	G	T    /                               \
#	5	A	Y   /                                 \
#	5	B	U  /                                   \
#	6	C	a  \                                    \
#	6	D	s   \                                    \
#	6	E	d    \                                    \
#	6	F	f     \                                    \
#	6	G	g      \                                    \
#	6	A	h       \                                    \
#	6	B	j        \  Middle keyboard row ------------- \ Shift key for higher octave
#	7	C	A        /                                    /
#	7	D	S       /                                    /
#	7	E	D      /                                    /
#	7	F	F     /                                    /
#	7	G	G    /                                    /
#	7	A	H   /                                    /
#	7	B	J  /                                    /
#	8	C	z  \                                   /
#	8	D	x   \                                 /
#	8	E	c    \                               /
#	8	F	v     \                             /
#	8	G	b      \                           /
#	8	A	n       \                         /
#	8	B	m        \  Bottom keyboard row  /  
#	9	C	Z        /
#	9	D	X       /
#	9	E	C      /
#	9	F	V     /
#	9	G	B    /
#	9	A	N   /
#	9	B	M  /
#
##########################

playnote() {
	NOTE="$1"
	OCT="$[ $2 - 1 ]"
	
	LOWC="16.35"
	declare -A NOTEMOD
	NOTEMOD=(["C"]="0" ["CS"]="0.97" ["DF"]="0.97" ["D"]="2" ["DS"]="3.1" ["EF"]="3.1" ["E"]="4.25" ["F"]="5.48" ["FS"]="6.77" ["GF"]="6.77" ["G"]="8.15" ["GS"]="9.61" ["AF"]="9.61" ["A"]="11.15" ["AS"]="12.79" ["BF"]="12.79" ["B"]="14.52")
	PLAYNOTE="$(bc <<< "scale=2;($LOWC+${NOTEMOD[$NOTE]})*(2^$OCT)")"
	ffplay -autoexit -loglevel quiet -nodisp -f lavfi -i "sine=f=$PLAYNOTE:d=0.15"
}


declare -A NOTEMAP
NOTEMAP=(["q"]="C  4"  ["w"]="D  4"  ["e"]="E  4"  ["r"]="F  4"  ["t"]="G  4"  ["y"]="A  4"  ["u"]="B  4"  ["Q"]="C  5"  ["W"]="D  5"  ["E"]="E  5"  ["R"]="F  5"  ["T"]="G  5"  ["Y"]="A  5"  ["U"]="B  5"  ["a"]="C  6"  ["s"]="D  6"  ["d"]="E  6"  ["f"]="F  6"  ["g"]="G  6"  ["h"]="A  6"  ["j"]="B  6"  ["A"]="C  7"  ["S"]="D  7"  ["D"]="E  7"  ["F"]="F  7"  ["G"]="G  7"  ["H"]="A  7"  ["J"]="B  7" ["z"]="C  8"  ["x"]="D  8"  ["c"]="E  8"  ["v"]="F  8"  ["b"]="G  8"  ["n"]="A  8"  ["m"]="B  8" ["Z"]="C  9"  ["X"]="D  9"  ["C"]="E  9"  ["V"]="F  9"  ["B"]="G  9"  ["N"]="A  9"  ["M"]="B  9")

while read -s -n1 k; do
	awk '{ printf("%s(%s)",$1,$2); }' <<< "${NOTEMAP[$k]}"
	playnote ${NOTEMAP[$k]} &
done
