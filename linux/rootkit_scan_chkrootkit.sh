#!/bin/bash

ask_input() {
  read -p "Enter the target IP or hostname: " target
}

rootkit_scan() {
  timeout=600
  trap 'echo "Scan stopped by user."; exit 0' INT
  echo "Starting rootkit scan against $target for $timeout seconds."
  time sudo chkrootkit -q -r $target &
  pid=$!
  sleep $timeout || wait $pid
  kill -9 $pid 2>/dev/null
  echo "Scan finished."
}

check_input() {
  if [[ -z $target ]]; then
    echo "Invalid input. Please try again."
    ask_input
    check_input
  fi
}

echo "This script will perform a rootkit scan using Chkrootkit."
echo "Please be careful and ethical when using this script and do not scan any servers without permission."
ask_input
check_input
rootkit_scan
