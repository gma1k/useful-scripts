#!/bin/bash

ask_input() {
  read -p "Enter the target website URL: " target_url
}

website_scan() {
  timeout=600
  trap 'echo "Scan stopped by user."; exit 0' INT
  echo "Starting website vulnerability scan against $target_url for $timeout seconds."
  time sudo nmap --script http-vuln*,ssl-enum-ciphers,vulners -p 80,443 $target_url &
  pid=$!
  sleep $timeout || wait $pid
  kill -9 $pid 2>/dev/null
  echo "Scan finished."
}

check_input() {
  if [[ -z $target_url ]]; then
    echo "Invalid input. Please try again."
    ask_input
    check_input
  fi
}

echo "This script will perform a website vulnerability scan using Nmap."
echo "Please be careful and ethical when using this script and do not scan any websites without permission."
ask_input
check_input
website_scan
