#!/bin/bash

set -eu

usage () {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -h, --help      Display this help message"
}

while getopts ":h:-:" opt; do
  case ${opt} in
    h )
      usage
      exit 0
      ;;
    - )
      case ${OPTARG} in
        help )
          usage
          exit 0
          ;;
        * )
          echo "Invalid option: --$OPTARG" >&2
          usage
          exit 2
          ;;
      esac;;
    \? )
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 2
      ;;
    : )
      echo "Option -$OPTARG requires an argument." >&2
      usage
      exit 2
      ;;
  esac
done

check_device () {
  if [ -b "$1" ]; then
    echo "Device $1 exists"
  else
    echo "Device $1 does not exist" >&2
    exit 1
  fi
}

create_partition () {
  echo "Creating a partition on $1"
  fdisk "$1" '<<EOF || { echo "Failed to create partition on $1" >&2; exit 3; }
n
p



w
EOF'
}

create_pv () {
  echo "Creating a physical volume on $1"
  pvcreate "$1" || { echo "Failed to create physical volume on $1" >&2; exit 4; }
}

create_vg () {
  echo "Creating a volume group named $2 on $1"
  vgcreate "$2" "$1" || { echo "Failed to create volume group named $2 on $1" >&2; exit 5; }
}

create_lv () {
  echo "Creating a logical volume named $3 with size $2 on $1"
  lvcreate -n "$3" --size "$2" "$1" || { echo "Failed to create logical volume named $3 with size $2 on $1" >&2; exit 6; }
}

format_lv () {
  echo "Formatting $1 with ext4 filesystem"
  mkfs.ext4 "$1" || { echo "Failed to format $1 with ext4 filesystem" >&2; exit 7; }
}

ask_input () {
  # Use read -p to prompt the user and store the input in a variable
  read -p "$1" input

   if [ -z "$input" ]; then 
     echo "Input cannot be empty" >&2
     exit 2
   fi

  case "$input" in
    # If the input matches /dev/sd[a-z], call the check_device function and return it as is 
    /dev/sd[a-z])
      check_device "$input"
      echo "$input"
      ;;
    [0-9]*[Gg])
      echo "$input"
      ;;
    [A-Za-z]*)
      echo "$input"
      ;;
    *)
      echo "Invalid input: $input" >&2 
      exit 2 
      ;;
   esac 
}

device=$(ask_input "Enter the device name (e.g. /dev/sdb): ")

create_partition "$device"
partition="${device}1"

create_pv "$partition"

vg_name=$(ask_input "Enter the volume group name (e.g. data01): ")

create_vg "$partition" "$vg_name"

lv_name=$(ask_input "Enter the logical volume name (e.g. mysql01): ")

lv_size=$(ask_input "Enter the logical volume size (e.g. 12G or 100%FREE): ")

create_lv "$vg_name" "$lv_size" "$lv_name"

format_lv "/dev/$vg_name/$lv_name"

echo "Done!"
