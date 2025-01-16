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

# Function to set up port forwarding
setup_port_forwarding() {
    read -p "Enter the external port for SSH (e.g., 2222): " external_port
    internal_ip=$(hostname -I | awk '{print $1}')
    echo "Please configure your router to forward port $external_port to $internal_ip:22"
    read -p "Press [Enter] to continue once you have completed the port forwarding configuration..."
}

# Function to set up Remote Desktop
setup_remote_desktop() {
    echo "Setting up Remote Desktop..."
    sudo apt update
    sudo apt install -y xrdp
    sudo systemctl enable xrdp
    sudo systemctl start xrdp
    echo "Remote Desktop (xrdp) installed and started. You can now connect using an RDP client."
}

# Check and install dhcpcd if necessary
check_and_install_dhcpcd

# Retrieve the router IP address
router_ip=$(ip r | grep default | awk '{print $3}')
echo "Router IP: $router_ip"

# Retrieve the current DNS server IP address
dns_ip=$(grep "nameserver" /etc/resolv.conf | awk '{print $2}')
echo "DNS Server IP: $dns_ip"

# Prompt user for static IP address for eth0
read -p "Enter the static IP address you want to assign to eth0: " eth0_ip

# Backup the current dhcpcd.conf file
sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.bak

# Add static IP configuration for eth0 to dhcpcd.conf
echo "interface eth0" | sudo tee -a /etc/dhcpcd.conf
echo "static ip_address=$eth0_ip/24" | sudo tee -a /etc/dhcpcd.conf
echo "static routers=$router_ip" | sudo tee -a /etc/dhcpcd.conf
echo "static domain_name_servers=$dns_ip" | sudo tee -a /etc/dhcpcd.conf

# Clear old DHCP leases
echo "Clearing old DHCP leases..."
sudo rm -f /var/lib/dhcpcd5/*

# Restart dhcpcd to apply changes
echo "Restarting dhcpcd service..."
sudo systemctl restart dhcpcd

# Set up port forwarding
setup_port_forwarding

# Set up Remote Desktop
setup_remote_desktop

read -p "Press [Enter] to reboot the Raspberry Pi and apply changes..."

# Restart the Raspberry Pi to apply changes
echo "Rebooting to apply changes..."
sudo reboot now
