#!/bin/bash

echo "Bitte geben Sie den Benutzernamen ein, der für die Installation verwendet wurde:"
read username

# Entfernen der udev-Regel
sudo rm -f /etc/udev/rules.d/100-usb-autoplay.rules

# Entfernen des Autoplay-Skripts
rm -f /home/$username/usb-vlc-playback.sh

# udev-Regeln neu laden
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "Deinstallation abgeschlossen. Die Änderungen wurden rückgängig gemacht."
