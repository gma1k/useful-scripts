#!/bin/bash

# Define scan_host function to scan a single host
scan_host() {
  # Check if the host is up
  nmap -sn $1 > /dev/null
  # If the host is up, scan its ports
  if [ $? -eq 0 ]; then
    echo "Scanning host $1"
    nmap $1
  else
    echo "Host $1 is down"
  fi
}

# Define scan_range function to scan a range of hosts
scan_range() {
  # Loop through the range of hosts
  for i in $(seq $1 $2); do
    # Call the scan_host function with each host
    scan_host $3.$i
  done
}

# Define validate_input function to validate user input
validate_input() {
  # Check if the IP address is valid
  if [[ ! ($1 =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ && ${1%.*} -ge 0 && ${1%.*} -le 255) ]]; then
    echo "Invalid IP address: $1"
    exit 1
  fi

  # Check if the subnet mask is valid
  if [[ ! ($2 =~ ^[0-9]+$ && $2 -ge 0 && $2 -le 32) ]]; then
    echo "Invalid subnet mask: $2"
    exit 1
  fi

  # Check if the interface name is valid and exists
  if [[ ! ($3 =~ ^[a-z0-9]+$) ]]; then
    echo "Invalid interface name: $3"
    exit 1
  fi

  if [[ ! (-e /sys/class/net/$3) ]]; then
    echo "Interface $3 does not exist"
    exit 1
  fi

  # Check if the interface is up
  if [[ ! (-e /sys/class/net/$3/operstate && $(cat /sys/class/net/$3/operstate) == "up") ]]; then
    echo "Interface $3 is not up"
    exit 1
  fi

}

# Define calculate_range function to calculate the range of hosts from the IP address and subnet mask
calculate_range() {
  # Convert the IP address to binary format
  ip_bin=$(echo "$1" | awk -F. '{printf "%08d%08d%08d%08d\n", strtonum("0b" $1), strtonum("0b" $2), strtonum("0b" $3), strtonum("0b" $4)}')
  
  # Calculate the network prefix and suffix from the subnet mask
  prefix=${ip_bin:0:$2}

# Get the current date and time in YYYY-MM-DD_HH-MM-SS format
datetime=$(date +"%Y-%m-%d_%H-%M-%S")

# Create the file name with the date and time
file_name="scan_results_$datetime.txt"

# Call the scan_range function with the calculated range and redirect the output to a file
scan_range $start $end $network $interface > $file_name

# Send an email notification with the file as an attachment
mail -s "Nmap scan completed on $datetime" -a $file_name user@example.com < /dev/null