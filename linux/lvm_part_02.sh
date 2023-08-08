#!/bin/bash

set -eu

device=""
partition=""
vg_name=""
lv_name=""
lv_size=""

usage () {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -d, --device    Specify the device name (e.g. /dev/sdb)"
  echo "  -v, --vg-name   Specify the volume group name (e.g. data01)"
  echo "  -l, --lv-name   Specify the logical volume name (e.g. mysql01)"
  echo "  -s, --lv-size   Specify the logical volume size (e.g. 12G or 100%FREE)"
  echo "  -h, --help      Display this help message"
}

while getopts ":d:v:l:s:-:" opt; do
  case ${opt} in
    d )
      device=$OPTARG
      ;;
    v )
      vg_name=$OPTARG
      ;;
    l )
      lv_name=$OPTARG
      ;;
    s )
      lv_size=$OPTARG
      ;;
    h )
      usage
      exit 0
      ;;
    - )
      case ${OPTARG} in
        device )
          device="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        vg-name )
          vg_name="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        lv-name )
          lv_name="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        lv-size )
          lv_size="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
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
      echo "Invalid input: $input" >&2
      exit 2
      ;;
  esac
}

if [ -z "$device" ]; then
  device=$(ask_input "Enter the device name (e.g. /dev/sdb): ")
fi

create_partition "$device"
partition="${device}1"

create_pv "$partition"

if [ -z "$vg_name" ]; then
  vg_name=$(ask_input "Enter the volume group name (e.g. data01): ")
fi

create_vg "$partition" "$vg_name"

if [ -z "$lv_name" ]; then
  lv_name=$(ask_input "Enter the logical volume name (e.g. mysql01): ")
fi

if [ -z "$lv_size" ]; then
  lv_size=$(ask_input "Enter the logical volume size (e.g. 12G or 100%FREE): ")
fi

create_lv "$vg_name" "$lv_size" "$lv_name"

format_lv "/dev/$vg_name/$lv_name"

echo "Done!"
