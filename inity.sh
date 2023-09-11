#!/bin/bash

##############################################
# inity.sh
#
# Extract initrd.gz
#     inity.sh -e /path/of/initrd.gz
#     Creates /path/of/initrd-root directory containing content of initrd
#
# Recreate initrd.gz
#     inity.sh -s /path/of/initrd.gz
#     Takes contents of /path/of/initrd-root and puts it in /path/of/initrd.gz
##############################################

usage() {
	echo "usage: inity <-e | -s> <path/to/inird>"
}

if [ -z "$1" ]; then
	usage
else
	INITRDPATH="$2"
	INITRDFILE="$(basename $INITRDPATH)"
	UNCOMPINITRD="$(echo $INITRDFILE | sed 's/\..*$//g')"
	INITRDDIR="$(dirname $INITRDPATH)/$UNCOMPINITRD-root"

	pushd . 2>&1 > /dev/null
	mkdir $INITRDDIR
	cd $INITRDDIR

	case "$1" in
		"-e")
      			gzip -cd ../$INITRDFILE | cpio -i 2>&1 > /dev/null
			echo "$INITRDPATH -> $INITRDDIR"
			;;
		"-s")
			find . | cpio -H newc -o > ../$UNCOMPINITRD 2>&1 > /dev/null
			gzip -f ../$UNCOMPINITRD
			echo "$INITRDDIR -> $INITRDPATH"
			;;
		*)
			usage
			;;
	esac
	
	popd 2>&1 > /dev/null
fi