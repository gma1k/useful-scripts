#!/bin/bash

start_wireshark_no_decrypt() {
  local interface=$1
  local filter=$2
  local filename=capture-$USER-$(date +%F-%H%M%S).pcap
  tshark -i "$interface" ${filter:+-f "$filter"} -w "$filename"
}

start_wireshark_decrypt() {
  local interface=$1
  local keylog=$2
  local filter=$3
  local filename=capture-$USER-$(date +%F-%H%M%S).pcap
  tshark -i "$interface" ${filter:+-f "$filter"} -o "tls.keylog_file:$keylog" -w "$filename"
}

read -p "Enter the path to the key log file: " key_log_file

if [ ! -f "$key_log_file" ] || [ ! -r "$key_log_file" ]; then
  echo "Invalid or inaccessible key log file: $key_log_file"
  exit 1
fi

read -p "Do you want to decrypt packets (D) or not (N)? " decrypt_option

case $decrypt_option in
  D|d)
    read -p "Do you want to capture all packets (A) or specify the IP address to capture (S)? " capture_option

    case $capture_option in
      A|a)
        interface=$(ip -o -4 addr show | grep "$ip_address" | awk '{print $2}')

        if [ -z "$interface" ]; then
          echo "No interface found for IP address $ip_address"
          exit 1
        fi

        start_wireshark_decrypt "$interface" "$key_log_file"
        ;;
      S|s)
        read -p "Enter your IP address: " ip_address
        read -p "Enter your subnet mask: " subnet_mask

        interface=$(ip -o -4 addr show | grep "$ip_address" | awk '{print $2}')

        if [ -z "$interface" ]; then
          echo "No interface found for IP address $ip_address"
          exit 1
        fi

        filter="ip.addr == $ip_address/$subnet_mask"

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

    case $capture_option in 
      A|a)
        interface=$(ip -o -4 addr show | grep "$ip_address" | awk '{print $2}')

        if [ -z "$interface" ]; then 
          echo "No interface found for IP address $ip_address"
          exit 1 
        fi 

        start_wireshark_no_decrypt "$interface"
        ;;
      S|s)
        read -p "Enter your IP address: " ip_address
        read -p "Enter your subnet mask: " subnet_mask

        interface=$(ip -o -4 addr show | grep "$ip_address" | awk '{print $2}')

        if [ -z "$interface" ]; then 
          echo "No interface found for IP address $ip_address"
          exit 1 
        fi 

        filter="ip.addr == $ip_address/$subnet_mask"

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
