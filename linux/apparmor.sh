#!/bin/bash

# Check if the script is run as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root."
        exit 1
    fi
}

# Get the current AppArmor status
get_apparmor_status() {
    aa-status
}

# Enable AppArmor
enable_apparmor() {
    systemctl start apparmor
    echo "AppArmor is now enabled."
}

# Disable AppArmor
disable_apparmor() {
    systemctl stop apparmor
    echo "AppArmor is now disabled."
}

# Menu options
display_menu() {
    echo "AppArmor Management Menu:"
    echo "1. Check AppArmor status"
    echo "2. Enable AppArmor"
    echo "3. Disable AppArmor"
    read -p "Enter your choice (1/2/3): " choice
}

# Main choice
main() {
    check_root
    display_menu

    case $choice in
        1)
            get_apparmor_status
            ;;
        2)
            enable_apparmor
            ;;
        3)
            disable_apparmor
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Call main
main
