#!/bin/bash
set -eu

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with sudo." >&2
    exit 1
fi

# Display logs based on the log type (error or warning)
show_logs() {
    local log_type=$1
    read -p "Enter the directory path of the log files: " dir_path
    if [ -d "$dir_path" ]; then
        read -p "Enter the keyword to grep on: " keyword
        find "$dir_path" -type f \( -name "*.log" -o -name "*.log.gz" \) | while read file; do
            if [[ $file == *.gz ]]; then
                zgrep -iE "$log_type.*$keyword|$keyword.*$log_type" "$file"
            else
                grep -iE "$log_type.*$keyword|$keyword.*$log_type" "$file"
            fi
        done
    else
        echo "$dir_path is not a valid directory path or does not exist"
    fi
}

# Main menu
echo "Please select an option:"
echo "1. Show Error Logs"
echo "2. Show Warning Logs"
echo "3. Quit"
read -p "Enter your choice (1/2/3): " choice

case $choice in
    1)
        show_logs "error"
        ;;
    2)
        show_logs "warning"
        ;;
    3)
        echo "Exiting the script."
        ;;
    *)
        echo "Invalid choice. Exiting the script."
        ;;
esac
