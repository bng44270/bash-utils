#!/bin/bash

##############################
# webfiler.sh
#
# Creates index.html files for each child
# directory underneath the specified directory
# that lists all files/subdirectories
#
# Usage:
#    webfiler.sh <folder-structure>
#
##############################

if [ -z "$1" ]; then
        echo "usage: webfiler.sh <folder-path>"
else
        find -type d | while read line; do
                thisdir="$(echo "$line" | sed 's/^\.[\/]*//g')"
                if [ -z "$thisdir" ]; then
                        thisdir="$(pwd | sed 's/^.*\///g')"
                        PARENT="."
                else
                        thisdir="$(basename $thisdir)"
                        PARENT=".."
                fi
                cat << HERE > $line/index.html
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html>
<head>
<title>Contents of $thisdir</title>
</head>
<body>
<h2>Contents of $thisdir</h2>
<a href="$PARENT">Parent Directory</a><br/><br/>
<table style="border-width:0px;">
HERE
                ls $line/ | while read entry; do
                        [[ "$entry" == "index.html" ]] && continue

                        if [ -f $line/$entry ]; then
                                ETYPE="F"
                                LINKTGT=""
                        fi

                        if [ -d $line/$entry ]; then
                                ETYPE="D"
                                LINKTGT=""
                        fi

                        if [ -h $line/$entry ]; then
                                ETYPE="L"
                                LINKTGT="<a href=\"$(dirname $(ls -alF $line/$entry | sed 's/^.*-> //g'))\">orig</a>"
                        fi

                        cat << HERE >> $line/index.html
<tr>
  <td>[$ETYPE]</td>
  <td style="width:10px;"></td>
  <td><a href="$entry">$entry</a></td>
  <td style="width:20px;"></td>
  <td>$(stat $line/$entry | grep '^[ \t]*Size' | awk '{ print $2 }' | rev | sed 's/\([0-9][0-9][0-9]\)/\1,/g' | rev | sed 's/^,//g') bytes</td>
  <td style="width:10px;"></td>
  <td>$(date -u -d "$(stat $line/$entry | grep '^[ \t]*Modify:' | sed 's/^[ \t]*Modify:[ \t]*//g')" +"%Y-%m-%d %H:%M:%S") $LINKTGT</td>
</tr>
HERE
                done
                cat << HERE >> $line/index.html
</table>
<br/><span style="font-style:italic;">Created by webfiler.sh</span><br/>
</body>
</html>
HERE
        done
fi