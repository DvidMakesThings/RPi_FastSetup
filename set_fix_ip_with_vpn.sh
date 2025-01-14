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
}

# Function to set up Dynamic DNS
setup_dynamic_dns() {
    echo "Setting up Dynamic DNS..."
    echo "Please sign up for a Dynamic DNS service (e.g., No-IP, DynDNS) and follow their instructions to set it up on your router."
}

# Function to set up VPN
setup_vpn() {
    echo "Setting up VPN..."
    echo "Please follow the instructions to set up OpenVPN on your Raspberry Pi: https://pimylifeup.com/raspberry-pi-vpn-server/"
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

# Set up port forwarding
setup_port_forwarding

# Set up Dynamic DNS
setup_dynamic_dns

# Set up VPN
setup_vpn

# Set up Remote Desktop
setup_remote_desktop

# Restart the Raspberry Pi to apply changes
echo "Rebooting to apply changes..."
sudo reboot now
