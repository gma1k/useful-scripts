#!/usr/bin/env ruby

def check_device(device)
  if File.blockdev?(device)
    puts "Device #{device} exists"
  else
    puts "Device #{device} does not exist"
    exit 1
  end
end

def create_partition(device)
  puts "Creating a partition on #{device}"
  system("fdisk #{device} <<EOF
n
p



w
EOF")
end

def create_pv(partition)
  puts "Creating a physical volume on #{partition}"
  system("pvcreate #{partition}")
end

def create_vg(partition, vg_name)
  puts "Creating a volume group named #{vg_name} on #{partition}"
  system("vgcreate #{vg_name} #{partition}")
end

def create_lv(vg_name, lv_size, lv_name)
  puts "Creating a logical volume named #{lv_name} with size #{lv_size} on #{vg_name}"
  system("lvcreate -n #{lv_name} --size #{lv_size} #{vg_name}")
end

def format_lv(lv_path)
  puts "Formatting #{lv_path} with ext4 filesystem"
  system("mkfs.ext4 #{lv_path}")
end

def ask_input(prompt, pattern)
  print prompt
  input = gets.chomp
  
   if input.empty?
     puts "Input cannot be empty"
     exit 2
   end

  case input
    when pattern
      return input
    else
      puts "Invalid input: #{input}"
      exit 2 
   end 
end

device = ask_input("Enter the device name (e.g. /dev/sdb): ", /\/dev\/sd[a-z]/)

check_device(device)

create_partition(device)
partition = "#{device}1"

create_pv(partition)

vg_name = ask_input("Enter the volume group name (e.g. data01): ", /[A-Za-z]+/)

create_vg(partition, vg_name)

lv_name = ask_input("Enter the logical volume name (e.g. mysql01): ", /[A-Za-z]+/)

lv_size = ask_input("Enter the logical volume size (e.g. 12G or 100%FREE): ", /[0-9]+[Gg]|100%FREE/)

create_lv(vg_name, lv_size, lv_name)

format_lv("/dev/#{vg_name}/#{lv_name}")

puts "Done!"
