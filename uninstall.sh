#!/bin/bash

# Fordere den Benutzernamen an, der für die Installation verwendet wurde
read -p "Bitte geben Sie den Benutzernamen ein, der für die Installation verwendet wurde: " username

# Stoppen und Deaktivieren des systemd Services
echo "Stoppe und deaktiviere systemd Service für Autoplay..."
sudo systemctl stop usb-autoplay.service
sudo systemctl disable usb-autoplay.service
sudo rm -f /etc/systemd/system/usb-autoplay.service

# systemd Konfiguration neu laden und zurücksetzen
sudo systemctl daemon-reload
sudo systemctl reset-failed

# Entfernen des USB-Autoplay-Skripts
autoplay_script_path="/home/$username/usb-vlc-playback.py"
echo "Entferne das USB-Autoplay-Skript..."
rm -f "$autoplay_script_path"

# Entfernen des Mount-Punktes
echo "Entferne den Mount-Punkt /mnt/usb..."
sudo rm -rf /mnt/usb

# Entfernen der Autologin-Konfiguration
echo "Entferne die Autologin-Konfiguration..."
sudo rm -f /etc/systemd/system/getty@tty1.service.d/override.conf

echo "Deinstallation abgeschlossen. Alle vorgenommenen Änderungen wurden rückgängig gemacht."
