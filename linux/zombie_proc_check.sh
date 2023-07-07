#!/bin/bash

if [ $(id -u) -ne 0 ]; then
  echo "This script requires root privileges"
  exit 1
fi

# Get the current date and time
now=$(date +"%Y-%m-%d %H:%M:%S")

# Get the zombie processes
zombies=$(ps -eo pid,ppid,state,cmd | awk '$3=="Z"')

# Check if there are any zombies
if [ -z "$zombies" ]; then
  echo "No zombie processes found at $now"
else
  echo "Found zombie processes at $now:"
  echo "$zombies"
  # Ask the user what they want to do
  read -p "Do you want to force kill all zombie processes (a), kill them one by one (b), or specify a process ID to kill (c)? (a/b/c) " answer
  case $answer in
    a)
      znames=$(ps -eo pid,state,cmd | awk '$2=="Z" {print $3}')
      for name in $znames; do
        echo "Killing all processes named $name"
        killall -9 $name
        # Check if the kill was successful
        if [ $? -eq 0 ]; then
          echo "Successfully killed all processes named $name"
        else
          echo "Could not kill all processes named $name"
        fi
      done
      ;;
    b)
      # Loop through the zombies and KILL THEM!
      while read -r pid ppid state cmd; do
        pcmd=$(ps -p $ppid -o cmd --no-headers)
        echo "Killing parent process $ppid ($pcmd) of zombie $pid"
        kill -9 $ppid
        if [ $? -eq 0 ]; then
          echo "Successfully killed parent process $ppid ($pcmd) of zombie $pid"
        else
          echo "Could not kill parent process $ppid ($pcmd) of zombie $pid"
        fi
      done <<< "$zombies"
      ;;
    c)
      read -p "Enter a process ID to kill: " pid
      if [ -z $(ps -p $pid -o state --no-headers) ]; then
        echo "Invalid process ID: $pid"
      elif [ $(ps -p $pid -o state --no-headers) != "Z" ]; then
        echo "Process ID $pid is not a zombie"
      else
        ppid=$(ps -p $pid -o ppid --no-headers)
        pcmd=$(ps -p $ppid -o cmd --no-headers)
        echo "Killing parent process $ppid ($pcmd) of zombie $pid"
        kill -9 $ppid
        if [ $? -eq 0 ]; then
          echo "Successfully killed parent process $ppid ($pcmd) of zombie $pid"
        else
          echo "Could not kill parent process $ppid ($pcmd) of zombie $pid"
        fi
      fi
      ;;
    *)
      echo "Invalid option: $answer"
      ;;
  esac
fi
