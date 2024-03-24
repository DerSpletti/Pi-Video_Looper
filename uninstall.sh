#!/bin/bash

# Benutzername abfragen, der für die Installation verwendet wurde
read -p "Bitte geben Sie den Benutzernamen ein, der für die Installation verwendet wurde: " username

# Stoppe und deaktiviere den systemd Service für Autoplay
sudo systemctl stop usb-autoplay.service
sudo systemctl disable usb-autoplay.service

# Entferne den systemd Service für Autoplay
sudo rm -f /etc/systemd/system/usb-autoplay.service

# Entferne das Autoplay-Skript
autoplay_script_path="/home/$username/usb-vlc-playback.py"
rm -f "$autoplay_script_path"

# Entferne die Autologin-Konfiguration
sudo rm -f /etc/systemd/system/getty@tty1.service.d/override.conf

# Setze das Standard-Target zurück, falls notwendig
# sudo systemctl set-default graphical.target # Nur ausführen, wenn das Standard-Target geändert wurde

# Lade die systemd Konfiguration neu
sudo systemctl daemon-reload
sudo systemctl reset-failed

echo "Deinstallation abgeschlossen. Alle Änderungen wurden rückgängig gemacht."
