#!/bin/bash

function ftp_user_control() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with sudo"
    exit 1
  fi

  echo "Choose an option:"
  echo "1) Block a user account for FTP access"
  echo "2) Unblock a user account for FTP access"
  echo "3) Quit"

  read -p "Enter your choice: " choice

  case $choice in
    1) 
      read -p "Enter the username to block: " username
      if getent passwd $username > /dev/null; then
        if grep -q $username /etc/vsftpd/user_list; then
          echo "$username is already blocked for FTP access"
        else
          echo "$username" >> /etc/vsftpd/user_list
          systemctl restart vsftpd
          echo "$username is blocked for FTP access"
        fi
      else
        echo "$username is not a valid user"
      fi
      ;;
    2)
      read -p "Enter the username to unblock: " username
      if getent passwd $username > /dev/null; then
        if grep -q $username /etc/vsftpd/user_list; then
          sed -i "/$username/d" /etc/vsftpd/user_list
          systemctl restart vsftpd
          echo "$username is unblocked for FTP access"
        else
          echo "$username is not blocked for FTP access"
        fi
      else
        echo "$username is not a valid user"
      fi      
      ;;
    3)
      echo "Bye!"
      exit 0      
      ;;
    *)
      echo "Invalid choice, please try again"
      ftp_user_control      
      ;;
  esac  
}

ftp_user_control
