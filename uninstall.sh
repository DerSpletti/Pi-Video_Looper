#!/bin/bash

# Benutzername abfragen
echo "Bitte geben Sie den Benutzernamen ein, der für die Installation verwendet wurde:"
read username

# Entfernen des Autoplay-Skripts
AUTOPLAY_SCRIPT_PATH="/home/$username/usb-vlc-playback.sh"
rm -f "$AUTOPLAY_SCRIPT_PATH"

# Deaktivieren des systemd Service für Autologin
sudo systemctl disable autologin@tty1.service
sudo systemctl daemon-reload

# Entfernen des Autoplay-Skripts aus der .bashrc
sed -i "/usb-vlc-playback.sh/d" /home/$username/.bashrc

echo "Deinstallation abgeschlossen. Die vorgenommenen Änderungen wurden rückgängig gemacht."
