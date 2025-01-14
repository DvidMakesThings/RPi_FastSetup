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

# Calculate the static IP address for wlan0 (eth0 + 5)
IFS='.' read -r -a ip_array <<< "$eth0_ip"
wlan0_ip="${ip_array[0]}.${ip_array[1]}.${ip_array[2]}.$((ip_array[3] + 5))"
echo "Calculated static IP address for wlan0: $wlan0_ip"

# Backup the current dhcpcd.conf file
sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.bak

# Add static IP configuration for eth0 to dhcpcd.conf
echo "interface eth0" | sudo tee -a /etc/dhcpcd.conf
echo "static ip_address=$eth0_ip/24" | sudo tee -a /etc/dhcpcd.conf
echo "static routers=$router_ip" | sudo tee -a /etc/dhcpcd.conf
echo "static domain_name_servers=$dns_ip" | sudo tee -a /etc/dhcpcd.conf

# Add static IP configuration for wlan0 to dhcpcd.conf
echo "interface wlan0" | sudo tee -a /etc/dhcpcd.conf
echo "static ip_address=$wlan0_ip/24" | sudo tee -a /etc/dhcpcd.conf
echo "static routers=$router_ip" | sudo tee -a /etc/dhcpcd.conf
echo "static domain_name_servers=$dns_ip" | sudo tee -a /etc/dhcpcd.conf

# Restart the Raspberry Pi to apply changes
echo "Rebooting to apply changes..."
sudo reboot

# Wait for the system to reboot
sleep 60

# Verify the static IP addresses
echo "Verifying the static IP addresses..."
hostname -I

echo "Static IP setup complete."