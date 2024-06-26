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

# Step 6: Create project folder
echo "Step 6: Creating project folder"
read -p "Do you want to add a project folder? (yes/no): " create_project_choice

if [[ "$create_project_choice" == "yes" ]]; then
    # Prompt for project folder name or default to 'apps'
    read -p "Enter the folder name for projects (default: apps): " folder_name
    folder_name=${folder_name:-apps}  # Set default to 'apps' if empty

    # If we already have the new user
    if [[ "$add_user_choice" == "yes" ]]; then
        echo "Adding project folder for - '$username' "
    else
        echo "Select the Existing user:"

        # Get a list of existing users added manually by root
        user_list=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd)

        select username in $user_list; do
            if [[ -n "$username" ]]; then
                break
            else
                echo "Invalid selection. Please choose a username from the list."
            fi
        done

        # Check if a username was selected
        if [[ -z "$username" ]]; then
            echo "No username selected. Exiting."
            exit 1
        fi

        echo "Selected username: $username"
    fi

    # Proceed to create project folder if username is set
    if [[ -n "$username" ]]; then
        # Create the project folder in user's home directory
        sudo -u $username mkdir -p /home/$username/$folder_name

        # Set ownership of the folder to the user
        sudo chown -R $username:$username /home/$username/$folder_name

        # Set permissions (example: 755 for directories)
        sudo chmod 755 /home/$username/$folder_name

        echo "Project folder '/home/$username/$folder_name' created for user '$username'."
    else
        echo "Project folder creation skipped."
    fi
else
    echo "Project folder creation skipped."
fi
