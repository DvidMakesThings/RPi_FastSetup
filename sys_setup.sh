#!/bin/bash

# Update and upgrade system
echo "Updating and upgrading system..."
sudo apt update && sudo apt full-upgrade -y
sudo apt update
sudo apt upgrade -y

# Install build tools and dependencies for Python
echo "Installing build tools and dependencies..."
sudo apt install -y build-essential libssl-dev libffi-dev zlib1g-dev libsqlite3-dev libbz2-dev libreadline-dev libncurses5-dev libgdbm-dev libnss3-dev liblzma-dev uuid-dev wget

# Download and install Python 3.12.3
echo "Downloading and installing Python 3.12.3..."
cd /usr/src
sudo wget https://www.python.org/ftp/python/3.12.3/Python-3.12.3.tgz
sudo tar xzf Python-3.12.3.tgz
cd Python-3.12.3
sudo ./configure --enable-optimizations
sudo make -j$(nproc)
sudo make altinstall
python3.12 --version

# Install Git
echo "Installing Git..."
sudo apt install -y git
git --version

# Install required system packages for OLED
echo "Installing OLED-related system packages..."
sudo apt install -y python3-dev python3-pip python3-numpy libfreetype6-dev libjpeg-dev build-essential
sudo apt install -y libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev libportmidi-dev
sudo apt install -y python3-luma.oled

# Install Python virtual environment package
echo "Installing Python virtual environment package..."
sudo apt install -y python3-venv

# Clone the luma.examples repository to /opt/luma
echo "Cloning luma.examples repository..."
sudo mkdir -p /opt/luma
sudo chown $USER:$USER /opt/luma
cd /opt/luma
git clone https://github.com/rm-hull/luma.examples.git
cd luma.examples

# Create the systemd service file
echo "Creating systemd service..."
SERVICE_FILE="/etc/systemd/system/oled_display.service"

sudo bash -c "cat > $SERVICE_FILE <<EOF
[Unit]
Description=OLED Display Service
After=multi-user.target

[Service]
ExecStart=/usr/bin/python3 /opt/luma/luma.examples/examples/sys_info_extended.py
WorkingDirectory=/opt/luma/luma.examples/examples
Restart=always
User=$USER
Group=$USER

[Install]
WantedBy=multi-user.target
EOF"

# Reload systemd to recognize the new service
echo "Reloading systemd..."
sudo systemctl daemon-reload

# Enable and start the service
echo "Enabling and starting the OLED display service..."
sudo systemctl enable oled_display.service
sudo systemctl start oled_display.service

# Check the status of the service
echo "Checking the status of the OLED display service..."
sudo systemctl status oled_display.service

# Enable SSH
echo "Enabling SSH..."
sudo systemctl enable ssh
sudo systemctl start ssh

# Enable VNC
echo "Enabling VNC..."
sudo raspi-config nonint do_vnc 0

# Enable SPI
echo "Enabling SPI..."
sudo raspi-config nonint do_spi 0

# Enable I2C
echo "Enabling I2C..."
sudo raspi-config nonint do_i2c 0

# Enable Serial Port
echo "Enabling Serial Port..."
sudo raspi-config nonint do_serial 0

# Enable Serial Console
echo "Enabling Serial Console..."
sudo raspi-config nonint do_serial 1

# Enable 1-Wire
echo "Enabling 1-Wire..."
sudo raspi-config nonint do_onewire 0

# Modify /boot/firmware/config.txt to allow max current
echo "Modifying /boot/firmware/config.txt to allow max current..."
sudo bash -c "echo 'usb_max_current_enable=1' >> /boot/firmware/config.txt"

# Modify EEPROM to allow max current
echo "Modifying EEPROM to allow max current..."
sudo -E rpi-eeprom-config --edit <<EOF
PSU_MAX_CURRENT=5000
EOF

echo "Setup complete. The OLED display script and required interfaces are now enabled!"

# Countdown timer in the background
(
    for i in {20..1}
    do
        echo -ne "Rebooting in $i seconds...\r"
        sleep 1
    done
    echo -ne "\n"
    sudo reboot
) &

# Prompt to press a button to reboot
read -p "Press any key to reboot immediately or wait for the countdown to finish..." -n1 -s

# Reboot to apply changes
echo "Rebooting to apply changes..."
sudo reboot