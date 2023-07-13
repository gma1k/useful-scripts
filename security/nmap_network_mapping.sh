#!/bin/bash

# A function to get the IP address and subnet mask of the default interface
get_ip_and_mask() {
  # Use ip command to get the default interface name
  local interface=$(ip route | grep default | awk '{print $5}')
  # Use ip command to get the IP address and subnet mask of the interface
  local ip_and_mask=$(ip -o -f inet addr show $interface | awk '{print $4}')
  # Split the IP address and subnet mask by /
  local ip=${ip_and_mask%/*}
  local mask=${ip_and_mask#*/}
  # Return the IP address and subnet mask as a string
  echo "$ip $mask"
}

# A function to convert a subnet mask to a CIDR notation
mask_to_cidr() {
  # Use bc command to convert the subnet mask to binary
  local binary_mask=$(echo "obase=2; ibase=16; ${1//./;}" | bc | tr -d '\n')
  # Count the number of 1s in the binary mask
  local cidr=$(echo "$binary_mask" | tr -cd '1' | wc -c)
  # Return the CIDR notation as a string
  echo "$cidr"
}

# A function to perform an aggressive nmap scan based on the IP address and CIDR notation
nmap_scan() {
  # Use nmap command with -A option for aggressive scan and -sV option for service version detection
  # Use the IP address and CIDR notation as the target range
  nmap -A -sV "$1/$2"
}

# Main script
# Get the IP address and subnet mask of the default interface
ip_and_mask=$(get_ip_and_mask)
# Split the IP address and subnet mask by space
ip=${ip_and_mask% *}
mask=${ip_and_mask#* }
# Convert the subnet mask to a CIDR notation
cidr=$(mask_to_cidr $mask)
# Perform an aggressive nmap scan based on the IP address and CIDR notation
nmap_scan $ip $cidr

# Get the current date and time in YYYY-MM-DD_HH-MM-SS format
datetime=$(date +"%Y-%m-%d_%H-%M-%S")

# Create the file name with the date and time
file_name="scan_results_$datetime.txt"

# Call the scan_range function with the calculated range and redirect the output to a file
scan_range $start $end $network $interface > $file_name

# Send an email notification with the file as an attachment
mail -s "Nmap scan completed on $datetime" -a $file_name user@example.com < /dev/null
