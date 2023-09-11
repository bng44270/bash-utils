#!/bin/bash

##############################
# Perform time-delayed packet capture and save the results to a pcap file
#
# usage: timed-pcap.sh <pcap-file> <seconds>
#
# Standard settings are put into a configuration file names ~/.timed-pcap.conf
#       Settings include:
#                 PacketFilter - standard tcpdump packet capture filter
#                 CaptureInterface - network interface to capture (default: eth0)
##############################

countdown() {
	counter="$@"
	printf "$counter"
	while [ $counter -gt 0 ]; do
		sleep 1
		export counter=$(echo $counter-1|bc)
		printf "...$counter"
	done
	printf "\n"
}

if [ -z "$1" ]; then
  echo "usage:  timed-pcap.sh <pcap-file> <seconds>"
else
  if [ ! -f ~/.timed-pcap.conf ]; then
    printf "PacketFilter \n" > ~/.timed-pcap.conf
    printf "CaptureInterface eth0\n" >> ~/.timed-pcap.conf
  fi
  pcapfile="$1"
  duration="$2"
  packetfilter=$(cat ~/.timed-pcap.conf | grep PacketFilter | sed 's/^PacketFilter //g')
  captureinterface=$(cat ~/.timed-pcap.conf | grep CaptureInterface | sed 's/^CaptureInterface //g')
  tcpdump -i $captureinterface "$packetfilter" -s 65535 -w $pcapfile &
  echo "Waiting for tcpdump to start..."
  sleep 2
  echo "Starting capture countdown:"
  countdown $duration
  jobpid=$(jobs -l | grep tcpdump | awk '{ print $2 }')
  kill -9 $jobpid
fi