#!/bin/bash

##########################
#
# deblxc-custom.sh
#
# Create Debian-based LXC containers with specific
# packages installed by default
#
# Example:
#
#    Create a template that will include Python, PIP, and Flask
#
#    sudo deblxc-custom.sh python3 python3-pip python3-flask > /usr/share/lxc/tempaltes/lxc-debian-python3
#
# Tested on Debian 12
#
##########################


PACKAGES_LIST="$(sed 's/[ \t]\+/,/g' <<< "$@")"

head -n $[ $(grep -n '^post_process[^(]' /usr/share/lxc/templates/lxc-debian | cut -d':' -f1) - 1 ] /usr/share/lxc/templates/lxc-debian
tail -n $[ $(wc -l /usr/share/lxc/templates/lxc-debian | cut -d' ' -f1) - $(grep -n '^post_process[^(]' /usr/share/lxc/templates/lxc-debian | cut -d':' -f1) + 1 ] /usr/share/lxc/templates/lxc-debian | sed 's/\(\${packages}\)/\1,'"$PACKAGES_LIST"'/g'
