#!/bin/bash

function pam_user_control() {
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
}

pam_user_control
