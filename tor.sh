#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit
fi

# Update package list and install Tor
echo "Updating package list and installing Tor..."
sudo apt update && sudo apt install tor -y

# Tor configuration file path
TORRC_FILE="/etc/tor/torrc"

# Hidden service directory path
HIDDEN_SERVICE_DIR="/var/lib/tor/hidden_service"

# Create backup of the original torrc file
if [ ! -f "$TORRC_FILE.bak" ]; then
  echo "Creating backup of torrc file..."
  sudo cp $TORRC_FILE $TORRC_FILE.bak
fi

# Add hidden service configuration to torrc
echo "Configuring hidden service for port 8080..."
sudo bash -c "cat <<EOT >> $TORRC_FILE
# Hidden Service for forwarding port 8080
HiddenServiceDir $HIDDEN_SERVICE_DIR/
HiddenServicePort 80 127.0.0.1:8080
EOT"

# Restart Tor service
echo "Restarting Tor service..."
sudo systemctl restart tor

# Display the .onion address
if [ -f "$HIDDEN_SERVICE_DIR/hostname" ]; then
  echo "Tor Hidden Service is set up. Your .onion address is:"
  sudo cat $HIDDEN_SERVICE_DIR/hostname
else
  echo "Error: Tor hidden service directory not found!"
fi
