#!/bin/bash

# Step 1: Check if the script is run as root
echo "Step 1: Checking root permissions..."
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
else
   echo "Congratulations, you have root permissions! Proceeding..."
fi

# Step 2: Ask user if they want to update the system
echo "Step 2: System update"
read -p "Do you want to update the system? (yes/no): " update_choice

if [[ "$update_choice" == "yes" ]]; then
    echo "Updating package lists..."
    apt-get update
    echo "Upgrading packages..."
    apt-get upgrade -y
else
    echo "System update skipped."
fi


# Step 3: Ask user if they want to install a web server
echo "Step 3: Web server installation"

read -p "Do you want to install a web server? (yes/no): " web_server_choice

if [[ "$web_server_choice" == "yes" ]]; then
    echo "Choose a web server to install:"
    echo "1. Nginx"
    echo "2. Apache2"

    read -p "Enter your choice (1 or 2): " server_choice

    case $server_choice in
        1)
            echo "Installing Nginx..."
            apt-get install -y nginx
            ;;
        2)
            echo "Installing Apache2..."
            apt-get install -y apache2
            ;;
        *)
            echo "Invalid choice. Skipping web server installation."
            ;;
    esac
else
    echo "Web server installation skipped."
fi