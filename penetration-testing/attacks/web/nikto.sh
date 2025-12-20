#!/bin/bash

display_menu() {
  echo "Welcome to the nikto automation script."
  echo "Please choose an option from the following list:"
  echo "1) Scan a single URL for vulnerabilities"
  echo "2) Scan a single URL with SSL"
  echo "3) Scan a single URL with a specific port"
  echo "4) Scan multiple URLs from a file"
  echo "5) Scan a URL with a specific plugin"
  echo "6) Scan a URL with a specific user agent"
  echo "7) Scan a URL with basic authentication"
  echo "8) Scan a URL with proxy support"
  echo "9) Scan a URL and save the report in HTML format"
  echo "10) Exit the script"
}

scan_url() {
  read -p "Enter the URL to scan: " url
  if [[ $url =~ ^https?:// ]]; then
    nikto -h "$url"
  else
    echo "Invalid URL. Please enter a valid URL starting with http:// or https://"
    display_menu
  fi
}

scan_url_ssl() {
  read -p "Enter the URL to scan: " url
  if [[ $url =~ ^https:// ]]; then
    nikto -h "$url"
  else
    echo "Invalid URL. Please enter a valid URL starting with https://"
    display_menu
  fi
}

scan_url_port() {
  read -p "Enter the URL to scan: " url
  if [[ $url =~ ^https?:// ]]; then
    read -p "Enter the port number: " port
    if [[ $port =~ ^[0-9]+$ ]]; then
      nikto -h "$url" -p "$port"
    else
      echo "Invalid port number. Please enter a valid port number between 0 and 65535."
      display_menu
    fi 
  else
    echo "Invalid URL. Please enter a valid URL starting with http:// or https://"
    display_menu
  fi 
}

scan_file() {
  read -p "Enter the file name containing the URLs to scan: " file 
  if [[ -f $file && -r $file ]]; then 
    nikto -h "$file" 
  else 
    echo "Invalid file. Please enter a valid file name that exists and is readable." 
    display_menu 
  fi 
}

scan_url_plugin() {
  read -p "Enter the URL to scan: " url
  if [[ $url =~ ^https?:// ]]; then
    read -p "Enter the plugin name: " plugin
    nikto -h "$url" -Plugins "$plugin"
  else
    echo "Invalid URL. Please enter a valid URL starting with http:// or https://"
    display_menu
  fi
}

scan_url_useragent() {
  read -p "Enter the URL to scan: " url
  if [[ $url =~ ^https?:// ]]; then
    read -p "Enter the user agent: " useragent
    nikto -h "$url" -useragent "$useragent"
  else
    echo "Invalid URL. Please enter a valid URL starting with http:// or https://"
    display_menu
  fi
}

scan_url_auth() {
  read -p "Enter the URL to scan: " url
  if [[ $url =~ ^https?:// ]]; then
    read -p "Enter the username: " username
    read -p "Enter the password: " password
    nikto -h "$url" -id "$username:$password"
  else
    echo "Invalid URL. Please enter a valid URL starting with http:// or https://"
    display_menu
  fi 
}

scan_url_proxy() {
  read -p "Enter the URL to scan: " url 
  if [[ $url =~ ^https?:// ]]; then 
    read -p "Enter the proxy address: " proxy_address 
    read -p "Enter the proxy port: " proxy_port 
    if [[ $proxy_address =~ ^https?:// && $proxy_port =~ ^[0-9]+$ ]]; then 
      nikto -h "$url" -useproxy "$proxy_address:$proxy_port" 
    else 
      echo "Invalid proxy address or port. Please enter a valid proxy address starting with http:// or https:// and a valid port number between 0 and 65535." 
      display_menu 
    fi 
  else 
    echo "Invalid URL. Please enter a valid URL starting with http:// or https://" 
    display_menu 
  fi 
}

scan_url_html() {
  read -p "Enter the URL to scan: " url 
  if [[ $url =~ ^https?:// ]]; then 
    read -p "Enter the output file name: " output_file 
    nikto -h "$url" -Format html -o "$output_file"  
  else 
    echo "Invalid URL. Please enter a valid URL starting with http:// or https://"  
    display_menu  
  fi  
}

display_menu

while true; do
  read -p "Enter your choice [1-10]: " choice

  case $choice in
    1) scan_url ;;
    2) scan_url_ssl ;;
    3) scan_url_port ;;
    4) scan_file ;;
    5) scan_url_plugin ;;
    6) scan_url_useragent ;;
    7) scan_url_auth ;;
    8) scan_url_proxy ;;
    9) scan_url_html ;;
    10) echo "Bye!" ; exit ;;
    *) echo "Invalid choice. Please enter a number between 1 and 10." ;;
  esac

  display_menu

done
