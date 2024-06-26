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


# Step 4: Check if web server is working
echo "Step 4: Checking web server status"
read -p "Do you want to check if the web server is working? (yes/no): " check_web_server

if [[ "$check_web_server" == "yes" ]]; then
    echo "Curling localhost to check web server status..."
    curl -s http://localhost
else
    echo "Web server check skipped."
fi


# Step 5: Add a new user
echo "Step 5: Adding a new user"
read -p "Do you want to add a new user? (yes/no): " add_user_choice

if [[ "$add_user_choice" == "yes" ]]; then
    read -p "Enter the username for the new user: " username

    # Check if the username already exists
    while id "$username" &>/dev/null; do
        echo "Username '$username' already exists. Please choose a different username."
        read -p "Enter a new username: " username
    done

    # Add the user with sudo for administrative tasks
    sudo adduser $username

    # Add the user to sudo group
    sudo usermod -aG sudo $username

    # Add the user to www-data group
    sudo usermod -aG www-data $username

    echo "User '$username' successfully added and added to 'sudo' and 'www-data' groups."
else
    echo "User addition skipped."
fi
