#!/bin/bash

# Systemd Service stoppen und deaktivieren
sudo systemctl stop usb-autoplay.service
sudo systemctl disable usb-autoplay.service

# Entferne den systemd Service
sudo rm -f /etc/systemd/system/usb-autoplay.service

# Entferne das Autoplay-Skript
read -p "Bitte geben Sie den Benutzernamen ein, der für die Installation verwendet wurde: " username
autoplay_script_path="/home/$username/usb-vlc-playback.py"
rm -f "$autoplay_script_path"

# Entferne den Mount-Punkt
sudo rm -rf /mnt/usb

# Systemd neu laden
sudo systemctl daemon-reload
sudo systemctl reset-failed

echo "Deinstallation abgeschlossen."
