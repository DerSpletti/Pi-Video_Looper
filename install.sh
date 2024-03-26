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

def device_still_connected(device):
    return os.path.exists(device)

def find_mounted_devices():
    result = subprocess.run(['lsblk', '-o', 'MOUNTPOINT'], capture_output=True, text=True)
    mounted = result.stdout.split('\n')
    return MOUNT_POINT in mounted

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
        command = [VLC_PATH, '--fullscreen', '--loop', '--no-video-title-show'] + media_files
        process = subprocess.Popen(command)
        return process
    else:
        print("No media files found on the USB device.")
        return None

while True:
    devices = list(find_usb_device())
    if devices:
        for device in devices:
            mount_device(device)
            if find_mounted_devices():
                process = play_media()
                while device_still_connected(device):
                    time.sleep(1)
                if process:
                    process.terminate()
                    time.sleep(1)  # Kurze Pause, um sicherzustellen, dass VLC geschlossen wird
                umount_device()
                print(f"Device {device} removed.")
    else:
        print("Waiting for USB device...")
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
