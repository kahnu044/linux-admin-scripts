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

1. **Check for root privileges:**

    ```bash
    #!/bin/bash

    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root"
        exit 1
    else
        echo "Congratulations, you have root permissions! We are ready to go."
    fi
    ```

    More steps will be added sequentially.