#!/bin/bash

# Function to update the system
update_system() {
    sudo apt update
    sudo apt full-upgrade -y
    if [ $? -ne 0 ]; then
        sudo apt --fix-broken install -y
        sudo apt full-upgrade -y
    fi
}

# Function to set PCIe to Gen3
set_pcie_gen3() {
    sudo raspi-config nonint do_pci_speed 1
    sudo reboot
}

# Function to install Hailo software
install_hailo_software() {
    sudo apt install -y hailo-all
    mkdir -p /home/GitHub_ext
    git clone https://github.com/hailo-ai/hailo-rpi5-examples.git /home/GitHub_ext/hailo-rpi5-examples
    cd /home/GitHub_ext/hailo-rpi5-examples
    sudo chmod +x install.sh
    sudo ./install.sh
}

# Function to verify installation
verify_installation() {
    hailortcli fw-control identify
    gst-inspect-1.0 hailotools
    gst-inspect-1.0 hailo

    if ! gst-inspect-1.0 hailotools &>/dev/null || ! gst-inspect-1.0 hailo &>/dev/null; then
        rm ~/.cache/gstreamer-1.0/registry.aarch64.bin
    fi
}

# Function to upgrade Hailo software
upgrade_hailo() {
    sudo apt update
    sudo apt full-upgrade -y
    sudo apt install -y hailo-all
    
}

# Function to update GitHub repository
update_github_repo() {
    mkdir /home/masterpi/_GitHub/external
    cd /home/masterpi/_GitHub/external
    git pull
}

# Function to downgrade to a previous version
downgrade_hailo() {
    sudo apt install -y hailort=4.17.0 hailo-tappas-core-3.28.2 hailofw=4.17.0-2 hailo-dkms=4.17.0-1
    sudo reboot
}

# Function to handle PCIe troubleshooting
pcie_troubleshooting() {
    lspci | grep Hailo
}

# Function to handle driver issues
driver_issue() {
    uname -a
}

# Function to handle PCIe page size issue
pcie_page_size_issue() {
    cat /etc/modprobe.d/hailo_pci.conf
    echo 'options hailo_pci force_desc_page_size=4096' | sudo tee /etc/modprobe.d/hailo_pci.conf
}

# Function to handle memory allocation issue
memory_allocation_issue() {
    echo 'export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libgomp.so.1' >> ~/.bashrc
    export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libgomp.so.1
    rm ~/.cache/gstreamer-1.0/registry.aarch64.bin
}

# Function to display help
display_help() {
    echo "Usage: $0 {--init|--hailo_setup|--hailo_continue|--downgrade|--pcie_troubleshooting|--driver_issue|--pcie_page_size_issue|--memory_allocation_issue|--help}"
    echo
    echo "Options:"
    echo "  --init                   Initialize the system and set PCIe to Gen3"
    echo "  --hailo_setup            Install Hailo software"
    echo "  --hailo_continue         Continue with verification, upgrading, and troubleshooting"
    echo "  --downgrade              Downgrade to a previous version of Hailo software"
    echo "  --pcie_troubleshooting   Perform PCIe troubleshooting"
    echo "  --driver_issue           Check for driver issues"
    echo "  --pcie_page_size_issue   Fix PCIe page size issue"
    echo "  --memory_allocation_issue Fix memory allocation issue"
    echo "  --help                   Display this help message"
}

# Main script logic
case "$1" in
    --init)
        update_system
        set_pcie_gen3
        ;;
    --hailo_setup)
        install_hailo_software
        ;;
    --hailo_continue)
        verify_installation
        upgrade_hailo
        update_github_repo
        ;;
    --downgrade)
        downgrade_hailo
        ;;
    --pcie_troubleshooting)
        pcie_troubleshooting
        ;;
    --driver_issue)
        driver_issue
        ;;
    --pcie_page_size_issue)
        pcie_page_size_issue
        ;;
    --memory_allocation_issue)
        memory_allocation_issue
        ;;
    --help)
        display_help
        ;;
    *)
        echo "Invalid option: $1"
        display_help
        exit 1
        ;;
esac