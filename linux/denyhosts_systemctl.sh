#!/bin/bash

function denyhosts_ip_control() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with sudo"
    exit 1
  fi

  echo "Choose an option:"
  echo "1) Ban an IP address in Denyhosts"
  echo "2) Unban an IP address in Denyhosts"
  echo "3) Quit"

  read -p "Enter your choice: " choice

  case $choice in
    1)
      read -p "Enter the IP address to ban: " ip_address
      if [[ $ip_address =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && [[ $ip_address != "127.0.0.1" ]]; then
        if grep -q $ip_address /etc/hosts.deny; then
          echo "$ip_address is already banned in Denyhosts"
        else
          systemctl stop denyhosts.service          
          echo "$ip_address" >> /etc/hosts.deny
          echo "$ip_address" >> /var/lib/denyhosts/hosts 
          echo "$ip_address" >> /var/lib/denyhosts/hosts-restricted
          echo "$ip_address" >> /var/lib/denyhosts/hosts-root
          echo "$ip_address" >> /var/lib/denyhosts/hosts-valid
          echo "$ip_address" >> /var/lib/denyhosts/users-hosts
          echo "# Banned by denyhosts_ip_control script on $(date)" >> /etc/hosts.deny
          echo "# Banned by denyhosts_ip_control script on $(date)" >> /var/lib/denyhosts/hosts 
          echo "# Banned by denyhosts_ip_control script on $(date)" >> /var/lib/denyhosts/hosts-restricted
          echo "# Banned by denyhosts_ip_control script on $(date)" >> /var/lib/denyhosts/hosts-root
          echo "# Banned by denyhosts_ip_control script on $(date)" >> /var/lib/denyhosts/hosts-valid
          echo "# Banned by denyhosts_ip_control script on $(date)" >> /var/lib/denyhosts/users-hosts          
          systemctl start denyhosts.service          
          echo "$ip_address is banned in Denyhosts"
        fi        
      else        
        echo "$ip_address is not a valid IP address or is localhost"
      fi      
      ;;
    2)    
      read -p "Enter the IP address to unban: " ip_address      
      if [[ $ip_address =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && [[ $ip_address != "127.0.0.1" ]]; then        
        if grep -q $ip_address /etc/hosts.deny; then          
          systemctl stop denyhosts.service          
          sed -i -B 1 "/$ip_address/d" /etc/hosts.deny          
          sed -i -B 1 "/$ip_address/d" /var/lib/denyhosts/hosts           
          sed -i -B 1 "/$ip_address/d" /var/lib/denyhosts/hosts-restricted          
          sed -i -B 1 "/$ip_address/d" /var/lib/denyhosts/hosts-root          
          sed -i -B 1 "/$ip_address/d" /var/lib/denyhosts/hosts-valid          
          sed -i -B 1 "/$ip_address/d" /var/lib/denyhosts/users-hosts          
          read -p "Enter the username to check and reset: " username
          if getent passwd $username > /dev/null; then
            echo "Checking the login counts for $username"
            pam_tally2 --user=$username
            echo "Resetting or unlocking $username's account"
            pam_tally2 --user=$username --reset
            echo "$username's account is checked and reset"
          else
            echo "$username is not a valid user"
          fi          
          systemctl start denyhosts.service          
          echo "$ip_address is unbanned in Denyhosts"        
        else          
          echo "$ip_address is not banned in Denyhosts"        
        fi      
      else        
        echo "$ip_address is not a valid IP address or is localhost"      
      fi      
      ;;
    3)
      echo "Bye!"      
      exit 0      
      ;;
    *)
      echo "Invalid choice, please try again"      
      denyhosts_ip_control      
      ;;
  esac  
}

denyhosts_ip_control
