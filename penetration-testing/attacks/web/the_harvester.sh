#!/bin/bash

theharvester_scan() {
  echo "Enter the domain name to scan:"
  read domain

  echo "Choose the options to use:"
  echo "0) Use the default options (-b google -l 100)"
  echo "1) Verify the host names via DNS resolution and search for virtual hosts"
  echo "2) Perform a DNS brute force for the domain name"
  echo "3) Perform a DNS TLD expansion discovery"
  echo "4) Port scan the detected hosts and check for takeovers"
  echo "5) Use a specific DNS server"
  echo "6) Use SHODAN database to query discovered hosts"
  echo "Enter the numbers of the options separated by space (e.g. 1 2 3):"
  read options

  cmd="theharvester -d $domain"
  for opt in $options; do
    case $opt in
      0) cmd="$cmd -b google -l 100";;
      1) cmd="$cmd -v";;
      2) cmd="$cmd -c";;
      3) cmd="$cmd -t";;
      4) cmd="$cmd -p";;
      5) echo "Enter the DNS server to use:"
         read dns
         cmd="$cmd -e $dns";;
      6) cmd="$cmd -h";;
      *) echo "Invalid option: $opt";;
    esac
  done

  echo "Running the command: $cmd"
  
  eval $cmd | tee output.txt
}

theharvester_scan
