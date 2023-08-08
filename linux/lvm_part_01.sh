#!/bin/bash

check_device () {
  if [ -b "$1" ]; then
    echo "Device $1 exists"
  else
    echo "Device $1 does not exist"
    exit 1
  fi
}

create_partition () {
  echo "Creating a partition on $1"
  fdisk "$1" <<EOF
n
p



w
EOF
}

create_pv () {
  echo "Creating a physical volume on $1"
  pvcreate "$1"
}

create_vg () {
  echo "Creating a volume group named $2 on $1"
  vgcreate "$2" "$1"
}

create_lv () {
  echo "Creating a logical volume named $3 with size $2 on $1"
  lvcreate -n "$3" --size "$2" "$1"
}

format_lv () {
  echo "Formatting $1 with ext4 filesystem"
  mkfs.ext4 "$1"
}

ask_input () {
  read -p "$1" input
  case "$input" in
    /dev/sd[a-z])
      check_device "$input"
      ;;
    [0-9]*[Gg])
      echo "$input"
      ;;
    [A-Za-z]*)
      echo "$input"
      ;;
    *)
      echo "Invalid input: $input"
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
