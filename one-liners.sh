# Download one-liners.sh to the specified file
getol() {
	[[ ! -f $1 ]] && echo "usage:  getol <target-file>" || curl https://raw.githubusercontent.com/bng44270/bash-utils/main/one-liners.sh > $1
}

# Delete docker image and associated containers
rmimg() {
	[[ -z "$1" ]] && echo "usage: rmimg <docker-image-id>" || (docker ps -a | awk '/^.*[ \t]+'"$1"'/ { print $1 }' | xargs docker container rm && docker image rm $1)
}

# Take screenshot of a website and a PDF file
urlscreenshot() {
	[[ -z "$@" ]] && echo "usage: urlscreenshot <url>" || curl -X POST -d "delay=n&screenshot=$@" https://freetsa.org/screenshot.php > $(sed 's/^http[s]*:\/\///g' <<< "$@").pdf
}

# Format text with multiple terminal escape sequences (https://misc.flogisoft.com/bash/tip_colors_and_formatting)
style() {
	[[ -z "$1" ]] && echo "style <code> [<code>...]" || sed 's/^/\x1b['"$(sed 's/[ \t]\+/;/g' <<< "$*")"'m/g;s/$/\x1b[0m/g'
}

# Get Windows 10 Product key from firmware
getwinkey() {
	sudo strings /sys/firmware/acpi/tables/MSDM | grep '^[A-Z0-9]\{5\}-[A-Z0-9]\{5\}-[A-Z0-9]\{5\}-[A-Z0-9]\{5\}-[A-Z0-9]\{5\}$'
}

# Connection  transfer and rate test (requires iperf server)
conntest() { 
	[[ -z $1 && -z $2 ]] && echo "usage: conntest <ipaddr> <port>" || iperf -c $1 -p $2 | awk '/\[[ \t]*ID\]/ { getline; printf("%-7s%s\n%-7s%s\n","XFER",gensub(/^.*([0-9]\.[0-9]+[ \t]+[KMG]Bytes).*$/,"\\1","g",$0),"RATE",gensub(/^.*([0-9]\.[0-9]+[ \t]+[KMG]bits\/sec).*$/,"\\1","g",$0)); }'
}


# Search for NWS station ID by station name
getnws() {
	[[ -z "$1" ]] && echo "usage: getnws <station name search string>" || curl -Ls http://weather.gov/xml/current_obs/index.xml | grep -i -B2 "$@" | awk '/<station_id>/ { st_id = gensub(/^.*<station_id>([^<]+)<\/station_id>.*$/,"\\1","g",$0); getline; state = gensub(/^.*<state>([^<]+)<\/state>.*$/,"\\1","g",$0); getline; st_name = gensub(/^.*<station_name>([^<]+)<\/station_name>.*$/,"\\1","g",$0); printf("%s (%s, %s)\n",st_id, st_name, state); }'
}

# Extract first CDATA block from XML
getcdata() {
	perl -0777 -pe 's/^.*<!\[CDATA\[(.*)\]\]>.*$/\1/igs'
}

# Get NVIDIA GPU statistics (query values found at https://nvidia.custhelp.com/app/answers/detail/a_id/3751/~/useful-nvidia-smi-queries)
gpuinfo() {
	[[ -z "$1" || -z "$2" ]] && echo "usage: gpuinfo <gpu-index> <query>" || nvidia-smi --query-gpu=index,$2 --format=csv | awk 'BEGIN { FS="," } /^'"$1"'/ { print gensub(/^[ \t]*([0-9]+).*$/,"\\1","g",$2); }'
}

# Get count of processes matching search string
pcount() {
	[[ -z "$1" ]] && echo "usage: pcount <search-string>" || ps -ef | grep "$(awk 'BEGIN { RS=" " } { printf("[%s]%s.*",gensub(/^(.).*$/,"\\1","g",$0),gensub(/^.(.*)$/,"\\1","g",$0)); } END { printf("\b\b  \b\b"); }' <<< "$@")" | wc -l
}

# Query ServiceNow Table API
snquery() {
	[[ -z "$1" ]] && echo "usage: snquery <host> <table-name> [<query>]" || curl -ks "https://$1/api/now/table/$2$([[ -n "$3" ]] && echo "?sysparm_query=$3")" -H"Accept:application/json" -u "$(read -p "Username: " usern; echo $usern):$(read -s -p "Password: "  passwd; echo $passwd)"
}

# Update record with ServiceNow Table API
snupdate() {
	[[ -z "$1" ]] && echo "usage: snupdate <host> <table> <record-sys_id> <field> <value>" || curl -ks "https://$1/api/now/table/$2/$3" -X PUT -H"Accept: application/json" -H"Content-Type: application/json" -d"{\"$4\":\"$5\"}" -u "$(read -p "Username: " usern; echo $usern):$(read -s -p "Password: "  passwd; echo $passwd)"
}

# Download NVD Data as XML
nvdxml() {
	[[ -z "$1" ]] && echo -e "usage:  nvdxml <feed>\n     feed => <year>, Modified, or Recent" || curl -ks https://nvd.nist.gov/vuln/data-feeds | tr -d '\r' | tr -d '\n' | sed 's/\(<tr\)/\n\1/g;s/\(<\/tr>\)/\1\n/g;s/>[ \t]*</></g' | grep '^<tr.*vuln-xml-feed' | xmlpretty | awk '/^<a href=.*\/xml\/cve\/2.0\/.*'$1'.*gz/ { printf("%-15s%s\n","GZipFileUrl",gensub(/^<a href='"'"'(.*gz)'"'"'.*$/,"\\1","g",$0)) } /^<a href=.*\/xml\/cve\/2.0\/.*'$1'.*zip/ { printf("%-15s%s\n","ZipFileUrl",gensub(/^<a href='"'"'(.*zip)'"'"'.*$/,"\\1","g",$0)) } /^<a href=.*\/xml\/cve\/2.0\/.*'$1'.*meta/ {	printf("%-15s%s\n","MetadataUrl",gensub(/^<a href='"'"'(.*meta)'"'"'.*$/,"\\1","g",$0)) }'
}

# Download NVD Data as JSON
nvdjson() {
	[[ -z "$1" ]] && echo -e "usage:  nvdjson <feed>\n     feed => <year>, Modified, or Recent" || curl -sk https://nvd.nist.gov/vuln/data-feeds | tr -d '\r' | tr -d '\n' | sed 's/\(<tr\)/\n\1/g;s/\(<\/tr>\)/\1\n/g;s/>[ \t]*</></g' | grep '^<tr.*vuln-json-feed' | xmlpretty | awk '/^<a href=.*\/json\/cve\/.*'$1'.*gz/ { printf("%-15s%s\n","GZipFileUrl",gensub(/^<a href='"'"'(.*gz)'"'"'.*$/,"\\1","g",$0)) } /^<a href=.*\/json\/cve\/.*'$1'.*zip/ { printf("%-15s%s\n","ZipFileUrl",gensub(/^<a href='"'"'(.*zip)'"'"'.*$/,"\\1","g",$0)) } /^<a href=.*\/json\/cve\/.*'$1'.*meta/ {	printf("%-15s%s\n","MetadataUrl",gensub(/^<a href='"'"'(.*meta)'"'"'.*$/,"\\1","g",$0)) }'
}

# If current folder is an SVN repository, display repo root
getsvnroot() { 
	[[ -d ./.svn ]] && echo "Repo Root:  $(sqlite3 ./.svn/wc.db 'SELECT root from repository')" || ( echo "$(pwd): not an SVN repository" ; return 1 )
}

# Generate all openssl-available hashes of a given string
allhashstr() {
	[[ -z "$1" ]] && ( echo "usage: allhashstr <string>" ; return 1 ) || openssl list -digest-algorithms | sed 's/^.*[=][>][ \t]*\(.*\)$/\1/g' | sort | uniq | awk -v origstr="$1" 'BEGIN { printf("echo \"%10s%s%-10s\"\n","---",origstr,"---"); } { printf("echo -n \"%15s: \" ; openssl dgst -%s <<< \"%s\" | sed '"'"'s/^.*=[ \t]*//g'"'"'\n",$1,$1,origstr); }' | eval "$(cat -)"
}

# return maximum field length for each field in delimted text file
fieldinfo() {
	[[ ! -f $1 && -z "$2" ]] && ( echo "usage: fieldinfo <file> <delimiter>" ; return 1 ) || cat $1 | awk -v delim="$2" 'BEGIN { FS=delim } { print NF; exit; }' | for i in $(seq 1 $(cat -)); do echo "Field $i - $(cat $1 | awk -v delim="$2" 'BEGIN { FS=delim } { print length($'"$i"') }' | sort -n -k1 | tail -n1) characters"; done
}

# grep for string variants
vgrep() {
	[[ -z "$1" ]] && echo "usage: vgrep <string>" || grep -i "$(sed 's/\(.\)/\1.*/g;s/^/.*/g' <<< "$1")"
}

# get number of observables in TAXII data
taxiiobscount() { 
	[[ -z "$1" ]] && echo "usage: taxiiobscount <file>" || sed 's/^[ \t]\+//g' < $1 | tr -d '\n' | xmlpretty | awk -v filen="$1" 'BEGIN { count=0 } /<indicator:Observable / { count = count + 1 } END { printf("%s: %d observables found\n",filen,count); }'
}

# pull observables from TAXII poll data
taxiisearch() { 
	[[ -z "$1" ]] && echo "usage: taxiisearch <file> <observable>" || sed 's/^[ \t]\+//g' < $1 | tr -d '\n' | xmlpretty | awk 'BEGIN { proc=0 } /<indicator:Observable / { proc = 1 } /<\/indicator:Observable>/ { printf("%s\n",$0); proc = 0 } { if (proc == 1) printf("%s",$0); }' | grep "$(sed 's/^'"$1"'[ \t]\+//g' <<< "$@")" | xmlpretty
}

# output a file with formatted line numbers
linenumbers() {
	[[ ! -f $1 ]] && echo "usage: linenumbers <file>" || awk -v RC="$(wc -l $1)" '{ printf("%" length(RC) "s: %s\n",NR,$0); }' $1
}

# Lookup name servers for DNS suffixes
suffixns() {
	[[ -z "$1" ]] && echo "usage: suffixns <dns-suffix>" || curl -s -k https://data.iana.org/TLD/tlds-alpha-by-domain.txt | grep -i "^$1$" | dig $(cat -) NS | awk '/^[^;].*[ \t]+NS[ \t]+/ { print gensub(/^.*[ \t]+NS[ \t](.*)\.$/,"\\1","g",$0); }'
}

# Return page count for a specified PDF file (requires GhostScript)
pdfpages() {
	[[ ! -f $@ ]] && echo "usage: pdfpages <pdf-file>" || gs -q -dNODISPLAY -c "($@) (r) file runpdfbegin pdfpagecount = quit"
}

# will show variable values or run 'eval $(getyumvars)' to load them into memory (variables are named YUM_<variable-name>)
getyumvars() {
	python -c 'import yum ; print yum.YumBase().conf.yumvar' | sed 's/[{}]//g;s/,/\n/g;s/[ \t]*:[ \t]*/:/g' | awk '/Loaded plugins/ { getline } { printf("YUM_%s=\"%s\"\n",gensub(/^[ \t]*'"'"'([^'"'"']+)'"'"':'"'"'([^'"'"']+)'"'"'.*$/,"\\1","g",$0),gensub(/^[ \t]*'"'"'([^'"'"']+)'"'"':'"'"'([^'"'"']+)'"'"'.*$/,"\\2","g",$0)) }'
}

# search debian packages
debsearch() {
	[[ -z "$1" ]] && echo "usage: debsearch <filename>" || curl -skL https://packages.debian.org/file:$1 | grep -A4 '<td.*class="file"' | sed 's/<[\/]*[^>]\+[\/]*>//g' | tr '\n' '|' | sed 's/|--|/\n/g;s/\(|[ \t\|]*|\)/|/g;s/|$//g' | sed 's/|[ \t]*/|/g;s/^[ \t]*//g;s/[ \t]*\[.*\]//g' | awk 'BEGIN { FS="|" ; printf("%-20s%-50s\n","Package","File Path"); } { printf ("%-20s%-50s\n",$2,$1); }'
}

# Check blocklist.de for IP Address
getblde() {
	[[ -z "$1" ]] && echo "usage: getblde <ip-address>" || echo "$1" | (revip="$(cat - | sed 's/\([0-9]\+\)\.\([0-9]\+\)\.\([0-9]\+\)\.\([0-9]\+\)/\4.\3.\2.\1./g')"; sed 's/^/'"$revip"'/g;s/|/|'"$revip"'/g;s/|/\n/g' <<< "apache.bl.blocklist.de|bruteforcelogin.bl.blocklist.de|bl.blocklist.de|all.bl.blocklist.de|ftp.bl.blocklist.de|imap.bl.blocklist.de|mail.bl.blocklist.de|ssh.bl.blocklist.de|sip.bl.blocklist.de") | xargs -I % sh -c "dig % TXT | grep '^[^; \t]'" | sed 's/^.*TXT[ \t]\+\"\([^\"]\+\)\"$/\1/g' | sort | uniq
}

# Calculate pi to a specified decimal length
pi() {
	[[ -z "$1" ]] && echo "usage: pi <length>" || bc -lq <<< "scale=$1+1;4*a(1)" | tr -d '\n' | sed 's/\\//g;s/.$//g'
}

# Calculate Eulers constant to a specified decimal length
e() {
	[[ -z "$1" ]] && echo "usage: e <length>" || bc -lq <<< "scale=$1;e(1)" |tr -d '\n' | sed 's/\\//g'
}

# Change one-line XML from stdin to multi-line XML
xmlpretty() {
	sed 's/\(<\/[^>]+>\)/\1\n/g;s/\(>\)\(<\)/\1\n\2/g'
}

# Return AD Domain Controllers sorted by weight
getdc() {
	[[ -z "$1" ]] && echo "usage: getdc <ad-domain>" || dig _ldap._tcp.dc._msdcs.$1 SRV | awk '/^_ldap._tcp.dc._msdcs./ { printf("%s:%s - %s\n",gensub(/\.$/,"","g",$8),$7,$6); }' | sort -k3 -n
}

# Validate Apache Sling User/Password
slingauth() {
	[[ -z "$1" ]] && echo "usage:  slingauth <host:port> <username>" || (curl -vvv -X POST -F"j_username=$2" -F"j_password=$(read -p "Enter password: " -s passwd ; echo -n $passwd)" "http://$1/home/users/${2:0:1}/$2.html/j_security_check" 2>&1 | awk '/< HTTP\/[0-9\.]+/ { respcode = gensub(/^< HTTP\/[0-9\.]+ ([0-9][0-9][0-9]) .*$/,"\\1","g",$0); if (respcode == "302") { print "Success"; } else { print "Failed"; } }')
}

# Return text between <begin> and <end> from stdin
inbetween() {
	[[ -z "$1" ]] && echo "usage: inbetween <begin> <end>" || awk 'BEGIN { showcrt = 0 } /'"$1"'/ { showcrt = 1 } /'"$2"'/ { print ; showcrt = 0 } { if (showcrt == 1) { print } }'
}

# View logs for a repository in another directory
repologs() {
	[[ -z "$1" ]] && echo "usage: repologs <repo-directory>" || (pushd . ; cd $1 ; git log ; popd)
}

# Get tweet, follower, and following information given a twitter username
twitterinfo() {
	[[ -z "$1" ]] && echo "twitterinfo <username>" || curl -s https://twitter.com/$1 | awk 'BEGIN { tweets=""; following=""; followers=""; } /u-hiddenVisually.*Tweets, current page/ { if (length(tweets)==0) { getline; tweets=gensub(/^.*>(.*)/,"\\1","g",$0); } } /u-hiddenVisually.*Following/ { if(length(following)==0) { getline; following=gensub(/^.*>[ \t]*(.*)[ \t]*<.*$/,"\\1","g",$0); } } /u-hiddenVisually.*Followers/ { if(length(followers)==0) { getline; followers=gensub(/^.*>(.*)<.*$/,"\\1","g",$0); } } END { printf("@'"$1"' info:\n  Tweets: %s\n  Following: %s\n  Followers: %s\n",tweets,following,followers); }'
}

# Get contents of an XML tag from standard input
getxmltag() {
	[[ -z "$1" ]] && echo "usage: getxmltag <tag-name>" || (tr -d '\n' | sed 's/>[ \t]*</></g;s/^.*<'"$1"'>\(.*\)<\/'"$1"'>.*$/\1/g')
}

# Check for generator meta tag to determine wordpress version
iswordpress() {
	[[ -z "$1" ]] && echo "usage: iswordpress <url>" || curl -s "$@" | awk 'BEGIN { found="no" } /^<meta name="generator" content="[Ww]ord[Pp]ress/ { found="yes" } END { if (found == "yes") { print "SUCCESS: Wordpress is running" } else { print "ERROR: Wordpress not running" } }'
}

# View shorter format of output from git logs command containing date and commit ID
gitslog() {
	[[ -d .git ]] && git log | awk 'BEGIN { monvalue[0] = "Jan"; monnum[0] = "01";monvalue[1] = "Feb"; monnum[1] = "02";monvalue[2] = "Mar"; monnum[2] = "03";monvalue[3] = "Apr"; monnum[3] = "04";monvalue[4] = "May"; monnum[4] = "05";monvalue[5] = "Jun"; monnum[5] = "06";monvalue[6] = "Jul"; monnum[6] = "07";monvalue[7] = "Aug"; monnum[7] = "08";monvalue[8] = "Sep";monnum[8] = "09";monvalue[9] = "Oct"; monnum[9] = "10";monvalue[10] = "Nov"; monnum[10] = "11";monvalue[11] = "Dec"; monnum[11] = "12"; } /^commit/ { commit = $2 ; while (!(match($0,/^Date:[ \t]*/))) { getline; } origdate = gensub(/^Date:[ \t]*/,"","g",$0);thismonthval = gensub(/^([a-zA-Z]+) ([a-zA-Z]+) ([0-9]+) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9]) ([0-9][0-9][0-9][0-9]) (.*)$/,"\\2","g",origdate);thismonthnum = "";for (i = 0; i < 12; i++) { if (thismonthval == monvalue[i]) { thismonthnum = monnum[i]; break; } }premon = gensub(/^([a-zA-Z]+) ([a-zA-Z]+) ([0-9]+) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9]) ([0-9][0-9][0-9][0-9]) (.*)$/,"\\5-","g",origdate);postmon = gensub(/^([a-zA-Z]+) ([a-zA-Z]+) ([0-9]+) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9]) ([0-9][0-9][0-9][0-9]) (.*)$/,"-\\3 \\4","g",origdate);printf("%s%s%s\t%s\n",premon,thismonthnum,postmon,commit); }' || echo "$(pwd):  invalid git repository"
}

# Get GZIP date from URL (returns "Wed, Dec 31, 1969  7:00:00 PM" if no GZIP date is found)
gzipdate() {
	[[ -z "$1" ]] && echo "usage: gzipdate <URL>" || date -d @$((16#$(curl -sL0 --raw --compressed -k $1 | xxd -s4 -l4 -p | rev | while read -n2 byte; do printf "$byte" | rev; done)))
}

# Pack a string representation of hexadecimal bytes (like PHP pack function)
packhex() {
	[[ -z "$1" || $((${#@} % 2)) -ne 0 ]] && echo "usage: packhex <byte>" || printf "$(sed 's/\(..\)/\\x\1/g' <<< "$@")"
}

# Pack a string representation of a single decimal byte (like PHP pack function)
packdec() {
	[[ -z "$1" || $1 -gt 255 ]] && echo "usage: packdec <byte>" || printf "\x$(printf '%x' $1)"
}

# Uses eog (Gnome Image Viewer) to run a manually-advanced slideshow with images from a specified directory
slideshow() {
	[[ -z "$1" || ! -d $1 ]] && echo "usage: slideshow </path/to/images>" || eog -f $(ls $1 | egrep -i 'ANI$|BMP$|GIF$|ICO$|JPEG$|JPG$|PCX$|PNG$|PNM$|RAS$|SVG$|TGA$|TIFF$|WBMP$|XBM$|XPM$' | head -n1)
}

# Get next available loop device
nextloop() {
	losetup -a | awk 'END { printf("/dev/loop%s\n",gensub(/^.*\/loop/,"","g",gensub(/:.*$/,"","g",$0))+1); }'
}

# assign arguments to variable names (ex: eval $(getargs -b one -c -d two) will resolve to ARG_b="one", ARG_c="EMPTY", and ARG_d="two") - does only alphabetic characters
getargs() {
	[[ -z "$1" ]] && echo "usage: getargs <arguments>" || echo "$@" | sed 's/[ \t]*\(-[a-zA-Z][ \t]\+\)/\n\1/g' | awk '/^-/ { printf("ARG_%s=\"%s\"\n",gensub(/^-([a-zA-Z]).*$/,"\\1","g",$0),gensub(/^-[a-zA-Z][ \t]+(.*)[ \t]*$/,"\\1","g",$0)) }' | sed 's/""/"EMPTY"/g'
}

# provide the folder size of a specified folder
foldersize() {
	[[ -z "$1" ]] && echo "usage: foldersize </path/to/folder>" || ls -alFR "$1" | awk 'BEGIN { tot=0 } /^-/ { tot=tot+$5 } END { print tot }' | rev | sed 's/\([0-9][0-9][0-9]\)/\1,/g;s/,$//g' | rev
}

# Alerts via email on disk utilization over a certain percent
diskalert() {
        [[ -z "$1" ]] && echo "usage: diskalert <mount-point> <percent-full> <email-address>" || df -hP | grep "$1[ \t]*$" | awk  '{ num = gensub(/%/,"","g",$5); if (num < '"$2"') { printf("PASS") } }' | [[ "$(cat -)" == "PASS" ]] || printf "Subject: $HOSTNAME: Disk Space Usage Alert\nFrom: aem@$HOSTNAME\n\n$(df -hP | grep "$1[ \t]*$" | awk '{ printf("Utilization of %s is using %s out of %s (%s)\n\nDetails:\n",$1,$3,$2,gensub(/%/,"%%","g",$5)) }' ; df -hP | head -n1 | sed 's/%/%%/g' ; df -hP | grep "$1[ \t]*$" | sed 's/%/%%/g')" | sendmail $3
}

# Create URL encoded version of string
urlencode() {
	[[ -z "$1" ]] && echo "usage: urlencode <string>" || xxd -u -p <<< "$1" | tr -d '\n' | sed 's/\(..\)/%\1/g'
}

# Decode URL encoded string
urldecode() {
	[[ -z "$1" ]] && echo "usage: urldecode <string>" || tr -d "%" <<< "$1" | xxd -r -p
}

# Pull weather observations from NOAA NWS using station ID
nwsobs() {
	[[ -z "$1" ]] && echo "usage: nwsobs <station-id>" || curl -Ls $(curl -Ls http://weather.gov/xml/current_obs/index.xml | tr -d '\n' | sed 's/\(<\/station>\)/\1\n/g;s/^.*\(<station>\)/\1/mg;s/\(<\/station>\).*$/\1/mg' | awk '/'"$1"'/ { printf("%s",gensub(/:\/\/weather/,"://w1.weather","g",gensub(/<\/xml_url>.*$/,"","g",gensub(/^.*<xml_url>/,"","g",$0)))) }') | egrep 'location|station_id|latitude|longitude|observation_time_rfc822|temp_f|temp_c|relative_humidity|wind_dir|wind_degrees|wind_mph|pressure_mb|dewpoint_f|dewpoint_c' | sed 's/^[ \t]*<\([a-zA-Z0-9_-]\+\)>/\1: /g;s/<\/[a-zA-Z0-9_-]\+>//g'
}

# Determine manufacturer of NIC based on MAC address (uses Wireshark data)
wsmac() {
	[[ -z "$1" ]] && echo "usage: wsmac <first-6-of-MAC>" || curl -s https://www.wireshark.org/assets/js/manuf.js | sed 's/},{/},\n{/g;s/^.*({/{/g;s/}).*$/}/g' | awk '/'"${1//[-:]}"'/ { printf("%s: %s\n","'"$1"'",gensub(/".*$/,"","g",gensub(/^.*desc":"/,"","g",$0))) }'
}

# display the newest version of Github Enterprise
gheinfo() {
	curl -s https://enterprise.github.com/releases | sed -n '/href="\/releases\/[0-9\.]*">/ { s/^.*\/releases\/\(.*\)".*$/Version:       \1/;p;n;s/^.*note">\(.*\)<.*$/Release Date:  \1/;p;q; }'
}

# file age in seconds, minutes, hours, days, weeks, and years
fileseconds() {
	[[ -z "$1" ]] && echo "usage: fileseconds <filespec>" || echo "$@: $(echo "scale=2;$(date +%s) - $(stat -c %Y $@)" | bc | sed 's/^\./0./g;s/0*$//g') seconds old"
}
fileminutes() {
	[[ -z "$1" ]] && echo "usage: fileminutes <filespec>" || echo "$@: $(echo "scale=2;($(date +%s) - $(stat -c %Y $@))/60" | bc | sed 's/^\./0./g;s/0*$//g') minutes old"
}
filehours() {
	[[ -z "$1" ]] && echo "usage: filehours <filespec>" || echo "$@: $(echo "scale=2;(($(date +%s) - $(stat -c %Y $@))/60)/60" | bc | sed 's/^\./0./g;s/0*$//g') hours old"
}
filedays() {
	[[ -z "$1" ]] && echo "usage: filedays <filespec>" || echo "$@: $(echo "scale=2;((($(date +%s) - $(stat -c %Y $@))/60)/60)/24" | bc | sed 's/^\./0./g;s/0*$//g') days old"
}
fileweeks() {
	[[ -z "$1" ]] && echo "usage: fileweeks <filespec>" || echo "$@: $(echo "scale=2;(((($(date +%s) - $(stat -c %Y $@))/60)/60)/24)/7" | bc | sed 's/^\./0./g;s/0*$//g') weeks old"
}
fileyears() {
	[[ -z "$1" ]] && echo "usage: fileyears <filespec>" || echo "$@: $(echo "scale=2;(((($(date +%s) - $(stat -c %Y $@))/60)/60)/24)/365" | bc | sed 's/^\./0./g;s/0*$//g') years old"
}

# use dshost function to get top results
dsdisplay() {
	[[ -z "$1" ]] && echo "dsdisplay <ip-address> <port> <record count>" || dshost $1 $2 | head -n$3 | LC_ALL=en_US.UTF-8 awk 'BEGIN { FS="|" } { printf("%-5s: %s\n%-5s: %'"'"'d\n%-5s: %'"'"'d\n\n","Host",$1,"In",$2,"Out",$3) }'
}

# get host data in/out information from darkstat instance
dshost() {
        [[ -z "$1" ]] && echo "usage: dshost <ip-address> <port>" || curl -s 'http://'"$1"':'"$2"'/hosts/?full=yes&sort=in' | tr -d '\n' | sed 's/</\n</g' | awk '/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+[ \t]*$/ { print gensub(/^.*>/,"","g",$0); }' | while read line; do echo -n "$line|"; curl -s http://$1:$2/hosts/$line/ | sed 's/<[\/]*[ \t]*[a-zA-Z0-9]\+[ \t]*[\/]*>//g;s/^[ \t]*//g' | awk '/^[IO][nu][t]*:[ \t]*[0-9]/ { printf("%s|",gensub(/,/,"","g",$2)); } END { printf("\n"); }'; done
}

# return the port, protocol, and numeric likelyhood of port being open
nmapweight() {
	[[ -z "$1" ]] && echo "usage: nmapweight <portnumber>" || egrep -v '^#|^[ \t]*$' /usr/share/nmap/nmap-services | awk '{ printf("%s %s\n",$2,$3); }' | grep "^$1\/" | sort -n -k2 -r
}

# Get page of output from a file
getpage() {
	[[ -z "$1" ]] && echo "usage: getpage <file> <lines-per-page> <page-number>" || head -n$[$2*$3] $1 | tail -n$2
}


# Generate random password of a specified length
randompass () {
        [[ -z "$1" ]] && echo "usage: randompass <password-length>" || echo "$(cat /dev/urandom | tr -dc 'a-z' | head -c$1) $(cat /dev/urandom | tr -dc 'A-Z' | head -c$1) $(cat /dev/urandom | tr -dc '0-9' | head -c$1) $(for dash in $(seq 0 $[$1/10]); do echo "-" ; done)" | sed 's/[ \t]//g' | fold -w1 | shuf | tr -d '\n' | head -c$1
}

# Get LatLng for current location based on IP address
getgeolocation() {
	curl -s http://freegeoip.net/csv/ | awk 'BEGIN { FS="," } { printf("%s => (",$1); if ($9 > 0) { printf ("%s N, ",$9); } else { printf("%s S, ",-$9); } if ($10 > 0) { printf ("%f E)",$10); } else { printf("%f W)\n",-$10); } }'
}

# Get how many days until cert for host and port expires
certdays() {
	[[ -z "$1" ]] && echo "usage: certdays <host> <port>" || openssl s_client -connect $1:$2 < /dev/null 2> /dev/null | awk 'BEGIN { showcrt = 0 } /-+BEGIN CERTIFICATE-+/ { showcrt = 1 } /-+END CERTIFICATE-+/ { print ; showcrt = 0 } { if (showcrt == 1) { print } }' | openssl x509 -text | awk '/^[ \t]+Not After[ \t]+:/ { print gensub(/^[ \t]+Not After[ \t]+:[ \t]+(.*)[ \t]*$/,"\\1","g",$0) }' | echo "Host $1:$2 is valid for $[ ($(date -d "$(cat -)" +%s)-$(date +%s)) /86400 ] days"
}

# Get Certificate information for host:port ($1)
certinfo() {
	[[ -z "$1" ]] && echo "usage: certinfo <server> <port>" || (echo -n | openssl s_client -connect $1:$2 2>&1 | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | openssl x509 -text -in - -noout)
}

# Generate base64-encoded auth string for use with HTTP Basic auth: basicauth <username>
basicauth() {
	[[ -z "$1" ]] && echo "usage: basicauth <username>" || echo -n "$1:$(read -s -p "Enter Password: " passwd; echo $passwd)" | openssl enc -base64
}
# View state of threads in a java process: threadstate <PID>
threadstate() {
	[[ -z "$1" ]] && echo "usage: threadstate <pid>" || jstack $1 | grep '^[ \t]*java.lang.Thread.State' | sed 's/^[ \t]*java\.lang\.Thread\.State: //g' | sort | uniq -c
}

# healthcheck AEM host:  aemhost <user> <password> <protocol (http/https)> <host:port>
aemhost() {
	[[ -z "$(curl -s -H"Action: Test" -H\"Path: /content\" -H\"Handle: /content\" -H\"Referrer: about:blank\" -H\"Content-length: 0\" -H\"Content-type: application/octet-stream\" -u $1:$2 $3://$4/bin/receive\?sling:authRequestLogin=1 -I | head -n 1 | grep '200 OK')" ]] && echo "$4 is down" || echo "$4 is up"
}

# Get IP address from specified interface or get all interfaces and IPs
getifip() {
	[[ -z "$1" ]] && echo "usage: getifip <interface>" || ifconfig $1 | grep -B1 inet | sed 's/^\([a-zA-Z0-9]*\):.*/\1/g;s/^.*inet \([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\).*$/\1/g' | xargs echo
}

# print scientific notation of $1
scinote() {
	[[ -z "$1" ]] && echo "usage: scinote <number>" || echo "scale=4;$1/(10^(${#1}-1))" | bc | sed 's/0*$//g' | tr -d '\n' | echo "$(cat - | sed 's/\.$//g')e$[${#1}-1]"
}

# get percent CPU utilization by process name ($1)
pscpu() {
	[[ -z "$1" ]] && echo "usage: pscpu <binary-name>" || ps -C $1 -o pcpu= | awk 'BEGIN { tot=0 } { tot=tot+$1 } END { print tot }'
}

# return HTTP request and response headers for a request
httpheaders() {
	[[ -z "$1" ]] && echo "usage: httpheaders <url>" || curl $@ -vvv 2>&1 | awk '/^[<>] / { print gensub(/^[<>] /,"","g",$0) }'
}

# create a symlink in the current directory (linkfile <target-path>)
linkfile() {
	ln -s $@ $(basename $@)
}

# Converts piped 1-byte between hexidecimal and decimal
alias hextodec="sed 's/^\([0-9][0-9]\).*$/\1/g;s/\([0-9]\)/\1 /g;s/[Aa]/10 /g;s/[Bb]/11 /g;s/[Cc]/12 /g;s/[Dd]/13 /g;s/[Ee]/14 /g;s/[Ff]/15 /g' | awk '{ print (\$1*16)+\$2 }'"
alias dectohex="awk '{ if (\$1 <256) { b1=\$1/16;b2=\$1%16;printf(\"%x%x\",b1,b2); } }'"

# Makes piped JSON slightly pretty
alias jsonpretty="tr -d '\n' | sed 's/\([{}]\)/\n\1\n/g;s/\[/\[\n/g;s/\][^,]/\n\]\n/g;s/\(\],\)/\n\1\n/g;s/,/,\n/g' | grep -v '^$'"

# Return lines $1 through $2 of piped data
getlines () {
	[[ -z "$1" ]] && echo "usage: getlines <start-line> <end-line>" || cat - <(seq 1 $[$2-$1] | sed 's/[0-9]//g') | head -n $(echo "$1+($2-$1)" | bc) | tail -n $(echo "$2-$1+1" | bc) | grep -v '^$'
}

# Use basic or advanced (-a) HTML tag stripping.  Advanced is experimental
striphtml() {
	[[ "$1" == "-a" ]] && sed 's/<[\/]*[ \ta-zA-Z0-9#/=_+.";:-]\+[\/]*>//g' || sed 's/<[\/]*[a-zA-Z0-9]*[ ]*[\/]*>//g'
}

# Convert text to audio and speak it
say() {
	[[ -z "$1" ]] && echo "usage: say <text>" || text2wave <<< "$@" | ffplay -nodisp -autoexit -loglevel quiet - > /dev/null
}

# print first $@ number of characters
firstchar() {
	[[ -z "$1" ]] && echo "usage: firstchar <char-count>" || sed 's/\(^.\{'$@'\}\).*$/\1/g'
}

# Get verbose output of the value of /proc/loadavg
alias getload="cat /proc/loadavg | sed 's/\([0-9]*\.[0-9]*\) \([0-9]*\.[0-9]*\) \([0-9]*\.[0-9]*\) \([0-9]*\)\/\([0-9]*\) \([0-9]*\).*$/1-minute: \1\n5-minute: \2\n15-minute: \3\nCurrent KSE: \4\nTotal KSE: \5\nLast PID: \6/g'"

# Get UNIX timestamp of file $@
getmodtimestamp() {
	[[ -f "$@" ]] && date -d "$(stat $@ | grep '^Modify' | sed 's/^.*: //g')" +%s
}
# return random integer less than $1
randint () {
	[[ -z "$1" ]] && echo "randint <max-value>" || echo "($(echo "scale=${#1};$RANDOM^${#1}/10^${#1}" | bc | sed 's/^.*\./0./g')*$1)+1" | bc | sed 's/\..*$//g'
}

# return file descriptors for PID $1
procfd() {
	[[ -z "$1" ]] && echo "usage: procfd <pid>" || ls -alF /proc/$1/fd | awk '/^l/ { print gensub(/^.*[0-9][0-9]:[0-9][0-9] /,"","g",$0) }'
}

# List files locally on filesystem the current Git repository folder
alias repofiles='[[ -d ".git" ]] && find . -type f | grep -v "^./.git" | sort || echo "$(pwd) is not a repository"'
