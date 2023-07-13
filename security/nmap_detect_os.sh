#!/bin/bash

# Define scan_host function to scan a single host and check if it is up
scan_host() {
  # Use the -sn flag to perform a ping scan
  nmap -sn $1 > /dev/null
  # If the host is up, scan it for operating system detection
  if [ $? -eq 0 ]; then
    echo "Scanning host $1 for operating system"
    # Use the -O flag to enable OS detection and the -v flag to increase verbosity
    nmap -O -v $1 
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

# Define calculate_range function to calculate the range of hosts from the IP address and subnet mask
calculate_range() {
  # Convert the IP address to binary format
  ip_bin=$(echo "$1" | awk -F. '{printf "%08d%08d%08d%08d\n", strtonum("0b" $1), strtonum("0b" $2), strtonum("0b" $3), strtonum("0b" $4)}')
  
  # Calculate the network prefix and suffix from the subnet mask
  prefix=${ip_bin:0:$2}
  suffix=${ip_bin:$2}
  
  # Calculate the first and last host addresses in binary format by flipping the suffix bits to zero and one respectively
  first_host_bin=$prefix$(printf "%0${#suffix}d\n" | tr '0' '1')
  last_host_bin=$prefix$(printf "%0${#suffix}d\n" | tr '0' '1')
  
  # Convert the first and last host addresses to decimal format and return them as an array
  first_host_dec=$(echo "$first_host_bin" | awk '{print strtonum("0b" substr($0,1,8)) "." strtonum("0b" substr($0,9,8)) "." strtonum("0b" substr($0,17,8)) "." strtonum("0b" substr($0,25,8))}')
  
  last_host_dec=$(echo "$last_host_bin" | awk '{print strtonum("0b" substr($0,1,8)) "." strtonum("0b" substr($0,9,8)) "." strtonum("0b" substr($0,17,8)) "." strtonum("0b" substr($0,25,8))}')
  
  echo "$first_host_dec $last_host_dec"
}

# Get the IP address and subnet mask of the interface that is connected to the network using the ip command
# You can change eth0 to any other interface name that you want to use
ip_address=$(ip -o -f inet addr show eth0 | awk '{print $4}' | cut -d/ -f1)
subnet_mask=$(ip -o -f inet addr show eth0 | awk '{print $4}' | cut -d/ -f2)

# Calculate the range of hosts from the IP address and subnet mask using an array variable 
range=($(calculate_range $ip_address $subnet_mask))

# Extract the start and end of the range from the array variable 
start=${range[0]##*.}
end=${range[1]##*.}

# Extract the network prefix from the IP address
network=${ip_address%.*}.

# Call the scan_range function with the calculated range
scan_range $start $end $network

# Get the current date and time in YYYY-MM-DD_HH-MM-SS format
datetime=$(date +"%Y-%m-%d_%H-%M-%S")

# Create the file name with the date and time
file_name="ping_scan_results_$datetime.txt"

# Call the scan_range function with the user input and a wildcard for the network prefix and redirect the output to a file
scan_range $start $end * > $file_name

# Send an email notification with the file as an attachment
mail -s "Ping scan completed on $datetime" -a $file_name user@example.com < /dev/null