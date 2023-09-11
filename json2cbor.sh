#!/bin/bash

##############################################################
#
# Encode JSON data provided via stdin as CBOR (uses cbor.me)
#
# Usage:
#
#   <json-text-data-output> | json2cbor.sh
#
#   json2cbor.sh <<< "<json-text-data>"
#
##############################################################


urlencode() {
  xxd -ps | sed 's/\(..\)/%\1/g'
}

getbytes() {
  sed 's/>/>\n/g' | awk '
  	BEGIN { reading = 0; }
  	/<textarea[ \t]+id="bytes"/ { reading = 1; getline; }
  	/<\/textarea>/ { reading = 0; }
  	{ 
  	  if (reading == 1) { 
  	    byteline = gensub(/^([^#]+)#.*$/,"\\1","g",$0);
  	    printf("%s", byteline);
  	  }
  	}' | sed 's/[ \t]*//g'
  	echo ""
}

DATA="$(cat -)"
RESP="$(curl -s https://cbor.me/?diag=$(urlencode <<< "$DATA"))"

ERROR="$(grep '<p class="warning">' <<< "$RESP")"

if [ -n "$ERROR" ]; then
  echo "Invalid data"
  exit 1
fi

getbytes <<< "$RESP"
exit 0