#!/bin/bash

kill_process() {
  echo "Enter the process name:"
  read process_name
  if [ -z "$process_name" ]; then
    echo "Process name cannot be empty."
    return 1 # Return with error code 1
  fi
  ps -ef | grep "$process_name" | grep -v grep # Exclude grep itself from the output
  if [ $? -ne 0 ] || [ -z "$(ps -ef | grep "$process_name" | grep -v grep)" ]; then
    echo "No processes found with that name."
    return 1
  fi
  echo "Do you want to kill any of these processes? (y/n)"
  read answer
  if [ "$answer" == "y" ]; then
    echo "Enter the process id (PID) of the process you want to kill:"
    read pid
    if [ -z "$pid" ]; then
      echo "Process id cannot be empty."
      return 1
    fi
    echo "Do you want to force kill the process? (y/n)"
    read option
    if [ "$option" == "y" ]; then
      option="-9"
    else
      option=""
    fi
    echo "Are you sure you want to kill the process with PID $pid? (y/n)"
    read confirmation
    if [ "$confirmation" == "y" ]; then
      kill $option $pid 
      if [ $? -eq 0 ]; then 
        echo "Process killed successfully." 
      else 
        echo "Failed to kill process." 
      fi 
    else 
      echo "Aborting..." 
      return 0
    fi 
  else 
    echo "Aborting..." 
    return 0
  fi 
}

show_menu() {
  echo "What type of process do you need to kill?"
  echo "1) User process"
  echo "2) System process"
  echo "3) Quit"
}

main() {
  while true; do
    show_menu
    read choice

    case $choice in
      1)
        kill_process
        result=$?
        ;;
      2)
        sudo kill_process
        result=$?
        ;;
      3)
        exit 0
        ;;
      *)
        echo "Invalid choice. Please enter 1, 2 or 3."
        break 
        ;;
    esac

    if [ $result -eq 0 ]; then 
      echo "Do you want to repeat or change your choice? (y/n)"
      read answer 
      if [ "$answer" == "n" ]; then
        break 
      fi 
    fi 

    echo ""
    
   done  
}

main

trap "echo 'Exiting the script...'; exit 0" SIGINT
