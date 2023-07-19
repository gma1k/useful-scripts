#!/bin/bash

ask_input() {
  read -p "Enter the target IP or hostname: " target
}

security_audit() {
  timeout=600
  trap 'echo "Audit stopped by user."; exit 0' INT
  echo "Starting security audit against $target for $timeout seconds."
  time sudo lynis -Q -c $target &
  pid=$!
  sleep $timeout || wait $pid
  kill -9 $pid 2>/dev/null
  echo "Audit finished."
}

check_input() {
  if [[ -z $target ]]; then
    echo "Invalid input. Please try again."
    ask_input
    check_input
  fi
}

echo "This script will perform a security audit using Lynis."
echo "Please be careful and ethical when using this script and do not audit any servers without permission."
ask_input
check_input
security_audit
