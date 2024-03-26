#!/bin/bash

echo "Bitte geben Sie Ihren Benutzernamen ein: "
read username

# Überprüfen und Installieren von Python3 und VLC
echo "Überprüfe und installiere Python3 und VLC..."
sudo apt-get update
sudo apt-get install -y python3 vlc

# Erstellen des Mount-Punktes
echo "Erstelle Mount-Punkt..."
sudo mkdir -p /mnt/usb
sudo chown "$username":"$username" /mnt/usb

# Erstellen und Konfigurieren des Autoplay-Skripts
echo "Erstelle USB-Autoplay-Skript..."
autoplay_script_path="/home/$username/usb-vlc-playback.py"
cat << 'EOF' > "$autoplay_script_path"
#!/usr/bin/env python3
# Python-Skript Inhalt hier einfügen
EOF
chmod +x "$autoplay_script_path"

# Erstellen und Aktivieren des systemd Service
echo "Konfiguriere systemd Service für Autoplay..."
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
sudo systemctl daemon-reload
sudo systemctl enable usb-autoplay.service
sudo systemctl start usb-autoplay.service

# Konfigurieren des Autologins
echo "Konfiguriere Autologin..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin $username --noclear %I \$TERM" | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null
sudo systemctl daemon-reload

echo "Installation und Autologin-Konfiguration abgeschlossen."
