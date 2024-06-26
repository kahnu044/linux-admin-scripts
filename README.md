# Linux Server Setup Script

This repository contains a shell script to set up a Linux server with necessary configurations, user accounts, and packages. The script is designed to automate the initial setup and configuration of a new server.

## Features

- Checks if the script is run as root
- Updates package lists
- Installs specified packages
- Adds new users and assigns them to the sudo group
- Configures system settings

## Getting Started

### Prerequisites

- A Linux server
- Root or sudo access

### Usage

1. **Clone the repository:**

    ```bash
    git clone https://github.com/kahnu044/linux-server-setup-scripts
    cd linux-server-setup-scripts
    ```

2. **Make the script executable:**

    ```bash
    chmod +x init-server.sh
    ```

3. **Run the script with root privileges:**

    ```bash
    sudo ./init-server.sh
    ```

### Step-by-Step Process

The script is designed to be modular. Here are the steps included:

1. **Check for root privileges**
2. **System update**
3. **Web server installation**
4. **Checking web server status**
5. **Adding a new user**
6. **Creating project folder**
7. **Creating a test project and Nginx configuration**