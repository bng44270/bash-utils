#!/bin/bash

################################################
#
# hpink.sh
#
# Display available capacity and model of ink cartridge
#
# Tested with HP OfficeJet 3830
#
# Usage:
#
#   hpink.sh -h <hostname/ip> -c <cartridge>
#
#   <cartridge> on the 3830 is CMY or K
#
################################################

getargs() {
	echo "$@" | sed 's/[ \t]*\(-[a-zA-Z][ \t]\+\)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }' | sed 's/""/"EMPTY"/g'
}

eval $(getargs "$@")

if [ -z "$ARG_h" ] && [ -z "$ARG_c" ]; then
	echo "usage: hpink -h <hostname> -c <cartridge>"
else
	curl -sN http://$ARG_h/DevMgmt/ConsumableConfigDyn.xml | \
	xmllint --xpath "//*[local-name()='ConsumableInfo'][*[local-name()='ConsumableLabelCode']='"$ARG_c"']/*[local-name()='ConsumablePercentageLevelRemaining' or local-name()='ConsumableSelectibilityNumber']/text()" ConsumableConfigDyn.xml | tr '\n' '|' | \
	awk 'BEGIN { FS="|" } { printf("%-10s: %d%%\n%-10s: %s\n","Percent",$1,"Model",$2); }'
fi