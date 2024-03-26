#!/bin/bash

# Systemd Service für das Autoplay stoppen und deaktivieren
sudo systemctl stop usb-autoplay.service
sudo systemctl disable usb-autoplay.service

# systemd Service-Datei entfernen
sudo rm -f /etc/systemd/system/usb-autoplay.service

# systemd Konfiguration neu laden
sudo systemctl daemon-reload
sudo systemctl reset-failed

# Fordere Benutzernamen an, der für die Installation verwendet wurde
read -p "Bitte geben Sie den Benutzernamen ein, der für die Installation verwendet wurde: " username

# Entferne das Autoplay-Skript
autoplay_script_path="/home/$username/usb-vlc-playback.py"
rm -f "$autoplay_script_path"

# Entferne den Mount-Punkt
sudo rm -rf /mnt/usb

# Entferne die Autologin-Konfiguration, wenn sie über eine override.conf Datei konfiguriert wurde
if [ -d "/etc/systemd/system/getty@tty1.service.d" ]; then
    sudo rm -f /etc/systemd/system/getty@tty1.service.d/override.conf
fi

# Optional: Setze systemd Target zurück, wenn es während der Installation geändert wurde
# sudo systemctl set-default graphical.target

echo "Deinstallation abgeschlossen. Alle vorgenommenen Änderungen wurden rückgängig gemacht."
