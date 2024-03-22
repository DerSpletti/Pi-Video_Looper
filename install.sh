#!/bin/bash

# Benutzername abfragen
echo "Bitte geben Sie Ihren Benutzernamen ein:"
read username

# VLC installieren, falls nicht vorhanden
if ! command -v vlc &> /dev/null; then
    echo "VLC Media Player wird installiert..."
    sudo apt-get update
    sudo apt-get install vlc -y
else
    echo "VLC Media Player ist bereits installiert."
fi

# Autoplay-Skript erstellen
AUTOPLAY_SCRIPT_PATH="/home/$username/usb-vlc-playback.sh"
cat << 'EOF' > "$AUTOPLAY_SCRIPT_PATH"
#!/bin/bash

MOUNT_POINT="/mnt/usb"

# Sicherstellen, dass der Mount-Point existiert
mkdir -p "$MOUNT_POINT"

# Loop, um auf das Anstecken von USB-Geräten zu warten und diese automatisch einzuhängen
while true; do
    DEVICE=$(ls /dev/sd[a-z][1-9] 2>/dev/null | head -n 1)
    if [ ! -z "$DEVICE" ] && mount | grep "$DEVICE" > /dev/null; then
        echo "Ein USB-Gerät ist bereits eingehängt."
    elif [ ! -z "$DEVICE" ]; then
        echo "Ein USB-Gerät wurde erkannt. Versuche, es einzuhängen..."
        if sudo mount "$DEVICE" "$MOUNT_POINT"; then
            echo "$DEVICE erfolgreich in $MOUNT_POINT eingehängt."
            DISPLAY=:0 cvlc --fullscreen --loop "$MOUNT_POINT"/* &
            VLC_PID=$!
            wait $VLC_PID
            echo "VLC beendet. USB-Gerät wird ausgehängt..."
            sudo umount "$MOUNT_POINT"
        else
            echo "Konnte $DEVICE nicht in $MOUNT_POINT einhängen."
        fi
    fi
    sleep 5
done
EOF

chmod +x "$AUTOPLAY_SCRIPT_PATH"

# Einrichten des systemd Service für Autologin und Start des Skripts
sudo bash -c "cat > /etc/systemd/system/autologin@.service" <<EOL
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $username --noclear %I \$TERM
Type=idle
EOL

sudo systemctl daemon-reload
sudo systemctl enable autologin@tty1.service

# Hinzufügen des Autoplay-Skripts zur .bashrc für automatische Ausführung
echo "$AUTOPLAY_SCRIPT_PATH" >> /home/$username/.bashrc

echo "Installation abgeschlossen. Der Raspberry Pi wird das Autoplay-Skript beim Booten automatisch ausführen."
