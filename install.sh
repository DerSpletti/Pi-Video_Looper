#!/bin/bash

# Benutzerinformationen abfragen
echo "Bitte geben Sie Ihren Benutzernamen ein: "
read username

# Prüfen und Installieren von Abhängigkeiten: Python3 und VLC
echo "Überprüfe und installiere notwendige Pakete (Python3 und VLC)..."
sudo apt-get update
sudo apt-get install -y python3 vlc

# Erstellen des Mount-Punktes mit den entsprechenden Berechtigungen
echo "Erstelle Mount-Punkt /mnt/usb..."
sudo mkdir -p /mnt/usb
sudo chown "$username":"$username" /mnt/usb

# Erstellen und Konfigurieren des USB-Autoplay-Skripts
echo "Erstelle das USB-Autoplay-Skript..."
autoplay_script_path="/home/$username/usb-vlc-playback.py"
cat << 'EOF' > "$autoplay_script_path"
#!/usr/bin/env python3
import os
import subprocess
import time

MOUNT_POINT = "/mnt/usb"
VLC_PATH = subprocess.getoutput('which cvlc')

def find_usb_device():
    for device in os.listdir('/dev'):
        if device.startswith('sd') and device[-1].isdigit():
            yield os.path.join('/dev', device)

def mount_device(device):
    if not os.path.exists(MOUNT_POINT):
        os.makedirs(MOUNT_POINT)
    subprocess.run(['sudo', 'mount', device, MOUNT_POINT], check=True)

def umount_device():
    subprocess.run(['sudo', 'umount', MOUNT_POINT], check=True)
    if os.path.exists(MOUNT_POINT):
        os.rmdir(MOUNT_POINT)

def play_media():
    media_files = [os.path.join(MOUNT_POINT, f) for f in os.listdir(MOUNT_POINT) if os.path.isfile(os.path.join(MOUNT_POINT, f))]
    if media_files:
        command = [VLC_PATH, '--fullscreen', '--loop',  '--no-video-title-show'] + media_files
        subprocess.Popen(command)
    else:
        print("No media files found on the USB device.")

while True:
    devices = list(find_usb_device())
    if devices:
        for device in devices:
            try:
                mount_device(device)
                play_media()
                while os.path.exists(device):
                    time.sleep(1)
                umount_device()
                print(f"Device {device} removed.")
            except Exception as e:
                print(f"Error: {e}")
    time.sleep(5)
EOF
chmod +x "$autoplay_script_path"

# Erstellen und Konfigurieren des systemd Service für das Autoplay-Skript
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

# Konfigurieren des Autologins für den Benutzer
echo "Konfiguriere Autologin für den Benutzer $username..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin $username --noclear %I \$TERM" | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null
sudo systemctl daemon-reload

echo "Installation und Autologin-Konfiguration abgeschlossen."
