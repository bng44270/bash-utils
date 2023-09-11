#!/bin/bash

##############################################
#
# ifttthook.sh
#
# Make calls to a IFTTT webhook
#
# Usage:
#
#    ifttthook.sh hook-name "first value" "second value" "third value"
#
#    In this example, the value1 parameter has the value of "first value", 
#    value2 has "second value", and value3 has "third value".
#
#    Depending on the needs of your webhook value2 and value3 may be omitted
#
#
# NOTE:  Modify the value of IFTTTKEY below to contain your IFTTT webhook key
#
##############################################

IFTTTKEY="ABC123"

if [ -z "$1" ] && [ -z "$2" ]; then
  echo "usage: ifttthook.sh <hook-name> "<value1>" [ "<value2>"  [ "<value3>" ]]"
elif [ -n "$5" ]; then
  echo "Too many arguments provided (limit 3)"
else
  (
  printf "{ "
  printf "\"value1\":\"$2\""
  if [ -n "$3" ]; then
    printf ", \"value2\":\"$3\""
  fi
  if [ -n "$4" ]; then
    printf ", \"value3\":\"$4\""
  fi
  printf " }"
  ) | curl -X POST -d ''"$(cat -)"'' -H "Content-type: application/json" https://maker.ifttt.com/trigger/{$1}/with/key/$IFTTTKEY
fi