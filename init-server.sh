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

        # Step 7: Create a test project and Nginx configuration
        echo "Step 7: Creating a test project and Nginx configuration"
        read -p "Do you want to create a test project? (yes/no): " create_test_project

        if [[ "$create_test_project" == "yes" ]]; then
            # Create a new project folder
            read -p "Enter the project name (default: project_test_1): " project_name
            project_name=${project_name:-project_test_1}  # Set default to 'project_test_1' if empty

            project_path="/home/$username/$folder_name/$project_name"
            sudo -u $username mkdir -p $project_path

            # Create an index.html file with "Hello World"
            echo "Hello World" | sudo tee $project_path/index.html > /dev/null
            sudo chown $username:$username $project_path/index.html

            echo "Test project '$project_name' created with an index.html file."

            # Ask for the domain name for the Nginx configuration
            read -p "Enter the domain name for the Nginx configuration: " domain_name

            # Create the Nginx configuration
            nginx_config_path="/etc/nginx/sites-available/$domain_name"
            sudo tee $nginx_config_path > /dev/null <<EOL
server {
    listen 80;
    server_name $domain_name;

    root $project_path;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOL

            # Enable the site by creating a symlink to sites-enabled
            sudo ln -s $nginx_config_path /etc/nginx/sites-enabled/

            # Test the Nginx configuration for syntax errors
            sudo nginx -t

            # Reload Nginx to apply the new configuration
            sudo systemctl reload nginx

            # Show the domain name with the server IP and guide the user
            server_ip=$(hostname -I | awk '{print $1}')
            echo "The Nginx configuration for '$domain_name' has been created and enabled."
            echo "Please add the following DNS record to your DNS server:"
            echo "A record for '$domain_name' pointing to '$server_ip'."
        else
            echo "Test project and Nginx configuration creation skipped."
        fi

    else
        echo "Project folder creation skipped."
    fi
else
    echo "Project folder creation skipped."
fi
