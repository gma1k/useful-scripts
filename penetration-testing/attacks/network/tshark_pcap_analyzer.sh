#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "Enter the .pcap file you want to analyze:"
read PCAP

if [ -z "$PCAP" ] || [ ! -f "$PCAP" ]
  then echo "Invalid .pcap file"
  exit
fi

tshark -r $PCAP -Y http -T json -e ip.src -e ip.dst -e http.request.method -e http.request.uri -e http.response.code
