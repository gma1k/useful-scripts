#!/bin/bash

kill_process() {
  echo "Enter the process name:"
  read process_name
  if [ -z "$process_name" ]; then
    echo "Process name cannot be empty."
    exit 1 # Exit with error code 1
  fi
  ps -ef | grep "$process_name" | grep -v grep
  if [ $? -ne 0 ]; then
    echo "No processes found with that name."
    exit 1 # Exit with error code 1
  fi
  echo "Do you want to kill any of these processes? (y/n)"
  read answer
  if [ "$answer" == "y" ]; then
    echo "Enter the process id (PID) of the process you want to kill:"
    read pid
    if [ -z "$pid" ]; then
      echo "Process id cannot be empty."
      exit 1 # Exit with error code 1
    fi
    echo "Do you want to force kill the process? (y/n)"
    read option
    if [ "$option" == "y" ]; then
      option="-9" # Use -9 option for force kill
    else
      option="" # Use no option for normal kill
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
      exit 0 # Exit with success code 
    fi 
  else 
    echo "Aborting..." 
    exit 0 # Exit with success code 
  fi 
}

echo "What type of process do you need to kill?"
echo "1) User process"
echo "2) System process"
echo "3) Quit"
read choice

case $choice in
  1)
    kill_process
    ;;
  2)
    sudo kill_process
    ;;
  3)
    exit 0
    ;;
  *)
    echo "Invalid choice. Please enter 1, 2 or 3."
    exit 1 
    ;;
esac
