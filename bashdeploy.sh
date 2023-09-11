#!/bin/bash

BASEDIR=$(dirname $0)

CONFIGFILE="$BASEDIR/.bashdeploy.conf"

listfiles() {
	egrep -v '^#|^[ \t]*$' $CONFIGFILE | awk 'BEGIN { FS="|"; printf("%-30s%-30s%-10s\n","Source File","Destination Directory","SrcOK") } { exist=""; if (system("[ -f '$BASEDIR'" $1 " ]") == 0) { exist="Yes" } else { exist="No" } printf("%-30s%-30s%-10s\n",$1,$2,exist) }'
}

addfile() {
	if [ "$1" == "int" ]; then
		read -p "Enter Local file path (within current folder): " localfile
		read -p "Enter destination folder: " destfolder
		if [ -f $BASEDIR$localfile ]; then
			echo "$localfile|$destfolder" >> $CONFIGFILE
		else
			echo "Error: $localfile does not exist"
		fi
	else
		cat - >> $CONFIGFILE
	fi
}

removefile() {
	read -p "Enter local file to delete: " delfile
	grep -v "^$delfile" $CONFIGFILE > $CONFIGFILE.tmp
	mv $CONFIGFILE.tmp $CONFIGFILE
	while true; do
		read -s -n1 -p "Delete from filesystem (y/n) " okdel
		printf "\n"
		if [ "$okdel" == "y" ] || [ "$okdel" == "Y" ]; then
			printf "Deleting file..."
			rm $BASEDIR$delfile
			printf "done\n"
			break
		elif [ "$okdel" == "n" ] || [ "$okdel" == "N" ]; then
			break
		else
			continue
		fi
	done
}

deployfiles() {
	if [ "$1" == "int" ]; then
		while true; do
			read -s -n1 -p "This will overwrite files.  Continue (y/n) " -s cont
			printf "\n"
			if [ "$cont" == "y" ] || [ "$cont" == "Y" ]; then
				egrep -v '^#|^[ \t]*$' $CONFIGFILE | while read line; do
					localfile=$(echo $line | sed 's/|.*$//g')
					destfolder=$(echo $line | sed 's/^.*|//g')
					printf "Deploying $(basename $localfile) to $destfolder..."
					[[ ! -d $destfolder ]] && mkdir -p $destfolder
					cp $BASEDIR$localfile $destfolder
					printf "done\n"
				done
				break
			elif [ "$cont" == "n" ] || [ "$cont" == "N" ]; then
				break
			else
				continue
			fi
		done
	else
		egrep -v '^#|^[ \t]*$' $CONFIGFILE | while read line; do
			localfile=$(echo $line | sed 's/|.*$//g')
			destfolder=$(echo $line | sed 's/^.*|//g')
			printf "Deploying $(basename $localfile) to $destfolder..."
			[[ ! -d $destfolder ]] && mkdir -p $destfolder
			cp $BASEDIR$localfile $destfolder
			printf "done\n"
		done
	fi
}

makepackage() {
	printf "Creating Package..."
	tar -czf $BASEDIR/deploy.tar.gz $BASEDIR/*
	printf "done\n"
}

usage() {
	echo "usage: $0 <-l | -a | -r | -d[ia] >"
        echo "      -l -> list files"
        echo "      -ai -> Add files (interactive)"
	echo "      -aa -> Add files (automatic)"
        echo "      -r -> Remove files (interactive)"
        echo "      -di -> Deploy files (interactive)"
        echo "      -da -> Deploy files (automatic)"
	echo "      -p -> Package files"
}

if [ -z "$1" ]; then
	usage
else
	case "$1" in
		"-l")
			listfiles
			;;
		"-ai")
			addfile int
			;;
		"-aa")
			addfile
			;;
		"-r")
			removefile
			;;
		"-di")
			deployfiles int
			;;
		"-da")
			deployfiles
			;;
		"-p")
			makepackage
			;;
		*)
			echo "Invalid argument"
			usage
	esac
fi