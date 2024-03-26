#!/bin/bash

# Benutzername für Autologin und Autoplay-Skript
read -p "Bitte geben Sie Ihren Benutzernamen ein: " username

# Python3 und VLC installieren, falls nicht vorhanden
if ! command -v python3 &> /dev/null; then
    echo "Installiere Python3..."
    sudo apt-get update && sudo apt-get install python3 -y
else
    echo "Python3 ist bereits installiert."
fi

if ! command -v vlc &> /dev/null; then
    echo "Installiere VLC Media Player..."
    sudo apt-get install vlc -y
else
    echo "VLC Media Player ist bereits installiert."
fi

# Erstelle den Mount-Punkt mit den richtigen Berechtigungen
sudo mkdir -p /mnt/usb
sudo chown "$username":"$username" /mnt/usb

# Autoplay-Skript erstellen
autoplay_script_path="/home/$username/usb-vlc-playback.py"
cat << 'EOF' > "$autoplay_script_path"
#!/usr/bin/env python3
# Python-Skript Inhalt hier einfügen
EOF

chmod +x "$autoplay_script_path"

# systemd Service-Datei für Autoplay erstellen
service_path="/etc/systemd/system/usb-autoplay.service"
sudo bash -c "cat > $service_path" <<EOF
[Unit]
Description=USB Autoplay Service
After=multi-user.target

[Service]
User=$username
ExecStart=/usr/bin/python3 $autoplay_script_path
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Systemd Service aktivieren und starten
sudo systemctl daemon-reload
sudo systemctl enable usb-autoplay.service
sudo systemctl start usb-autoplay.service

# Autologin für den Benutzer konfigurieren
sudo systemctl set-default multi-user.target
sudo systemctl edit getty@tty1 --full --force <<EOL
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $username --noclear %I \$TERM
EOL

echo "Installation und Autologin-Konfiguration abgeschlossen."
