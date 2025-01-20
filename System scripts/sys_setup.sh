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

# Reboot to apply changes
echo "Rebooting to apply changes..."
sudo reboot