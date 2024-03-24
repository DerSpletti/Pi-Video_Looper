#!/bin/bash

# Benutzername für Autologin und Autoplay-Skript
echo "Bitte geben Sie Ihren Benutzernamen ein:"
read username

# Installiere Python3 und VLC, falls nicht vorhanden
if ! command -v python3 &> /dev/null; then
    echo "Installiere Python3..."
    sudo apt-get update
    sudo apt-get install python3 -y
else
    echo "Python3 ist bereits installiert."
fi

if ! command -v vlc &> /dev/null; then
    echo "Installiere VLC Media Player..."
    sudo apt-get install vlc -y
else
    echo "VLC Media Player ist bereits installiert."
fi

# Erstelle das Mount-Verzeichnis und setze die Besitzrechte
sudo mkdir -p /mnt/usb
sudo chown $username:$username /mnt/usb

# Erstelle das Autoplay-Skript
autoplay_script_path="/home/$username/usb-vlc-playback.py"
cat << 'EOF' > "$autoplay_script_path"
#!/usr/bin/env python3
import os
import subprocess
import time

MOUNT_POINT = "/mnt/usb"
if not os.path.exists(MOUNT_POINT):
    os.makedirs(MOUNT_POINT)

def find_usb_device():
    for dev in os.listdir('/dev'):
        if dev.startswith('sd'):
            dev_path = f"/dev/{dev}"
            if not any(dev_path in line for line in subprocess.run(['mount'], capture_output=True, text=True).stdout.splitlines()):
                return dev_path
    return None

def mount_device(device):
    result = subprocess.run(['sudo', 'mount', device, MOUNT_POINT])
    return result.returncode == 0

def umount_device():
    subprocess.run(['sudo', 'umount', MOUNT_POINT])

def play_media():
    subprocess.Popen(['cvlc', '--fullscreen', '--loop', f"{MOUNT_POINT}/*"], shell=False)

while True:
    device = find_usb_device()
    if device and mount_device(device):
        print(f"Gerät {device} eingehängt. Starte Wiedergabe...")
        play_media()
        while os.path.exists(device):
            time.sleep(1)
        umount_device()
    time.sleep(5)
EOF
chmod +x "$autoplay_script_path"

# Systemd Service-Datei für Autoplay erstellen
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

echo "Installation abgeschlossen. Der Raspberry Pi wird das Autoplay-Skript beim Booten automatisch ausführen."
