##################################################
#
# Read text-based config files
#
# File Format:
#
#    <Parameter Name><WHITESPACE><Parameter Value>
#
# File Sample (config.txt):
#
#    DATADIR          /path/to/data
#    SESSIONS         sessions.db
#
# Usage:
#
#    $ eval $(configfile config.txt)
#    $ echo $CONF_DATADIR
#    /path/to/data
#    $ echo $CONF_SESSIONS
#    sessions.db
#
##################################################

configfile() {
	if [ -f $1 ]; then
		while read line; do
			CONFIG_KEY="$(awk '{ print $1 }' <<< "$line")"
			CONFIG_VAL="$(awk '{ print gensub(/^'"$CONFIG_KEY"'[ \t]+(.*)$/,"\\1","g",$0) }' <<< "$line")"
			echo "CONF_${CONFIG_KEY}=\"${CONFIG_VAL}\""
		done < $1
		
	else
		echo "File Not Found ($1)"
	fi
}