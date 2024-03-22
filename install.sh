#!/bin/bash

# Benutzername abfragen
echo "Bitte geben Sie Ihren Benutzernamen ein:"
read username

# Prüfen, ob VLC installiert ist, und falls nicht, installieren
if ! command -v vlc &> /dev/null
then
    echo "VLC Media Player ist nicht installiert. Installation wird gestartet..."
    sudo apt-get update
    sudo apt-get install vlc -y
else
    echo "VLC Media Player ist bereits installiert."
fi

# Einhängepunkt erstellen, falls nicht vorhanden
if [ ! -d "/mnt/usb" ]; then
    echo "Erstelle Einhängepunkt /mnt/usb..."
    sudo mkdir -p /mnt/usb
else
    echo "Einhängepunkt /mnt/usb existiert bereits."
fi

# USB-Autoplay-Skript erstellen
cat << EOF | sudo tee /home/$username/usb-vlc-playback.sh > /dev/null
#!/bin/bash

MOUNT_POINT=/mnt/usb
sleep 5

USB_DEVICES_FOUND=\$(ls /dev/sd[a-z][1-9] 2> /dev/null)
if [ -z "\$USB_DEVICES_FOUND" ]; then
    echo "Kein USB-Stick erkannt."
    exit 1
fi

for DEVICE in \$USB_DEVICES_FOUND; do
    if ! mount | grep \$DEVICE > /dev/null; then
        echo "USB-Stick erkannt. Starte Countdown von 5 Sekunden..."
        for i in {5..1}; do
            echo "\$i..."
            sleep 1
        done
        echo "Versuche, \$DEVICE in \$MOUNT_POINT einzuhängen..."
        mkdir -p \$MOUNT_POINT
        if sudo mount \$DEVICE \$MOUNT_POINT; then
            echo "\$DEVICE erfolgreich in \$MOUNT_POINT eingehängt."
            DISPLAY=:0 cvlc --fullscreen --loop \$MOUNT_POINT/* &
            exit 0
        else
            echo "Konnte \$DEVICE nicht in \$MOUNT_POINT einhängen."
        fi
    fi
done

echo "Kein USB-Stick zum Einhängen verfügbar."
EOF

# Skript ausführbar machen
chmod +x /home/$username/usb-vlc-playback.sh

# udev-Regel hinzufügen
echo 'ACTION=="add", KERNEL=="sd[a-z][0-9]", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", RUN+="/home/'$username'/usb-vlc-playback.sh"' | sudo tee /etc/udev/rules.d/100-usb-autoplay.rules > /dev/null

# udev-Regeln neu laden
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "Installation abgeschlossen. Bitte stecken Sie den USB-Stick an, um die Videowiedergabe zu testen."
