#!/bin/bash

#################################################
# mftones.sh - Generate Blue Box and DTMF tones
#
# Usage:
#    Generate the DTMF tones for 513
#        mftones.sh -d dtmf -t 5
#        mftones.sh -d dtmf -t 1
#        mftones.sh -d dtmf -t 3
#
#    Generate Blue Box tones for 630
#        mftones.sh -d bb -t 6
#        mftones.sh -d bb -t 3
#        mftones.sh -d bb -t 0
#
#    Generate custom tones 
#        mftones.sh -f 2600,2400
#
# If you have issues with tones not playing correctly or simultaneously,
# you can increase the value of DURATION variable below.
#
#################################################

DURATION="0.5"

mftones() {
	TONEPIDS=""
	for TONE in "$@"; do
		ffplay -autoexit -nodisp -f lavfi -i "sine=f=$TONE:d=$DURATION" &
		TONEPIDS="$TONEPIDS $!"
	done
	sleep $DURATION
	kill -9 $TONEPIDS
}

getargs() {
	echo "$@" | sed 's/[ \t]*\(-[a-zA-Z][ \t]\+\)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }' | sed 's/""/"EMPTY"/g'
}

declare -A TONES
TONES=(["bb1"]="700 900" ["bb2"]="700 1100" ["bb3"]="900 1100" ["bb4"]="700 1300" ["bb5"]="900 1300" ["bb6"]="1100 1300" ["bb7"]="700 1500" ["bb8"]="900 1500" ["bb9"]="1100 1500" ["bb0-10"]="1300 1500" ["bb11-ST3"]="700 900 1700" ["bb12-ST2"]="1100 1700" ["bbKP"]="1700" ["bbKB-ST2"]="1300 1700" ["bbST"]="1500 1700" ["dtmf1"]="697 1209" ["dtmf2"]="697 1336" ["dtmf3"]="697 1477" ["dtmf4"]="770 1209" ["dtmf5"]="770 1336" ["dtmf6"]="770 1477" ["dtmf7"]="852 1209" ["dtmf8"]="852 1336" ["dtmf9"]="852 1477" ["dtmf0"]="941 1336" ["dtmfST"]="941 1209" ["dtmfPO"]="941 1477" ["dtmfA"]="697 1633" ["dtmfB"]="770 1633" ["dtmfC"]="852 1633" ["dtmfD"]="941 1633")

eval $(getargs "$@")

if [ -z "$ARG_d" ] || [ -z "$ARG_t" ]; then
	if [ -z "$ARG_f" ]; then
		BBKEYS="$(tr ' ' '\n' <<< "${!TONES[@]}" | awk '{ printf("%s ",gensub(/^bb(.*)$/,"\\1","g",$0)); }')"
		DTMFKEYS="$(tr ' ' '\n' <<< "${!TONES[@]}" | awk '/^dtmf/ { printf("%s ",gensub(/^dtmf(.*)$/,"\\1","g",$0)); }')"
		echo "usage:"
		echo "    mftones.sh -d <device> -t <tone>"
		echo "    mftones.sh -f freq1,freq2,..."
		echo ""
		echo "    Devices: bb or dtmf"
		echo "    Tones:"
		echo "        Blue Box:  $BBKEYS"
		echo "        DTMF:      $DTMFKEYS"
	else
		TONEARGS="$(sed 's/,/ /g' <<< "$ARG_f")"
		grep '^[0-9 \t]\+$' <<< "$TONEARGS" > /dev/null
		if [ $? -eq 0 ]; then
			mftones $TONEARGS
		else
			echo "Invalid frequency list ($ARG_f)"
		fi
	fi
else
	USETONE="${ARG_d}${ARG_t}"
	if [ -n "${TONES[$USETONE]}" ]; then
		mftones ${TONES[$USETONE]}
	else
		echo "Invalid device/tone ($USETONE)"
	fi
fi
