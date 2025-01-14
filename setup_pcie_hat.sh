#!/bin/bash

# Enable PCIe Interface
echo "Enabling PCIe Interface..."
if ! grep -q "dtparam=pciex1" /boot/firmware/config.txt; then
    echo "dtparam=pciex1" | sudo tee -a /boot/firmware/config.txt
fi

# Reboot to apply changes
echo "Rebooting to apply changes..."
sudo reboot

# Wait for the system to reboot
sleep 60

# Check if the SSD is recognized
echo "Checking if the SSD is recognized..."
lsblk

# Partition the SSD
echo "Partitioning the SSD..."
sudo fdisk /dev/nvme0n1 <<EOF
n
p
1


w
EOF

# Format the SSD to ext4 file format
echo "Formatting the SSD to ext4 file format..."
sudo mkfs.ext4 /dev/nvme0n1p1

# Create Mount Directory and Mount the device
echo "Creating mount directory and mounting the device..."
sudo mkdir -p /home/pi/toshiba
sudo mount /dev/nvme0n1p1 /home/pi/toshiba

# Check disk status
echo "Checking disk status..."
df -h

# Read/Write Test
echo "Performing read/write test..."
cd /home/pi/toshiba
sudo sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"
sudo dd if=/dev/zero of=./test_write count=2000 bs=1024k
sudo dd if=./test_write of=/dev/null count=2000 bs=1024k

# Auto-mounting setup
echo "Setting up auto-mounting..."
echo "/dev/nvme0n1p1  /home/pi/toshiba  ext4  defaults  0  0" | sudo tee -a /etc/fstab
sudo mount -a

# Booting from NVMe SSD setup
echo "Setting up booting from NVMe SSD..."
sudo rpi-eeprom-config --edit <<EOF
NVME_CONTROLLER=1
BOOT_ORDER=0xf416
EOF

# Reboot to apply changes
echo "Rebooting to apply changes..."
sudo reboot

# Wait for the system to reboot
sleep 60

# Check the device through lsblk
echo "Checking the device through lsblk..."
lsblk

# NVME Power Monitoring setup
echo "Setting up NVME Power Monitoring..."
wget https://files.waveshare.com/upload/0/06/PCIE_HAT_INA219.zip
unzip -o PCIE_HAT_INA219.zip -d ./PCIE_HAT_INA219
cd PCIE_HAT_INA219
sudo python INA219.py

echo "Installation and setup complete."
