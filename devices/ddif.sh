#!/bin/bash

################################################
#
# ddif.sh
#   Get interface counters from DD-WRT-based router
#
#   Usage:
#   
#     List Interfaces
#     
#       ddif.sh -o list -h 192.168.1.1
#
#     Get Specific Interface Counter
#
#       ddif.sh -o get -h 192.168.1.1 -i eth0
#
#     Get All Interface Counters
#
#       ddif.sh -o get -h 192.168.1.1
#
################################################

iflist() {
	curl -u "$(read -p "Username: " usrnm; echo -n $usrnm)" -s http://$1/Status_Bandwidth.asp | awk '/graph_if\.svg/ { print gensub(/^.*graph_if\.svg\?([^"]+)".*$/,"\\1","g",$0); }'
}


ifcounters() {
	curl -u "$(read -p "Username: " usernm; echo -n $usernm)" -s http://$1/fetchif.cgi?$2 | awk '{ getline printf("%-4s%s\n%-4s%s\n","IN",gensub(/^.*:(.*)$/,"\\1","g",$1),"OUT",$9); }'
}

getargs() {
	[[ -z "$1" ]] && echo "usage: getargs <arguments>" || echo "$@" | sed 's/[ \t]*\(-[a-zA-Z][ \t]\+\)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }' | sed 's/""/"EMPTY"/g'
}

usage() {
	"usage:  ddif.sh -o <list | get> -h <hostname> [-i <interface>]"
}

[[ -n "$@" ]] && eval $(getargs $@)

if [ -n "$ARG_o" ]; then
	if [ "$ARG_o" == "list" ] && [ -n "$ARG_h" ]; then 
		iflist $ARG_h
	elif [ "$ARG_o" == "get" ] && [ -n "$ARG_h" ]; then
		if [ -n "$ARG_i" ]; then
			ifcounters $ARG_h $ARG_i
		else
			iflist $ARG_h | while read IFACE; do
				IFCOUNT="$(ifcounters $ARG_h $IFACE)"
				echo "$IFACE $IFCOUNT"
			done
		fi
	else
		echo "Invalid operation or parameter not provided"
		usage
	fi
else
	echo "Operation not provided"
	usage
fi