#!/bin/bash

#####################
# bacon.sh
#
# Client to get paragraphs of garbage content from baconipsum.com
#
# usage:
#    bacon.sh <paragraph-count>
#####################

[[ -z "$1" ]] && PARAS="1" || PARAS="$1"
curl -s 'https://baconipsum.com/?paras='"$PARAS"'&type=all-meat' | grep 'div class="anyipsum-output"' | sed 's/<\/div>.*$//g;s/<\/p>/\n/g;s/^[ \t]*//g;s/<[\/]*[A-Za-z0-9 "-=]*[\/]*>//g' | grep -v '^[ \t]*$'