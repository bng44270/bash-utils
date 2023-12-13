#!/bin/bash

######################################
#
# vlcweb.sh - Start VLC with a browser interface
#
# Upon launching a dialog will appear showing the address
# to access the VLC web application along wtih a temporary
# random password.
#
######################################

randompass () {
        [[ -z "$1" ]] && echo "usage: randompass <password-length>" || echo "$(cat /dev/urandom | tr -dc 'a-z' | head -c$1) $(cat /dev/urandom | tr -dc 'A-Z' | head -c$1) $(cat /dev/urandom | tr -dc '0-9' | head -c$1) $(for dash in $(seq 0 $[$1/10]); do echo "-" ; done)" | sed 's/[ \t]//g' | fold -w1 | shuf | tr -d '\n' | head -c$1
}

PORTRANGE="$(seq 40000 41000)"
PASS="$(randompass 8)"
for PORT in $PORTRANGE; do
  nc -z 127.0.0.1 $PORT
	if [ $? -ne 0 ]; then
		vlc -I http --http-password="$PASS" --http-port=$PORT 2>&1 > /dev/null &
		VLCPID="$!"
		zenity --info --text="Port: http://127.0.0.1:$PORT\nPassword: $PASS\n" --width=300 --ok-label="Stop"
		kill -9 $VLCPID
		break
	fi
done
