#!/bin/bash

getdeps() {
        # $1=>ver, $2=>arch, $3=>pkg, $4=>tempdir
        if [ ! -f $4/$3.dep ] && [ -n "$(curl -s http://distro.ibiblio.org/tinycorelinux/$1.x/$2/tcz/$3.dep -I | grep '200 OK')" ]; then
                echo -n "Downloading $4/$3.dep..."
                curl -s http://distro.ibiblio.org/tinycorelinux/$1.x/$2/tcz/$3.dep > $4/$3.dep
                echo "done"
                cat $4/$3.dep | while read line; do
                        getdeps "$1" "$2" "$line" "$4"
                done
        fi
}

if [ -z "$1" ]; then
        echo "usage: getcz.sh <arch> <package>"
else
        [[ -z "$(grep "tcz$" <<< "$2")" ]] && PKG="$2.tcz" || PKG="$2"
        TMPDIR="/tmp/tce.$RANDOM"

        [[ ! -d $TMPDIR ]] && mkdir -p $TMPDIR

        TCVER="$(curl -s http://distro.ibiblio.org/tinycorelinux/ | awk -v arch="$1" '/latest version:/ { version = gensub(/^.*<b>/,"","g",gensub(/<\/b>.*$/,"","g",$0)) } END { printf("%s",gensub(/\..*$/,"","g",version))}')"
        getdeps "$TCVER" "$1" "$PKG" "$TMPDIR"

        echo  "Downloading $TMPDIR/$PKG:"
        curl -# http://distro.ibiblio.org/tinycorelinux/$TCVER.x/$1/tcz/$PKG > $TMPDIR/$PKG

        cat $TMPDIR/*dep | sort | uniq | egrep -v "^[ \t]*$" | while read line; do
                echo "Downloading $TMPDIR/$line:"
                curl -# http://distro.ibiblio.org/tinycorelinux/$TCVER.x/$1/tcz/$line > $TMPDIR/$line
        done
fi