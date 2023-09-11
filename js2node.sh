###############################
# js2node.sh
#
# Convert a javascript library containing "function" and "class"
# definitions into a Node library
#
# Usage:
#   js2node.sh -f <js-source-file>
###############################

#!/bin/bash

getargs() {
        sed 's/[ \t]*\(-[a-zA-Z][ \t]\+\)/\n\1/g' <<< "$@" | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }' | sed 's/""/"EMPTY"/g'
}

EXPORTTEMPLATE='NAME:NAME,'

eval $(getargs "$@")

if [ -z "$ARG_f" ]; then
  echo "usage: js2node.sh -f <js-file>"
else
  if [ -f $ARG_f ]; then
    FILENAME="node-$ARG_f"
    cat $ARG_f > $FILENAME.tmp
    echo -ne "\n\n" >> $FILENAME.tmp
    echo -ne "module.exports = {" >> $FILENAME.tmp
    grep "^[ \t]*function\|^[ \t]*class" $ARG_f | while read line; do
      INAME="$(sed 's/^[^ \t]\+[ \t]\+\([^\( \t]\+\).*$/\1/g' <<< "$line")"
      echo -ne "\n$(sed 's/NAME/'"$INAME"'/g' <<< "$EXPORTTEMPLATE")" >> $FILENAME.tmp
    done
    LASTLINE="$(tail -n1 $FILENAME.tmp | sed 's/,$//g')"
    head -n$(wc -l $FILENAME.tmp | cut -d' ' -f1) $FILENAME.tmp > $FILENAME
    echo -ne "$LASTLINE" >> $FILENAME    
    echo -ne "\n};" >> $FILENAME
    rm $FILENAME.tmp
    echo "Created $FILENAME"
  else
    echo "$ARG_f not found"
  fi
fi