#!/bin/bash

ask_input() {
  read -p "Enter the target IP or hostname: " target
}

show_menu() {
  echo "Please choose one of the following scan options:"
  echo "1) Full and fast"
  echo "2) Full and fast ultimate"
  echo "3) Full and very deep"
  echo "4) Full and very deep ultimate"
  echo "5) Host discovery"
  echo "6) System discovery"
  echo "7) Base"
  read -p "Enter your choice [1-7]: " choice
}

vuln_scan() {
  timeout=3600
  trap 'echo "Scan stopped by user."; exit 0' INT
  case $choice in
    1) config="daba56c8-73ec-11df-a475-002264764cea" ;;
    2) config="698f691e-7489-11df-9d8c-002264764cea" ;;
    3) config="708f25c4-7489-11df-8094-002264764cea" ;;
    4) config="74db13d6-7489-11df-91b9-002264764cea" ;;
    5) config="2d3f051c-55ba-11e3-bf43-406186ea4fc5" ;;
    6) config="bbca7412-a950-11e3-9109-406186ea4fc5" ;;
    7) config="d21f6c81-2b88-4ac1-b7b4-a2a9f2ad4663" ;;
    *) echo "Invalid choice. Please try again." ; show_menu ; vuln_scan ;;
  esac
  echo "Starting vulnerability scan against $target for $timeout seconds using $config configuration."
  time sudo openvas --scan-start $target --config=$config &
  pid=$!
  sleep $timeout || wait $pid
  kill -9 $pid 2>/dev/null
  echo "Scan finished."
}

save_report() {
  report_id=$(sudo openvas --get-report-list | tail -n1 | cut -d' ' -f1)
  file_name="$target_$(date +%Y%m%d).pdf"
  sudo openvas --get-report $report_id --format PDF > $file_name
}

check_input() {
  if [[ -z $target ]]; then
    echo "Invalid input. Please try again."
    ask_input
    check_input
  fi
}

echo "This script will perform a vulnerability scan using OpenVAS and save a report."
echo "Please be careful and ethical when using this script and do not scan any servers without permission."
ask_input
check_input
show_menu
vuln_scan
save_report
