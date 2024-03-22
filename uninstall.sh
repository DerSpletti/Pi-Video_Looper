#!/bin/bash

# Benutzername abfragen
echo "Bitte geben Sie den Benutzernamen ein, der für die Installation verwendet wurde:"
read username

# systemd Service deaktivieren und stoppen
sudo systemctl stop usb-vlc-autoplay.service
sudo systemctl disable usb-vlc-autoplay.service

# systemd Service-Datei entfernen
sudo rm -f /etc/systemd/system/usb-vlc-autoplay.service

# Autoplay-Skript entfernen
rm -f /home/$username/usb-vlc-playback.sh

# systemd Daemon neu laden
sudo systemctl daemon-reload

echo "Deinstallation abgeschlossen. Alle Änderungen wurden rückgängig gemacht."
