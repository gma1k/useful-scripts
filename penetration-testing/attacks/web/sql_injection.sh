#!/bin/bash

display_menu() {
  echo "Welcome to the sqlmap automation script."
  echo "Please choose an option from the following list:"
  echo "1) Scan a single URL for SQL injection vulnerabilities"
  echo "2) Scan a list of URLs from a file for SQL injection vulnerabilities"
  echo "3) Scan a Google dork query for SQL injection vulnerabilities"
  echo "4) Exit the script"
}

scan_url() {
  read -p "Enter the URL to scan: " url
  if [[ $url =~ ^https?:// ]]; then
    sqlmap -u "$url" --batch --smart --level=3 --risk=3
  else
    echo "Invalid URL. Please enter a valid URL starting with http:// or https://"
    display_menu
  fi
}

scan_file() {
  read -p "Enter the file name containing the URLs to scan: " file
  if [[ -f $file && -r $file ]]; then
    sqlmap -m "$file" --batch --smart --level=3 --risk=3
  else
    echo "Invalid file. Please enter a valid file name that exists and is readable."
    display_menu
  fi
}

scan_dork() {
  read -p "Enter the Google dork query to scan: " dork
  sqlmap -g "$dork" --batch --smart --level=3 --risk=3
}

display_menu

while true; do
  read -p "Enter your choice [1-4]: " choice

  case $choice in
    1) scan_url ;;
    2) scan_file ;;
    3) scan_dork ;;
    4) echo "Bye!" ; exit ;;
    *) echo "Invalid choice. Please enter a number between 1 and 4." ;;
  esac

  display_menu

done
