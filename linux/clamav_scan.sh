#!/bin/bash

update_db() {
  echo "Updating virus database..."
  sudo freshclam -v
}

deep_scan() {
  # -r: recursive scan
  # -i: only show infected files
  # --bell: ring a bell when finding a virus
  # --exclude-dir: exclude directories from scanning
  # --max-filesize: scan files up to the specified size
  # --max-scansize: scan files up to the specified size
  # --detect-pua: detect potentially unwanted applications
  # --scan-mail: scan mail files
  # --scan-ole2: scan OLE2 containers
  # --scan-pdf: scan PDF files
  # --scan-swf: scan SWF files
  # --scan-html: scan HTML files
  # --scan-archive: scan archive files
  options="-r -i --bell --exclude-dir=^/sys --max-filesize=4000M --max-scansize=4000M --detect-pua=yes --scan-mail=yes --scan-ole2=yes --scan-pdf=yes --scan-swf=yes --scan-html=yes --scan-archive=yes"
  
  echo "Starting deep dive scan..."
  sudo clamscan $options /
}

quick_scan() {
  # -r: recursive scan
  # -i: only show infected files
  # --bell: ring a bell when finding a virus
  options="-r -i --bell"
  
  echo "Starting quick scan..."
  sudo clamscan $options /home
}

show_menu() {
  echo "Please choose one of the following scan options:"
  echo "1) Deep dive scan"
  echo "2) Quick scan"
  read -p "Enter your choice [1-2]: " choice
}

check_choice() {
  if [[ $choice != [1-2] ]]; then
    echo "Invalid choice. Please try again."
    show_menu
    check_choice
  fi
}

echo "This script will update the virus database and perform a scan using ClamAV."
update_db
show_menu
check_choice

case $choice in 
  1) deep_scan ;;
  2) quick_scan ;;
esac
