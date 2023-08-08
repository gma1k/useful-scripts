#!/usr/bin/env python3

import subprocess
import re

def check_device(device):
  if subprocess.run(["test", "-b", device], check=False).returncode == 0:
    print(f"Device {device} exists")
  else:
    print(f"Device {device} does not exist")
    exit(1)

def create_partition(device):
  print(f"Creating a partition on {device}")
  subprocess.run(f"fdisk {device} <<EOF\nn\np\n\n\n\nw\nEOF", shell=True, check=True)

def create_pv(partition):
  print(f"Creating a physical volume on {partition}")
  subprocess.run(["pvcreate", partition], check=True)

def create_vg(partition, vg_name):
  print(f"Creating a volume group named {vg_name} on {partition}")
  subprocess.run(["vgcreate", vg_name, partition], check=True)

def create_lv(vg_name, lv_size, lv_name):
  print(f"Creating a logical volume named {lv_name} with size {lv_size} on {vg_name}")
  subprocess.run(["lvcreate", "-n", lv_name, "--size", lv_size, vg_name], check=True)

def format_lv(lv_path):
  print(f"Formatting {lv_path} with ext4 filesystem")
  subprocess.run(["mkfs.ext4", lv_path], check=True)

def ask_input(prompt, pattern):
  input = input(prompt)
  
   if not input:
     print("Input cannot be empty")
     exit(2)
   
  if re.match(pattern, input):
    return input
  else:
    print(f"Invalid input: {input}")
    exit(2)

device = ask_input("Enter the device name (e.g. /dev/sdb): ", r"/dev/sd[a-z]")

check_device(device)

create_partition(device)
partition = f"{device}1"

create_pv(partition)

vg_name = ask_input("Enter the volume group name (e.g. data01): ", r"[A-Za-z]+")

create_vg(partition, vg_name)

lv_name = ask_input("Enter the logical volume name (e.g. mysql01): ", r"[A-Za-z]+")

lv_size = ask_input("Enter the logical volume size (e.g. 12G or 100%FREE): ", r"[0-9]+[Gg]|100%FREE")

create_lv(vg_name, lv_size, lv_name)

format_lv(f"/dev/{vg_name}/{lv_name}")

print("Done!")
