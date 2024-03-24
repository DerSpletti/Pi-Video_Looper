#!/bin/bash

# Benutzername abfragen
read -p "Bitte geben Sie den Benutzernamen ein, der für die Installation verwendet wurde: " username

# Systemd Service stoppen und deaktivieren
sudo systemctl stop usb-vlc-autoplay.service
sudo systemctl disable usb-vlc-autoplay.service

# systemd Service-Datei entfernen
sudo rm -f /etc/systemd/system/usb-vlc-autoplay.service

# Autoplay-Skript entfernen
autoplay_script_path="/home/$username/usb-vlc-playback.py"
rm -f "$autoplay_script_path"

# Systemd neu laden, um Änderungen zu übernehmen
sudo systemctl daemon-reload
sudo systemctl reset-failed

echo "Deinstallation abgeschlossen. Die Änderungen wurden rückgängig gemacht."
