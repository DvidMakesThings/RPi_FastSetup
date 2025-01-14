# Raspberry Rack Setup

This repository contains scripts to set up a Raspberry Pi with an OLED display, configure a static IP address, set up a VPN, and install Hailo software. Follow the instructions below to get started.

## Files

### sys_setup.sh

This script performs the following tasks:
- Updates and upgrades the system packages.
- Installs build tools and dependencies for Python.
- Downloads and installs Python 3.12.3.
- Installs Git.
- Installs required system packages for the OLED display.
- Installs the Python virtual environment package.
- Clones the `luma.examples` repository to `/opt/luma`.
- Creates a systemd service to run the OLED display script.
- Enables and starts the OLED display service.
- Enables SSH, VNC, SPI, I2C, Serial Port, Serial Console, and 1-Wire interfaces.

To run this script, use:
```bash
sudo bash sys_setup.sh
```

### set_fix_ip.sh

This script sets a static IP address for the Ethernet interface (eth0). It performs the following tasks:
- Checks if `dhcpcd` is installed and installs it if necessary.
- Prompts the user to enter the static IP address for eth0.
- Calculates the static IP address for wlan0 (eth0 + 5).
- Configures the static IP addresses in the `dhcpcd.conf` file.
- Restarts the Raspberry Pi to apply the changes.

To run this script, use:
```bash
sudo bash set_fix_ip.sh
```

### set_fix_ip_with_vpn.sh

This script sets a static IP address for the Ethernet interface (eth0) and sets up a VPN. It performs the following tasks:
- Checks if `dhcpcd` is installed and installs it if necessary.
- Prompts the user to enter the static IP address for eth0.
- Calculates the static IP address for wlan0 (eth0 + 5).
- Configures the static IP addresses in the `dhcpcd.conf` file.
- Sets up port forwarding.
- Sets up Dynamic DNS.
- Sets up VPN.
- Sets up Remote Desktop.
- Restarts the Raspberry Pi to apply the changes.

To run this script, use:
```bash
sudo bash set_fix_ip_with_vpn.sh
```

### setup_hailo.sh

This script installs and configures Hailo software. It performs the following tasks:
- Updates and upgrades the system packages.
- Sets PCIe to Gen3.
- Installs Hailo software.
- Verifies the installation.
- Upgrades Hailo software.
- Updates the GitHub repository.
- Downgrades to a previous version of Hailo software.
- Performs PCIe troubleshooting.
- Checks for driver issues.
- Fixes PCIe page size issue.
- Fixes memory allocation issue.

To run this script, use:
```bash
sudo bash setup_hailo.sh --option
```
Replace `--option` with one of the following:
- `--init`
- `--hailo_setup`
- `--hailo_continue`
- `--downgrade`
- `--pcie_troubleshooting`
- `--driver_issue`
- `--pcie_page_size_issue`
- `--memory_allocation_issue`
- `--help`

### setup_pcie_hat.sh

This script sets up the PCIe interface and NVME power monitoring. It performs the following tasks:
- Enables PCIe Interface.
- Sets up NVME Power Monitoring.
- Checks if the SSD is recognized.
- Partitions the SSD.
- Formats the SSD to ext4 file format.
- Creates a mount directory and mounts the device.
- Performs a read/write test.
- Sets up auto-mounting.
- Sets up booting from NVMe SSD.
- Reboots the system to apply changes.

To run this script, use:
```bash
sudo bash setup_pcie_hat.sh --option
```
Replace `--option` with one of the following:
- `--setup_pciehat`
- `--setup_pwr_monitor`
- `--help`

## Usage

1. Clone this repository to your Raspberry Pi:
```bash
git clone https://github.com/DvidMakesThings/RPi_FastSetup.git
cd RPi_FastSetup
```

2. Make the scripts executable:
```bash
chmod +x sys_setup.sh set_fix_ip.sh set_fix_ip_with_vpn.sh setup_hailo.sh setup_pcie_hat.sh
```

3. Run the `sys_setup.sh` script to set up the system and OLED display:
```bash
sudo bash sys_setup.sh
```

4. Run the `set_fix_ip.sh` script to configure a static IP address for the Ethernet interface:
```bash
sudo bash set_fix_ip.sh
```

5. (Optional) Run the `set_fix_ip_with_vpn.sh` script to configure a static IP address and set up a VPN:
```bash
sudo bash set_fix_ip_with_vpn.sh
```

6. (Optional) Run the `setup_hailo.sh` script to install and configure Hailo software:
```bash
sudo bash setup_hailo.sh --option
```

7. (Optional) Run the `setup_pcie_hat.sh` script to set up the PCIe interface and NVME power monitoring:
```bash
sudo bash setup_pcie_hat.sh --option
```

8. Verify that the OLED display service is running:
```bash
sudo systemctl status oled_display.service
```

The Raspberry Pi should now be configured with the OLED display, a static IP address, VPN, and Hailo software.