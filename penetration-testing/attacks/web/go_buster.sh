#!/bin/bash

function uri_mode() {
  echo "Enter the target URL:"
  read url

  echo "Enter the wordlist path:"
  read wordlist

  echo "Enter the output file (leave blank for stdout):"
  read output

  gobuster dir --url $url --wordlist $wordlist $( [ -n "$output" ] && echo "--output $output" )
}

function dns_mode() {
  echo "Enter the target domain:"
  read domain

  echo "Enter the wordlist path:"
  read wordlist

  echo "Enter the output file (leave blank for stdout):"
  read output

  gobuster dns --domain $domain --wordlist $wordlist $( [ -n "$output" ] && echo "--output $output" )
}

function vhost_mode() {
  echo "Enter the target IP address:"
  read ip

  echo "Enter the wordlist path:"
  read wordlist

  echo "Enter the output file (leave blank for stdout):"
  read output

  gobuster vhost --url $ip --wordlist $wordlist $( [ -n "$output" ] && echo "--output $output" )
}

function s3_mode() {
  echo "Enter the wordlist path:"
  read wordlist

  echo "Enter the output file (leave blank for stdout):"
  read output

  gobuster s3 --wordlist $wordlist $( [ -n "$output" ] && echo "--output $output" )
}

function gcs_mode() {
  echo "Enter the wordlist path:"
  read wordlist

  echo "Enter the output file (leave blank for stdout):"
  read output

  gobuster gcs --wordlist $wordlist $( [ -n "$output" ] && echo "--output $output" )
}

function tftp_mode() {
   echo "Enter the target IP address:"
   read ip

   echo "Enter the wordlist path:"
   read wordlist

   echo "Enter the output file (leave blank for stdout):"
   read output

   gobuster tftp --url $ip --wordlist $wordlist $( [ -n "$output" ] && echo "--output $output" )
}

echo "Welcome to Gobuster script. Please choose an option:"
echo "1) Brute-force URIs in web sites"
echo "2) Brute-force DNS subdomains"
echo "3) Brute-force virtual host names on target web servers"
echo "4) Brute-force open Amazon S3 buckets"
echo "5) Brute-force open Google Cloud buckets"
echo "6) Brute-force TFTP servers"
echo "7) Exit"

read choice

case $choice in 
1) uri_mode ;;
2) dns_mode ;;
3) vhost_mode ;;
4) s3_mode ;;
5) gcs_mode ;;
6) tftp_mode ;;
7) exit ;;
*) echo "Invalid choice. Exiting." ; exit ;;
esac
