# Raspberry Rack Setup

This repository contains scripts to set up a Raspberry Pi with an OLED display and configure a static IP address. Follow the instructions below to get started.

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
- Prompts the user to enter the last octet of the desired static IP address.
- Configures the static IP address in the `dhcpcd.conf` file.
- Restarts the networking service to apply the changes.

To run this script, use:
```bash
sudo bash set_fix_ip.sh
```

## Usage

1. Clone this repository to your Raspberry Pi:
```bash
git clone https://github.com/yourusername/RPi_FastSetup.git
cd RPi_FastSetup
```

2. Make the scripts executable:
```bash
chmod +x sys_setup.sh set_fix_ip.sh
```

3. Run the `sys_setup.sh` script to set up the system and OLED display:
```bash
sudo bash sys_setup.sh
```

4. Run the `set_fix_ip.sh` script to configure a static IP address for the Ethernet interface:
```bash
sudo bash set_fix_ip.sh
```

5. Verify that the OLED display service is running:
```bash
sudo systemctl status oled_display.service
```

The Raspberry Pi should now be configured with the OLED display and a static IP address.