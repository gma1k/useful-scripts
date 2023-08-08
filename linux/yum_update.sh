#!/bin/bash

shopt -s extglob

update_and_upgrade () {
  echo "Updating and upgrading the system using yum"
  sudo yum update -y || { echo "Failed to update the package lists" >&2; exit 1; }
  sudo yum upgrade -y || { echo "Failed to upgrade the installed packages" >&2; exit 2; }
  echo "Done!"
}

exclude_packages () {
  for package in "$@"
  do
    sudo yum versionlock add "$package" || { echo "Failed to mark $package as held back" >&2; exit 5; }
  done

  echo "The following packages will be excluded from being upgraded: $*"
}

read -p "Enter the names of the packages you want to exclude from being upgraded (separated by space): " -a exclude

exclude_packages "${exclude[@]}"

read -r -p "Do you want to update and upgrade your system? (y/n): " answer

case "$answer" in
  [yY])
    update_and_upgrade
    ;;
  [nN])
    echo "Okay, exiting the script"
    exit 0
    ;;
  *)
    echo "Invalid input: $answer"
    exit 4
    ;;
esac

read -r -p "Do you want to reboot your system? (y/n): " answer

if [[ "$answer" == [yY] ]]; then
  echo "Rebooting your system"
  sudo reboot
elif [[ "$answer" == [nN] ]]; then
  echo "Okay, not rebooting your system"
  exit 0
else
  echo "Invalid input: $answer"
  exit 6
fi
