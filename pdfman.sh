#!/bin/bash

#######################################
#
# pdfman.sh
#       Creates printable PDF of man page
#
# Usage:
#      pdfman.sh git
#              Creates git.pdf with the contents of the git man page
#
#      pdfman.sh -s git
#               Creates PDF of git man page and every mentioned man page with the git man page
#
# Requires text2pdf (from pdflib or pdflib-lite)
#
#######################################

if [ -z "$(which text2pdf)" ]; then
        echo "Requires text2pdf (install pdflib to satisfy dependancy)"
        exit 1
fi

if [ -z "$1" ]; then
        echo "pdfman.sh [-s] <command>"
else
        if [ -z "$2" ]; then
                manval="$(man $1)"
                if [ $? -eq 0 ]; then
                        printf "Making $1.pdf..."
                        text2pdf -o $(echo $1 | sed 's/[ \t]//g').pdf <(echo "$manval" | fold -w 80 -s | pr )
                        printf "done\n"
                fi
        else
                if [ "$1" == "-s" ]; then
                        manval="$(man $2)"
                        if [ $? -eq 0 ]; then
                                printf "Making $2.pdf..."
                                text2pdf -o $(echo $2 | sed 's/[ \t]//g').pdf <(echo "$manval" | pr)
                                printf "done\n"
                                echo "$manval" | sed 's/[ \t]/\n/g' | grep '[a-z-]*([0-9]\+)' | sed 's/).*$/)/g' | grep -iv "$2([0-9]\+)" | sed 's/([0-9]\+)//g' | sort | uniq | while read line; do
                                        newmanval="$(man $line)"
                                        if [ $? -eq 0 ]; then
                                                printf "Making $line.pdf..."
                                                text2pdf -o $(echo $line | sed 's/[ \t]//g').pdf <(echo "$newmanval" | fold -w 80 -s | pr)
                                                printf "done\n"
                                        fi
                                done
                        fi
                else
                        echo "Invalid Argument"
                fi
        fi
fi
