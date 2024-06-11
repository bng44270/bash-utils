#!/bin/bash

# Tested on Debian 12

#################################
# Download and setup newest version of Apache Sling including:
#
#    - Feature Model Launcher (JAR)
#    - Starter Feature Archive (TAR)
#
# Usage:
#
#    1. Run this script
#         - Use optional -p <PATH> to specify installation path (default is /opt)
#    2. Run start_sling
#
#################################

getargs() {
        echo "$@" | sed 's/[ \t]*\(-[a-zA-Z][ \t]\+\)/\n\1/g' | gawk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }' | sed 's/""/"EMPTY"/g'
}

NEWJDK="$(apt-cache search openjdk | awk '/openjdk-[0-9]+-jdk[ \t]+/ { print $1 }')"

apt-get install -y $NEWJDK unzip gawk curl

eval "$(getargs "$@")"

INSTALLPATH="/opt"

[[ -n "$ARG_p" ]] && INSTALLPATH="$ARG_p"

echo -n "Downloading sling..."
curl -s 'https://sling.apache.org/downloads.cgi' | sed 's/>/>\n/g;s/</\n>/g' |\
gawk '/oak_tar_far.far"/ { 
	print gensub(/^.*href="([^"]+)".*$/,"\\1","g",$0); 
}
/sling\.feature\.launcher.*zip"/ {
	print gensub(/^.*href="([^"]+)".*$/,"\\1","g",$0); 
}' | while read file; do
	FILENAME="$(basename $file)"
	curl -s $file > $INSTALLPATH/$FILENAME
done
echo "done"

echo -n "Setting up sling..."
pushd . > /dev/null
cd $INSTALLPATH
unzip -qq *sling.feature.launcher*zip
rm *zip
ln -s $(ls *sling.feature.launcher* -d) sling
mv *oak_tar_far.far sling
OAKTAR="$(ls $INSTALLPATH/sling/*oak_tar_far.far)"
cat <<HERE > /usr/bin/start_sling
#!/bin/bash

/opt/sling/bin/launcher -f $OAKTAR
HERE
chmod +x /usr/bin/start_sling
popd > /dev/null
echo "done"
