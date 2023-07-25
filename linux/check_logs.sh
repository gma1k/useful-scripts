#!/bin/bash

function log_search() {
  echo "Choose an option:"
  echo "1) Errors"
  echo "2) Warnings"
  echo "3) Both"
  echo "4) Quit"

  read -p "Enter your choice: " choice

  case $choice in
    1)
      read -p "Enter the directory path of the log files: " dir_path
      if [ -d "$dir_path" ]; then
        read -p "Enter the keyword to grep on: " keyword
        find "$dir_path" -type f \( -name "*.log" -o -name "*.log.gz" \) | while read file; do
          if [[ $file == *.gz ]]; then
            zgrep -iE "error.*$keyword|$keyword.*error" "$file"
          else
            grep -iE "error.*$keyword|$keyword.*error" "$file"
          fi          
        done        
      else        
        echo "$dir_path is not a valid directory path or does not exist"
      fi      
      ;;
    2)
      read -p "Enter the directory path of the log files: " dir_path      
      if [ -d "$dir_path" ]; then        
        read -p "Enter the keyword to grep on: " keyword        
        find "$dir_path" -type f \( -name "*.log" -o -name "*.log.gz" \) | while read file; do          
          # Check if the file is zipped or not          
          if [[ $file == *.gz ]]; then            
            zgrep -iE "warning.*$keyword|$keyword.*warning" "$file"          
          else            
            grep -iE "warning.*$keyword|$keyword.*warning" "$file"          
          fi          
        done        
      else        
        echo "$dir_path is not a valid directory path or does not exist"      
      fi      
      ;;
    3) 
      read -p "Enter the directory path of the log files: " dir_path      
      if [ -d "$dir_path" ]; then        
        read -p "Enter the keyword to grep on: " keyword        
        find "$dir_path" -type f \( -name "*.log" -o -name "*.log.gz" \) | while read file; do          
          if [[ $file == *.gz ]]; then            
            zgrep -iE "(error|warning).*$keyword|$keyword.*(error|warning)" "$file"          
          else            
            grep -iE "(error|warning).*$keyword|$keyword.*(error|warning)" "$file"          
          fi          
        done        
      else        
        echo "$dir_path is not a valid directory path or does not exist"      
      fi      
      ;;
    4)
      echo "Bye!"      
      exit 0      
      ;;
    *)
      echo "Invalid choice, please try again"      
      log_search      
      ;;
  esac  
}

log_search
