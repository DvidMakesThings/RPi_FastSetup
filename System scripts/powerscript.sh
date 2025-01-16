#!/bin/bash

function show_help {
    echo "Usage: current.sh [OPTION]"
    echo "Options:"
    echo "  --help       Show this help message"
    echo "  --maxcurrent Modify settings to allow max current"
    echo "  --monitor    Monitor the system voltage"
}

function max_current {
    # Ask if the power supply is capable of delivering the required current
    read -p "Is your power supply capable of delivering the required current without power-delivery negotiation? (yes/no): " response

    if [[ "$response" == "yes" ]]; then
        # Check if the Raspberry Pi model is Raspberry Pi 5
        pi_model=$(cat /proc/device-tree/model)
        if [[ "$pi_model" == *"Raspberry Pi 5"* ]]; then
            # Modify /boot/firmware/config.txt to allow max current
            echo "Modifying /boot/firmware/config.txt to allow max current..."
            sudo bash -c "echo 'usb_max_current_enable=1' >> /boot/firmware/config.txt"

            # Modify EEPROM to allow max current
            echo "Modifying EEPROM to allow max current..."
            sudo rpi-eeprom-config --out /tmp/boot.conf --config /proc/device-tree/hat/custom_0/boot.conf
            echo "PSU_MAX_CURRENT=5000" | sudo tee -a /tmp/boot.conf
            sudo rpi-eeprom-config --apply /tmp/boot.conf

            echo "Setup complete"
        else
            echo "This setting is only applicable to Raspberry Pi 5. No changes made."
        fi
    else
        # Check if the Raspberry Pi model is Raspberry Pi 5
        pi_model=$(cat /proc/device-tree/model)
        if [[ "$pi_model" == *"Raspberry Pi 5"* ]]; then
            # Modify EEPROM to set default max current
            echo "Modifying EEPROM to set default max current..."
            sudo rpi-eeprom-config --out /tmp/boot.conf --config /proc/device-tree/hat/custom_0/boot.conf
            echo "PSU_MAX_CURRENT=" | sudo tee -a /tmp/boot.conf
            sudo rpi-eeprom-config --apply /tmp/boot.conf

            echo "Setup complete with default max current"
        else
            echo "Power-delivery negotiation is needed or power supply is not capable. No changes made."
        fi
    fi
}

function monitor_voltage {
    echo "Monitoring system voltage. Press ENTER to exit."
    while true; do
        vcgencmd pmic_read_adc EXT5V_V
        sleep 1
        read -t 1 -n 1 key
        if [[ $key = "" ]]; then
            break
        fi
    done
}

case "$1" in
    --help)
        show_help
        ;;
    --maxcurrent)
        max_current
        ;;
    --monitor)
        monitor_voltage
        ;;
    *)
        echo "Invalid option: $1"
        show_help
        ;;
esac