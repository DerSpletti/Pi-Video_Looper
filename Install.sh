#!/bin/bash

echo "Bitte geben Sie Ihren Benutzernamen ein:"
read username

# Erstelle die udev-Regel
echo 'ACTION=="add", KERNEL=="sd[a-z][0-9]", SUBSYSTEM=="block", RUN+="/home/$username/usb-vlc-playback.sh"' | sudo tee /etc/udev/rules.d/100-usb-autoplay.rules

# Berechtigungen für VLC festlegen
sudo usermod -a -G video $username

# Skript zum Abspielen der Videos von USB mit VLC erstellen
cat << 'EOF' > /home/$username/usb-vlc-playback.sh
#!/bin/bash

# Der Pfad, an dem der USB-Stick eingehängt wird
MOUNT_POINT=/mnt/usb

# Warte kurz, um sicherzustellen, dass der USB-Stick eingehängt wurde
sleep 5

# Erstelle den Mount-Punkt, falls er noch nicht existiert
mkdir -p $MOUNT_POINT

# Finde die Device-Bezeichnung des USB-Sticks (z.B. /dev/sda1)
DEVICE=$(lsblk -o NAME,LABEL | grep 'USB_LABEL' | awk '{print $1}')
if [ ! -z "$DEVICE" ]; then
    DEVICE="/dev/$DEVICE"
    # Einhängen des USB-Sticks
    mount $DEVICE $MOUNT_POINT

    # Starte VLC in einer Endlosschleife für alle Videos auf dem USB-Stick
    cvlc --fullscreen --loop $MOUNT_POINT/* &

    # Optional: Aushängen des USB-Sticks, nachdem VLC beendet wurde
    # umount $MOUNT_POINT
fi
EOF

# Mache das Skript ausführbar
chmod +x /home/$username/usb-vlc-playback.sh

# udev-Regeln neu laden
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "Installation abgeschlossen. Bitte stecken Sie den USB-Stick an, um die Videowiedergabe zu testen."
