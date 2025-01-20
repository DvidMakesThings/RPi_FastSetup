#!/bin/bash

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