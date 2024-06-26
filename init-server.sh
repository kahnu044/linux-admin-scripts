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
