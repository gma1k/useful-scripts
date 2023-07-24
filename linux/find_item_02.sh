#!/bin/bash

find_folder() {
  echo "Enter the folder name or part of the name:"
  read folder_name
  # Validate the folder name
  if [ -z "$folder_name" ]; then
    echo "Folder name cannot be empty."
    exit 1
  fi
  find . -type d -name "*$folder_name*"
}

find_file() {
  echo "Enter the file name or part of the name:"
  read file_name
  if [ -z "$file_name" ]; then
    echo "File name cannot be empty."
    exit 1
  fi
  find . -type f -name "*$file_name*"
}

echo "What do you need to do?"
echo "1) Find a folder"
echo "2) Find a file"
echo "3) Quit"
read choice

case $choice in
  1)
    find_folder
    ;;
  2)
    find_file
    ;;
  3)
    exit 0
    ;;
  *)
    echo "Invalid choice. Please enter 1, 2 or 3."
    exit 1
    ;;
esac
