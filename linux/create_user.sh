#!/bin/bash

generate_password() {
  openssl rand -base64 20 | tr -dc 'a-zA-Z0-9$@=%' | head -c 14
}

create_user() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: create_user user_name group_name"
    exit 1
  fi

  if id -u "$1" >/dev/null 2>&1; then
    echo "User $1 already exists"
    exit 2
  fi

  if ! grep -q "^$2:" /etc/group; then
    echo "Group $2 does not exist"
    exit 3
  fi

  useradd -m -g "$2" "$1"
  echo "User $1 created and added to group $2"

  password=$(generate_password)
  echo "$1:$password" | chpasswd
  echo "Password for $1 is $password"

  passwd -e "$1"
  echo "Please change your password on first login using the command: passwd $1"
}

create_sudo_user() {
  if [ -z "$1" ]; then
    echo "Usage: create_sudo_user user_name"
    exit 1
  fi

  if id -u "$1" >/dev/null 2>&1; then
    echo "User $1 already exists"
    exit 2
  fi

  useradd -m -G sudo "$1"
  echo "User $1 created and added to sudo group"

   # Generate a random password
   password=$(generate_password)
   echo "$1:$password" | chpasswd
   echo "Password for $1 is $password"

   # Expire password
   passwd -e "$1"
   echo "Please change your password on first login using the command: passwd $1"
}

echo "Do you want to create a sudo user or a regular user?"
select choice in "sudo" "regular" "exit"; do
  case $choice in
    sudo )
      read -p "Enter the user name: " user_name
      create_sudo_user "$user_name"
      break;;
    regular )
      read -p "Enter the user name: " user_name
      read -p "Enter the group name: " group_name
      create_user "$user_name" "$group_name"
      break;;
    exit )
      echo "Bye!"
      exit;;
    * )
      echo "Invalid choice. Please try again.";;
  esac
done
