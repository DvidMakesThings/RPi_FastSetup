#!/bin/bash
 
# Modify /boot/firmware/config.txt to allow max current
echo "Modifying /boot/firmware/config.txt to allow max current..."
sudo bash -c "echo 'usb_max_current_enable=1' >> /boot/firmware/config.txt"

# Modify EEPROM to allow max current
echo "Modifying EEPROM to allow max current..."
sudo rpi-eeprom-config --out /tmp/boot.conf --config /proc/device-tree/hat/custom_0/boot.conf
echo "PSU_MAX_CURRENT=5000" | sudo tee -a /tmp/boot.conf
sudo rpi-eeprom-config --apply /tmp/boot.conf

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