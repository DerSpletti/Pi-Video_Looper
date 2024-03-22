#!/bin/bash

# Benutzername abfragen
echo "Bitte geben Sie Ihren Benutzernamen ein:"
read username

# Prüfen, ob VLC installiert ist, und falls nicht, installieren
if ! command -v vlc &> /dev/null; then
    echo "VLC Media Player ist nicht installiert. Installation wird gestartet..."
    sudo apt-get update
    sudo apt-get install vlc -y
else
    echo "VLC Media Player ist bereits installiert."
fi

# Autoplay-Skript erstellen
AUTOPLAY_SCRIPT="/home/$username/usb-vlc-playback.sh"
cat << 'EOF' > "$AUTOPLAY_SCRIPT"
#!/bin/bash

MOUNT_POINT=/mnt/usb

# Warte, bis ein USB-Gerät verbunden wird
until ls /dev/sd[a-z][1-9] 2> /dev/null; do sleep 1; done

echo "USB-Stick erkannt. Starte in 5 Sekunden..."
sleep 5

# Versuche, das erste verfügbare USB-Speichergerät einzuhängen
DEVICE=$(ls /dev/sd[a-z][1-9] 2> /dev/null | head -n 1)
sudo mount $DEVICE $MOUNT_POINT

# Starte VLC für alle Videos auf dem USB-Stick
DISPLAY=:0 cvlc --fullscreen --loop $MOUNT_POINT/* &

VLC_PID=$!

# Warte, bis der USB-Stick entfernt wird
while ls /dev/sd[a-z][1-9] | grep -q $(basename $DEVICE); do sleep 1; done

echo "USB-Stick entfernt. Beende VLC."
sudo umount $MOUNT_POINT
kill $VLC_PID
EOF

chmod +x "$AUTOPLAY_SCRIPT"

# systemd Service-Datei erstellen
SERVICE_FILE="/etc/systemd/system/usb-vlc-autoplay.service"
cat << EOF | sudo tee "$SERVICE_FILE" > /dev/null
[Unit]
Description=USB VLC Autoplay Service
After=multi-user.target

[Service]
User=$username
Type=simple
ExecStart=/bin/bash $AUTOPLAY_SCRIPT

[Install]
WantedBy=multi-user.target
EOF

# systemd Service aktivieren und starten
sudo systemctl enable usb-vlc-autoplay.service
sudo systemctl start usb-vlc-autoplay.service

echo "Installation und Service-Einrichtung abgeschlossen."
