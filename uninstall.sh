#!/bin/bash

# Stoppen und Deaktivieren des systemd Service
echo "Stoppe und deaktiviere systemd Service für Autoplay..."
sudo systemctl stop usb-autoplay.service
sudo systemctl disable usb-autoplay.service
sudo rm /etc/systemd/system/usb-autoplay.service

# Entfernen des Autoplay-Skripts
echo "Entferne USB-Autoplay-Skript..."
read -p "Bitte geben Sie den Benutzernamen ein, der für die Installation verwendet wurde: " username
autoplay_script_path="/home/$username/usb-vlc-playback.py"
rm -f "$autoplay_script_path"

# Entfernen des Mount-Punktes
echo "Entferne Mount-Punkt..."
sudo rm -rf /mnt/usb

# Entfernen der Autologin-Konfiguration
echo "Entferne Autologin-Konfiguration..."
sudo rm -rf /etc/systemd/system/getty@tty1.service.d

sudo systemctl daemon-reload
sudo systemctl reset-failed

echo "Deinstallation abgeschlossen. Alle vorgenommenen Änderungen wurden rückgängig gemacht."
