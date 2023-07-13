#!/bin/bash

# A function to list the available interfaces for capturing packets
list_interfaces() {
  # Use tcpdump -D to show the interfaces
  tcpdump -D
}

# A function to capture packets
capture_packets() {
  # Use tcpdump -i -c -w to capture packets
  # Use $1, $2, and $3 as the arguments for interface, count, and file name
  tcpdump -i $1 -c $2 -w $3
}

# A function to filter packets by host, port, protocol, or expression
filter_packets() {
  # Use tcpdump -r to read from a file
  # Use $1 as the argument for file name
  # Use $2 as the argument for filter expression
  tcpdump -r $1 $2
}

# A function to drop privileges after capturing packets
drop_privileges() {
  # Use tcpdump -Z to change user ID
  # Use $1 as the argument for user name
  tcpdump -Z $1
}

# A function to ask the user if they need to filter specific packets or to show all packets on all available interfaces
ask_user() {
  # Use read command to get user input
  # Use -p option to prompt the user with a message
  # Use -n option to limit the number of characters accepted
  # Store the user input in a variable called answer
  read -p "Do you need to filter specific packets or to show all packets on all available interfaces? (Enter F for filter or A for all): " -n 1 answer
  # Use echo command to print a new line
  echo ""
  # Use case statement to check the user input and perform different actions accordingly
  case $answer in
    # If the user input is F or f, call the filter_packets function with the file name and filter expression as arguments
    F|f) 
      echo "Enter the file name:"
      read file_name
      echo "Enter the filter expression:"
      read filter_expression
      filter_packets $file_name $filter_expression;;
    # If the user input is A or a, call the list_interfaces function and then capture packets from any interface and display them
    A|a) 
      echo "The available interfaces are:"
      list_interfaces
      echo "Capturing packets from any interface and displaying them"
      capture_packets any;;
    # If the user input is anything else, print an error message and exit the script with status code 1
    *) 
      echo "Invalid input. Please enter F or A."
      exit 1;;
  esac
}

# A function to ask the user if they want to capture all packets or just the last and in real time
ask_user_2() {
  # Use read command to get user input
  # Use -p option to prompt the user with a message
  # Use -n option to limit the number of characters accepted
  # Store the user input in a variable called answer_2
  read -p "Do you want to capture all packets or just the last and in real time? (Enter L for last or R for real time): " -n 1 answer_2
  # Use echo command to print a new line
  echo ""
  # Use case statement to check the user input and perform different actions accordingly
  case $answer_2 in 
    # If the user input is L or l, call the capture_packets function with the interface, count, and file name as arguments 
    L|l) 
      echo "Enter the interface:"
      read interface_2 
      echo "Enter the number of packets:"
      read count_2 
      echo "Enter the file name:"
      read file_name_2 
      capture_packets $interface_2 $count_2 $file_name_2;;
    # If the user input is R or r, call the capture_packets function with the interface and -n option as arguments 
    R|r) 
      echo "Enter the interface:"
      read interface_3 
      echo "Capturing and displaying packets from $interface_3 interface in real time"
      capture_packets $interface_3 -n;;
    # If the user input is anything else, print an error message and exit the script with status code 1 
    *) 
      echo "Invalid input. Please enter L or R."
      exit 1;;
   esac  
}

# Main script

# Ask the user if they need to filter specific packets or to show all packets on all available interfaces
ask_user

# Ask the user if they want to capture all packets or just the last and in real time
ask_user_2

# Drop privileges to user nobody after capturing packets
echo "Dropping privileges to user nobody after capturing packets"
drop_privileges nobody
