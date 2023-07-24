#!/bin/bash

find_item() {
  echo "Enter the item type (folder or file):"
  read item_type
  if [ "$item_type" != "folder" ] && [ "$item_type" != "file" ]; then
    echo "Invalid item type. Please enter folder or file."
    exit 1
  fi
  echo "Enter the item name or part of the name:"
  read item_name
  # Validate the item name
  if [ -z "$item_name" ]; then
    echo "Item name cannot be empty."
    exit 1
  fi
  if [ "$item_type" == "folder" ]; then
    find . -type d -name "*$item_name*"
  elif [ "$item_type" == "file" ]; then
    find . -type f -name "*$item_name*"
  fi
}

echo "What do you need to do?"
echo "1) Find an item"
echo "2) Exit"
read choice

case $choice in
  1)
    find_item
    ;;
  2)
    exit 0
    ;;
  *)
    echo "Invalid choice. Please enter 1 or 2."
    exit 1
    ;;
esac
