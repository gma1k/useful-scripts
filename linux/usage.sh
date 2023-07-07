#!/bin/bash

convert_kb() {
  # Get the value in kilobytes as first argument
  local kb=$1
  # If the value is greater than or equal to 1 GB, use GB, otherwise use MB
  if [[ $kb -ge 1048576 ]]; then
    # Convert to GB and add unit
    echo $(awk -v k=$kb 'BEGIN {printf "%.2f GB", k / (1024 * 1024)}')
  else
    # Convert to MB and add unit
    echo $(awk -v k=$kb 'BEGIN {printf "%.2f MB", k / 1024}')
  fi
}

read -p "Enter the path of user folder on ftp: " user_path

read -p "Enter the path of ftp file system: " ftp_path

# Get the disk usage of user folder in kilobytes using du command
user_usage_kb=$(du -sk $user_path | awk '{print $1}')

# Get the available space of ftp file system in kilobytes using df command
ftp_avail_kb=$(df -k $ftp_path | awk 'NF == 6 {print $4} NF == 5 {print $3}')

# Convert kilobytes to megabytes or gigabytes
user_usage=$(convert_kb $user_usage_kb)
ftp_avail=$(convert_kb $ftp_avail_kb)

# Calculate the percentage
percentage=$(awk -v u=$user_usage_kb -v f=$ftp_avail_kb 'BEGIN {printf "%.2f", (u / f) * 100}')

# Print output message
echo "User usage: $user_usage $user_path"
echo "FTP available space: $ftp_avail $ftp_path"
echo "Percentage: $percentage%"

