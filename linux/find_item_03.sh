#!/bin/bash

find_folder() {
  echo "Enter the folder name or part of the name:"
  read folder_name
  if [ -z "$folder_name" ]; then
    echo "Folder name cannot be empty."
    return 1 # Return with error code 1
  fi
  find . -type d -name "*$folder_name*" 2>/dev/null # Redirect errors to /dev/null
  if [ $? -ne 0 ] || [ -z "$(find . -type d -name "*$folder_name*" 2>/dev/null)" ]; then
    echo "No folders found with that name."
    return 1 # Return with error code 1
  fi
}

find_file() {
  echo "Enter the file name or part of the name:"
  read file_name
  if [ -z "$file_name" ]; then
    echo "File name cannot be empty."
    return 1 # Return with error code 1
  fi
  find . -type f -name "*$file_name*" 2>/dev/null # Redirect errors to /dev/null
  if [ $? -ne 0 ] || [ -z "$(find . -type f -name "*$file_name*" 2>/dev/null)" ]; then
    echo "No files found with that name."
    return 1
  fi
}

show_menu() {
  echo "What do you need to do?"
  echo "1) Find a folder"
  echo "2) Find a file"
  echo "3) Quit"
}

main() {
  while true; do
    show_menu
    read choice

    case $choice in
      1)
        find_folder
        result=$?
        if [ $result -eq 0 ]; then
          echo "Do you want to repeat or change your choice? (y/n)"
          read answer 
          if [ "$answer" == "n" ]; then
            break 
          fi 
        fi 
        ;;
      2)
        find_file
        result=$?
        if [ $result -eq 0 ]; then
          echo "Do you want to repeat or change your choice? (y/n)"
          read answer 
          if [ "$answer" == "n" ]; then 
            break 
          fi 
        fi 
        ;;
      3)
        exit 0
        ;;
      *)
        echo "Invalid choice. Please enter 1, 2 or 3."
        break 
        ;;
    esac

    # Add an empty line for readability 
    echo ""
    
   done  
}

main

trap "echo 'Exiting the script...'; exit 0" SIGINT
