#!/bin/bash

#####################
# 1. curl -k https://geolite.maxmind.com/download/geoip/database/GeoLite2-City-CSV.zip > geo-city.zip
# 2. Extract GeoLite2-City-Blocks-IPv4.csv
# 3. cat GeoLite2-City-Blocks-IPv4.csv | tail -n +2 > ipv4.csv
# 4. sqlite3 ip.db 'CREATE TABLE ipv4(network text,geoname_id text,registered_country_geoname_id text,represented_country_geoname_id text,is_anonymous_proxy text,is_satellite_provider text,postal_code text,latitude text,longitude text,accuracy_radius text);'
# 5. sqlite3 ip.db <<HERE
#    .mode csv
#    .import ipv4.csv ipv4
#    HERE
# 6. Change value of DBFILE below to reflect ip.db file location
#####################





DBFILE="/path/to/ip.db"

getargs() {
        echo "$@" | sed 's/\(-[a-zA-Z]\)/\n\1/g' | awk 'BEGIN { FS=" " } /^-/ { printf("ARG_%s=\"%s\"\n",gensub(/\n/,"","g",gensub(/^-/,"","g",$1)),length($2)==0?"EMPTY":gensub(/\n/,"","g",$2)) }'
}

getsubnets() {
	echo $1 | sed 's/[0-9]\+$/0/g'
	echo $1 | sed 's/[0-9]\+\.[0-9]\+$/0.0/g'
	echo $1 | sed 's/[0-9]\+\.[0-9]\+\.[0-9]\+$/0.0.0/g'
}

if [ -z "$1" ]; then
	echo "usage: geoip.sh <-d | -i <address> >"
else
	eval $(getargs "$@")
	if [ -n "$ARG_d" ]; then
		curl -k https://geolite.maxmind.com/download/geoip/database/GeoLite2-City-CSV.zip > geo-city.zip
		cat GeoLite2-City-Blocks-IPv4.csv | tail -n +2 > ipv4.csv
		awk 'BEGIN { FS=","; first = 1 ; printf("INSERT INTO ipv4 VALUES "); } { if (first == 1) { printf("(\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\")",$1,$2,$3,$4,$5,$6,$7,$8,$9,$10); first = 0; } else { printf(",(\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\")",$1,$2,$3,$4,$5,$6,$7,$8,$9,$10); } } END { printf(";"); }' < <(sed 's/"//g' ipv4.csv)
	getsubnets $1 | while read line; do
		result=`sqlite3 $DBFILE 'select network,latitude,longitude from ipv4 where network like "'"$line"'%";' | \
			awk 'BEGIN { FS="|" }
				{
					if ($2 && $3)
						printf("%s => https://www.openstreetmap.org/search?query=%s%%2C%s#map=5/%s/%s\n",$1,$2,$3,$2,$3);
				}'
		`
		if [ -n "$result" ]; then
			echo "$result"
			break
		fi
	done
fi
