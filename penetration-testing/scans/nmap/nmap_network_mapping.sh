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
  # Use nmap command with -A option for aggressive scan and -sV option for service version detection
  # Use the IP address and CIDR notation as the target range
  # Use -oG option to output the scan results in grepable format
  nmap -A -sV "$1/$2" -oG scan_results.txt
}

show_up_down() {
  local up_count=$(grep Up scan_results.txt | wc -l)
  local down_count=$(grep Down scan_results.txt | wc -l)
  echo "$up_count IP addresses are up"
  echo "$down_count IP addresses are down"
}

# Get the IP address and subnet mask of the default interface
ip_and_mask=$(get_ip_and_mask)
# Split the IP address and subnet mask by space
ip=${ip_and_mask% *}
mask=${ip_and_mask#* }
# Convert the subnet mask to a CIDR notation
cidr=$(mask_to_cidr $mask)
# Perform an aggressive nmap scan based on the IP address and CIDR notation
nmap_scan $ip $cidr
# Show how many IP addresses are up and down in the scan results
show_up_down

datetime=$(date +"%Y-%m-%d_%H-%M-%S")

file_name="scan_results_$datetime.txt"

scan_range $start $end $network $interface > $file_name

mail -s "Nmap scan completed on $datetime" -a $file_name user@example.com < /dev/null
