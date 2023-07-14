#!/bin/bash

# A function to start Wireshark without decryption
start_wireshark_no_decrypt() {
  local interface=$1
  local filter=$2
  # Create a unique file name
  local filename=capture-$USER-$(date +%F-%H%M%S).pcap
  # Start Wireshark
  tshark -i "$interface" ${filter:+-f "$filter"} -w "$filename"
}

# A function to start Wireshark with decryption
start_wireshark_decrypt() {
  local interface=$1
  local keylog=$2
  local filter=$3
  # Create a unique file name
  local filename=capture-$USER-$(date +%F-%H%M%S).pcap
  # Start Wireshark
  tshark -i "$interface" ${filter:+-f "$filter"} -o "tls.keylog_file:$keylog" -w "$filename"
}

# Ask the user for path to key log file
read -p "Enter the path to the key log file: " key_log_file

# Check if the key log file exists and is readable
if [ ! -f "$key_log_file" ] || [ ! -r "$key_log_file" ]; then
  echo "Invalid or inaccessible key log file: $key_log_file"
  exit 1
fi

# Ask the user whether to decrypt packets or not
read -p "Do you want to decrypt packets (D) or not (N)? " decrypt_option

# Use a case statement to handle the decrypt option
case $decrypt_option in
  D|d)
    read -p "Do you want to capture all packets (A) or specify the IP address to capture (S)? " capture_option

    # Use another case statement to handle the capture option
    case $capture_option in
      A|a)
        interface=$(ip -o -4 addr show | grep "$ip_address" | awk '{print $2}')

        # Check if interface exists
        if [ -z "$interface" ]; then
          echo "No interface found for IP address $ip_address"
          exit 1
        fi

        # Call the function to start Wireshark with decryption without a filter
        start_wireshark_decrypt "$interface" "$key_log_file"
        ;;
      S|s)
        read -p "Enter your IP address: " ip_address
        read -p "Enter your subnet mask: " subnet_mask

        # Determine the network interface that matches the IP address
        interface=$(ip -o -4 addr show | grep "$ip_address" | awk '{print $2}')

        # Check if the interface exists
        if [ -z "$interface" ]; then
          echo "No interface found for IP address $ip_address"
          exit 1
        fi

        # Create a filter to capture only the packets in the same subnet
        filter="ip.addr == $ip_address/$subnet_mask"

        # Call the function to start Wireshark with decryption with a filter
        start_wireshark_decrypt "$interface" "$key_log_file" "-f" "$filter"
        ;;
      *)
        echo "Invalid option: $capture_option"
        exit 1 
        ;;
    esac 
    ;;
  N|n)
    read -p "Do you want to capture all packets (A) or specify the IP address to capture (S)? " capture_option

    # Use another case statement to handle the capture option 
    case $capture_option in 
      A|a)
        interface=$(ip -o -4 addr show | grep "$ip_address" | awk '{print $2}')

        # Check if the interface exists 
        if [ -z "$interface" ]; then 
          echo "No interface found for IP address $ip_address"
          exit 1 
        fi 

        # Call the function to start Wireshark without decryption without a filter 
        start_wireshark_no_decrypt "$interface"
        ;;
      S|s)
        read -p "Enter your IP address: " ip_address
        read -p "Enter your subnet mask: " subnet_mask

        # Determine the network interface that matches the IP address 
        interface=$(ip -o -4 addr show | grep "$ip_address" | awk '{print $2}')

        # Check if the interface exists 
        if [ -z "$interface" ]; then 
          echo "No interface found for IP address $ip_address"
          exit 1 
        fi 

        # Create a filter to capture only the packets in the same subnet 
        filter="ip.addr == $ip_address/$subnet_mask"

        # Call the function to start Wireshark without decryption with a filter 
        start_wireshark_no_decrypt "$interface" "-f" "$filter"
        ;;
      *)
        echo "Invalid option: $capture_option"
        exit 1 
        ;;
    esac 
    ;;
  *)
    echo "Invalid option: $decrypt_option"
    exit 1 
    ;;
esac
