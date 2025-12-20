#!/bin/bash

if ! command -v wireshark &> /dev/null
then
    echo "Wireshark is not installed. Please install it first."
    exit 1
fi

if [ -z "$1" ]
then
    echo "Please provide a pcap file as an argument."
    exit 2
fi

if [ ! -f "$1" ] || [ ! -r "$1" ]
then
    echo "The pcap file does not exist or is not readable."
    exit 3
fi

TMPDIR=$(mktemp -d)

i=1
while read -r packet
do
    echo "Decoding packet $i..."
    tshark -r "$1" -Y "$packet" -V > "$TMPDIR/packet$i.txt"
    i=$((i+1))
done < <(tshark -r "$1" -T fields -e frame.number -Y "http.authbasic or http.authdigest")

echo "Found $(($i-1)) packets that contain passwords."

cat "$TMPDIR"/*.txt

rm -rf "$TMPDIR"
