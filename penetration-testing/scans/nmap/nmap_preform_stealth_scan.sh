#!/bin/bash

get_ip_and_mask() {
  local interface=$(ip route | grep default | awk '{print $5}')
  local ip_and_mask=$(ip -o -f inet addr show $interface | awk '{print $4}')
  local ip=${ip_and_mask%/*}
  local mask=${ip_and_mask#*/}
  echo "$ip $mask"
}

mask_to_cidr() {
  local binary_mask=$(echo "obase=2; ibase=16; ${1//./;}" | bc | tr -d '\n')
  local cidr=$(echo "$binary_mask" | tr -cd '1' | wc -c)
  echo "$cidr"
}

nmap_scan() {
  nmap -sS -sV "$1/$2" -oG scan_results.txt
}

show_up_down() {
  local up_count=$(grep Up scan_results.txt | wc -l)
  local down_count=$(grep Down scan_results.txt | wc -l)
  echo "$up_count IP addresses are up"
  echo "$down_count IP addresses are down"
}

ip_and_mask=$(get_ip_and_mask)
ip=${ip_and_mask% *}
mask=${ip_and_mask#* }
cidr=$(mask_to_cidr $mask)
nmap_scan $ip $cidr
show_up_down

datetime=$(date +"%Y-%m-%d_%H-%M-%S")

file_name="preform_scan_results_$datetime.txt"

scan_range $start $end * > $file_name

mail -s "Preforming stealth scan completed on $datetime" -a $file_name user@example.com < /dev/null
