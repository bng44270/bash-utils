#!/bin/bash

#####################################
# pretext.sh
# 
# This will be used as a cgit about-filter
# It will format the text in a README file
# for clean display on the screen.
#
# Usage:
#   Add the following line to /etc/cgitrc
#
#   about-filter=/path/to/pretext.sh
#####################################

echo "<pre style=\"width:100%;white-space: pre-wrap; white-space: -moz-pre-wrap; white-space: -pre-wrap; white-space: -o-pre-wrap; word-wrap: break-word;\">"
cat - | sed "s|<|&lt;|g;s|>|&gt;|g"
echo "</pre>"
