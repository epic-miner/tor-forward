#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Function to install Tor if not installed
install_tor() {
    echo "Checking if Tor is installed..."
    if ! command -v tor >/dev/null 2>&1; then
        echo "Tor not found. Installing Tor..."
        apt update
        apt install tor -y
        echo "Tor installed successfully."
    else
        echo "Tor is already installed."
    fi
}

# Function to configure Tor for port forwarding
configure_tor() {
    echo "Configuring Tor for port forwarding..."
    
    # Backup torrc if not already backed up
    if [ ! -f /etc/tor/torrc.backup ]; then
        echo "Backing up /etc/tor/torrc to /etc/tor/torrc.backup"
        cp /etc/tor/torrc /etc/tor/torrc.backup
    fi
    
    # Hidden Service configuration
    HIDDEN_SERVICE_DIR="/var/lib/tor/hidden_service"
    PORT_TO_FORWARD=8080
    read -p "Enter the port to forward (default 8080): " input_port
    PORT_TO_FORWARD=${input_port:-$PORT_TO_FORWARD}

    echo "HiddenServiceDir $HIDDEN_SERVICE_DIR" >> /etc/tor/torrc
    echo "HiddenServicePort 80 127.0.0.1:$PORT_TO_FORWARD" >> /etc/tor/torrc

    # Restart Tor
    echo "Restarting Tor service to apply changes..."
    service tor restart
}

# Function to display the .onion address
display_onion_address() {
    echo "Fetching the .onion address..."
    if [ -f /var/lib/tor/hidden_service/hostname ]; then
        ONION_ADDRESS=$(cat /var/lib/tor/hidden_service/hostname)
        echo "Your hidden service is available at: $ONION_ADDRESS"
    else
        echo "Error: Could not find the .onion address. Make sure the hidden service is set up correctly."
    fi
}

# Main script execution
install_tor
configure_tor
display_onion_address
