#!/bin/bash

# Stoppen und Deaktivieren des systemd Services
echo "Stoppe und deaktiviere systemd Service für Autoplay..."
sudo systemctl stop usb-autoplay.service
sudo systemctl disable usb-autoplay.service
sudo rm /etc/systemd/system/usb-autoplay.service

# Entfernen des USB-Autoplay-Skripts
echo "Bitte geben Sie den Benutzernamen ein, der für die Installation verwendet wurde: "
read username
autoplay_script_path="/home/$username/usb-vlc-playback.py"
rm -f "$autoplay_script_path"

# Entfernen des Mount-Punktes
echo
