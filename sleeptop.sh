#!/bin/bash

#######################
# sleeptop.sh
#
# Sleep to the top of the hour:
#    sleeptop.sh -h
#
# Sleep to top of the minute
#    sleeptop.sh -m
#######################

case "$1" in 
  "-h")
    sleep $[3600-($(date +%M)*60+$(date +%S))]
    ;;
  "-m")
    sleep $[60-$(date +%S)]
    ;;
  *)
    echo "sleeptop <-h | -m>"
    ;; 
esac