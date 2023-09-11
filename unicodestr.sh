#!/bin/bash

if [ -z "$1" ]; then
  echo "unicodestr <ASCII string>"
  echo " return unicode (UTF16LE) encoded string for specified password"
else
  (
    printf "\""
    printf \\x"0"
    printf "$1" | while read -n 1 passchar; do
      printf "$passchar"
      printf \\x"0"
    done
		printf "\""
    printf \\x"0"
  ) | base64
fi