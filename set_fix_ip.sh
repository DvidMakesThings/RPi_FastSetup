#!/bin/bash

# Function to check and install dhcpcd
check_and_install_dhcpcd() {
    echo "Checking if dhcpcd is installed..."
    if ! command -v dhcpcd &> /dev/null; then
        echo "dhcpcd not found. Installing it now..."
        sudo apt update
        sudo apt install -y dhcpcd5
        sudo systemctl enable dhcpcd
        sudo systemctl start dhcpcd
        echo "dhcpcd installed and started."
    else
        echo "dhcpcd is already installed."
    fi
}

# Function to set a static IP for eth0
set_static_ip_eth0() {
    local ip_base="192.168.0."

    echo "Enter the full IP for eth0: ${ip_base}[last octet]"
    read -p "Last octet (e.g., 10): " last_octet

    # Validate last octet
    if ! [[ "$last_octet" =~ ^[0-9]+$ ]] || [ "$last_octet" -lt 1 ] || [ "$last_octet" -gt 254 ]; then
        echo "Invalid last octet. Please enter a number between 1 and 254."
        exit 1
    fi

    # Full IP address
    ip_address="${ip_base}${last_octet}/24"

    # Add to dhcpcd.conf
    echo "Configuring static IP for eth0..."
    sudo bash -c "cat > /etc/dhcpcd.conf <<EOF
interface eth0
static ip_address=$ip_address
static routers=${ip_base}1
static domain_name_servers=8.8.8.8
nohook dhcp
EOF"

    echo "Static IP for eth0 set to $ip_address"
}

# Start script
echo "Setting up static IP for eth0..."

# Check and install dhcpcd if necessary
check_and_install_dhcpcd

# Configure Ethernet (eth0)
set_static_ip_eth0

# Restart networking
echo "Restarting networking service..."
sudo systemctl restart dhcpcd

echo "Static IP configuration complete!"
