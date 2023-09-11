#!/bin/bash

#############################
#
# randompass.sh
#
# Generate a random password of a specified length
#
# usage:  randompass.sh <length>
#
#############################

increment() {
        echo $[ $1 + 1 ]
}

if [ -z "$1" ]; then
  echo "usage: randompass <password-length>"
  echo "       generate random password"
else
  chars="abcdefgjkmnpqrstwxyz-%@#ABCDEFGHJKMNPQRSTWXYZ-%@#0123456789-%@#"
  randpass=""
  counter="0"
  maxchar="$1"
  while [ "$counter" != "$[ $maxchar + 1 ]" ]; do
    firstrand="${RANDOM:1:1}"
    secondrand="${RANDOM:3:1}"
    
    if [ "$firstrand" -eq "0" ] && [ "$secondrand" -gt "0" ]; then 
      randomnumber="$secondrand"
      if [ "$randomnumber" -ge "0" ] && [ "$randomnumber" -le "63" ]; then
        export randpass=`printf "$randpass${chars:$randomnumber:1}"`
        counter=`increment $counter`
      fi 2> /dev/null
    fi 2> /dev/null
    
    if [ "$firstrand" -gt "0" ] && [ "$secondrand" -eq "0" ]; then 2> /dev/null
      randomnumber="$firstrand"
      if [ "$randomnumber" -ge "0" ] && [ "$randomnumber" -le "63" ]; then
        export randpass=`printf "$randpass${chars:$randomnumber:1}"`
        counter=`increment $counter`
      fi 2> /dev/null
    fi 2> /dev/null
          
    if [ "$firstrand" -gt "0" ] && [ "$secondrand" -gt "0" ]; then
      randomnumber="$firstrand$secondrand"
      if [ "$randomnumber" -ge "0" ] && [ "$randomnumber" -le "63" ]; then
        export randpass=`printf "$randpass${chars:$randomnumber:1}"`
        export counter=`increment $counter`
      fi 2> /dev/null
    fi 2> /dev/null
  done
        
  printf "${randpass:0:$maxchar}"
fi