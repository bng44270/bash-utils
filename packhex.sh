#!/bin/bash

##################################
#
# packhex.sh - convert the ASCII representation a hexidecimal value to binary data
#
# The functionality of this script is base on the PHP pack function (php.net/manual/en/function.pack.php)
#
# To validate data once packed, do the following:
#
#        ./packhex.sh abcd | hexdump -C
#
# After this command you should get the following output:
#
#        00000000  ab cd                                             |..|
#
##################################

if [ ${#1} -eq 0 ]; then
  echo "packhex.sh <hex string>"
  echo " pack a hexadecimal string representation into a binary string"
else
  strlen=`printf "$1" | wc -c`
  hexstring=""
  evenword=`echo "$strlen % 4" | bc | grep '0'`
  if [ ${#evenword} -eq 0 ]; then
    upperwordlen=`echo "$strlen % 4" | bc`
    padlen=`echo "4-$upperwordlen" | bc`
    wordpad=`printf "%0${padlen}d"`
    hexstring="$wordpad$1"
    strlen=`printf "$hexstring" | wc -c`
  else
    hexstring="$1"
  fi

  idx="0"

  while true; do
    if [ $idx -lt $strlen ]; then
      hexword=`printf "${hexstring:$idx:4}"`
      printf \\x"${hexword:0:2}"
      printf \\x"${hexword:2:2}"
      idx=`echo $idx+4 | bc`
    else
      break
    fi
  done
fi