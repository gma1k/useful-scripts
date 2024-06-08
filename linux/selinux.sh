#!/bin/bash

# Check if the script is run as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root."
        exit 1
    fi
}

# Get the current SELinux state
get_selinux_status() {
    SELINUX_STATE=$(getenforce)
    echo "Current SELinux state: $SELINUX_STATE"
}

# Enable SELinux 
enable_selinux() {
    setenforce 1
    echo "SELinux is now in enforcing mode."
}

# Disable SELinux
disable_selinux() {
    setenforce 0
    echo "SELinux is now in permissive mode."
}

# Menu options
display_menu() {
    echo "SELinux Management Menu:"
    echo "1. Check SELinux status"
    echo "2. Enable SELinux"
    echo "3. Disable SELinux"
    read -p "Enter your choice (1/2/3): " choice
}

# Main choice
main() {
    check_root
    display_menu

    case $choice in
        1)
            get_selinux_status
            ;;
        2)
            enable_selinux
            ;;
        3)
            disable_selinux
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Call main
main
