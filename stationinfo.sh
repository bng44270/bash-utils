#!/bin/bash

getargs() {
	echo "$@" | sed 's/[ \t]*\(-[a-zA-Z][ \t]\+\)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }' | sed 's/""/"EMPTY"/g'
}

striphtml() {
	[[ "$1" == "-a" ]] && sed 's/<[\/]*[ \ta-zA-Z0-9#/=_+.";:-]\+[\/]*>//g' || sed 's/<[\/]*[a-zA-Z0-9]*[ ]*[\/]*>//g'
}

getvariants() {
	cat <<HERE
$@-TV
$@-DT
$@-AM
$@-FM
HERE
}

istvstation() {
	[[ -n "$(cat - | grep 'Transmitter coordinates' )" ]] && echo yes || echo no
}

getcoords() {
	 sed 's/>/>\n/g' | awk -v gc="$1" 'BEGIN { 
		lat="";
		lng="" 
	} 
	
	/class="latitude"/ { 
		getline;
		lat = $0
	}
	
	/class="longitude"/ { 
		getline;
		lng = $0
	}
	
	END {
		if (gc == "lat") {
			print lat;
		}
		if (gc == "lng") {
			print lng;
		}
	}' | striphtml
}

dms2deg() {
	xxd -ps | awk 'function hextostring (hex,str) {
		for (i = 1; i <= length(hex); i = i + 2) {
			str = str sprintf("%c",strtonum("0x" substr(hex,i,1) substr(hex,i+1,1)));
		}
		return str;
	}
	{
		od = hextostring(gensub(/^([a-f0-9]+)c2b0.*$/,"\\1","g",$0));
		om = hextostring(gensub(/^.*c2b0([a-f0-9]+)e280b2.*$/,"\\1","g",$0));
		os = hextostring(gensub(/^.*e280b2([a-f0-9]+)e280b3.*$/,"\\1","g",$0));
		dir = hextostring(gensub(/^.*e280b3([a-f0-9]{2}).*$/,"\\1","g",$0));
		
		modif = (dir == "S" || dir == "W") ? -1 : 1; 
		deg = ((os /3600) + (om / 60) + od) * modif; 
		printf("%3.10f",deg)
	}'
}

eval $(getargs "$@")

if [ -z "$ARG_c" ]; then
	echo "usage:  stationinfo.sh -c <callsign> [-m <FM|AM|TV|DT>]"
else
	if [ -z "$ARG_m" ]; then
		COORDS=`getvariants $ARG_c | while read line; do
			HTML="$(curl -s https://en.wikipedia.org/wiki/$line)"
			if [ "$(istvstation <<< "$HTML")" == "yes" ]; then
				echo "$line ($(getcoords lat <<< "$HTML" | dms2deg),$(getcoords lng <<< "$HTML" | dms2deg))"
			fi
		done`
	
		if [ -n "$COORDS" ]; then
			echo "$COORDS"
		else
			echo "Transmitter not found ($ARG_c)"
		fi
	else
		HTML="$(curl -s https://en.wikipedia.org/wiki/$ARG_c-$ARG_m)"
		if [ "$(istvstation <<< "$HTML")" == "yes" ]; then
			echo "$ARG_c - $(parsecoords <<< "$HTML")"
		else
			echo "Transmitter not found ($ARG_c)"
		fi
	fi
		
fi
