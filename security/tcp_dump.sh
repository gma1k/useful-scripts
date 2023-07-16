#!/bin/bash

list_interfaces() {
  tcpdump -D
}

capture_packets() {
  # Use tcpdump -i -c -w to capture packets
  # Use $1, $2, and $3 as the arguments for interface, count, and file name
  tcpdump -i $1 -c $2 -w $3
}

filter_packets() {
  # Use tcpdump -r to read from a file
  # Use $1 as the argument for file name
  # Use $2 as the argument for filter expression
  tcpdump -r $1 $2
}

drop_privileges() {
  # Use tcpdump -Z to change user ID
  # Use $1 as the argument for user name
  tcpdump -Z $1
}

ask_user() {
  # Use -p option to prompt the user with a message
  # Use -n option to limit the number of characters accepted
  # Store the user input in a variable called answer
  read -p "Do you need to filter specific packets or to show all packets on all available interfaces? (Enter F for filter or A for all): " -n 1 answer
  echo ""
  case $answer in
    F|f) 
      echo "Enter the file name:"
      read file_name
      echo "Enter the filter expression:"
      read filter_expression
      filter_packets $file_name $filter_expression;;
    A|a) 
      echo "The available interfaces are:"
      list_interfaces
      echo "Capturing packets from any interface and displaying them"
      capture_packets any;;
    *) 
      echo "Invalid input. Please enter F or A."
      exit 1;;
  esac
}

ask_user_2() {
  # Use -p option to prompt the user with a message
  # Use -n option to limit the number of characters accepted
  # Store the user input in a variable called answer_2
  read -p "Do you want to capture all packets or just the last and in real time? (Enter L for last or R for real time): " -n 1 answer_2
  echo ""
  case $answer_2 in 
    L|l) 
      echo "Enter the interface:"
      read interface_2 
      echo "Enter the number of packets:"
      read count_2 
      echo "Enter the file name:"
      read file_name_2 
      capture_packets $interface_2 $count_2 $file_name_2;;
    R|r) 
      echo "Enter the interface:"
      read interface_3 
      echo "Capturing and displaying packets from $interface_3 interface in real time"
      capture_packets $interface_3 -n;;
    *) 
      echo "Invalid input. Please enter L or R."
      exit 1;;
   esac  
}

ask_user

ask_user_2

echo "Dropping privileges to user nobody after capturing packets"
drop_privileges nobody
