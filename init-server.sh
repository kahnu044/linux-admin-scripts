#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
else
   echo "Congratulations, you have root permissions! We are ready to go."
fi
