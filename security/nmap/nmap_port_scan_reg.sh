#!/bin/bash

scan_host() {
  nmap -sn $1 > /dev/null
  if [ $? -eq 0 ]; then
    echo "Scanning host $1"
    nmap $1
  else
    echo "Host $1 is down"
  fi
}

scan_range() {
  for i in $(seq $1 $2); do
    scan_host $3.$i
  done
}

validate_input() {
  if [[ ! ($1 =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ && ${1%.*} -ge 0 && ${1%.*} -le 255) ]]; then
    echo "Invalid IP address: $1"
    exit 1
  fi

  if [[ ! ($2 =~ ^[0-9]+$ && $2 -ge 0 && $2 -le 32) ]]; then
    echo "Invalid subnet mask: $2"
    exit 1
  fi

  if [[ ! ($3 =~ ^[a-z0-9]+$) ]]; then
    echo "Invalid interface name: $3"
    exit 1
  fi

  if [[ ! (-e /sys/class/net/$3) ]]; then
    echo "Interface $3 does not exist"
    exit 1
  fi

  if [[ ! (-e /sys/class/net/$3/operstate && $(cat /sys/class/net/$3/operstate) == "up") ]]; then
    echo "Interface $3 is not up"
    exit 1
  fi

}

calculate_range() {
  ip_bin=$(echo "$1" | awk -F. '{printf "%08d%08d%08d%08d\n", strtonum("0b" $1), strtonum("0b" $2), strtonum("0b" $3), strtonum("0b" $4)}')
  
  prefix=${ip_bin:0:$2}

datetime=$(date +"%Y-%m-%d_%H-%M-%S")

file_name="scan_results_$datetime.txt"

scan_range $start $end $network $interface > $file_name

mail -s "Nmap scan completed on $datetime" -a $file_name user@example.com < /dev/null
