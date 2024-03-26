#!/bin/bash

# Benutzerinformationen abfragen
echo "Bitte geben Sie Ihren Benutzernamen ein: "
read username

# Prüfen und Installieren von Abhängigkeiten: Python3 und VLC
echo "Überprüfe und installiere notwendige Pakete (Python3 und VLC)..."
sudo apt-get update
sudo apt-get install -y python3 vlc feh

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

# Konfigurationsvariablen
MOUNT_POINT = "/mnt/usb"
NO_USB_IMAGE_PATH = "/home/spletti/Pi-Video_Looper//no_usb.png"  # Aktualisiere diesen Pfad
VLC_PATH = subprocess.getoutput('which cvlc')  # Verwendet 'cvlc' statt 'vlc' falls 'cvlc' nicht gefunden wird
FEH_PROCESS = None

def find_usb_device():
    """Sucht nach USB-Geräten im /dev Verzeichnis."""
    for device in os.listdir('/dev'):
        if device.startswith('sd') and device[-1].isdigit():
            yield os.path.join('/dev', device)

def mount_device(device):
    """Mountet das gefundene USB-Gerät am vorgegebenen Mount-Punkt."""
    if not os.path.exists(MOUNT_POINT):
        os.makedirs(MOUNT_POINT)
    subprocess.run(['sudo', 'mount', device, MOUNT_POINT], check=True)

def umount_device():
    """Unmountet das USB-Gerät."""
    subprocess.run(['sudo', 'umount', MOUNT_POINT], check=True)
    if os.path.exists(MOUNT_POINT):
        os.rmdir(MOUNT_POINT)

def play_media():
    """Spielt die Medieninhalte des USB-Geräts mit VLC ab."""
    media_files = [os.path.join(MOUNT_POINT, f) for f in os.listdir(MOUNT_POINT) if os.path.isfile(os.path.join(MOUNT_POINT, f))]
    if media_files:
        command = [VLC_PATH, '--fullscreen', '--loop', '--no-video-title-show'] + media_files
        subprocess.Popen(command)
    else:
        print("No media files found on the USB device.")

def show_no_usb_image():
    """Zeigt ein Bild an, wenn kein USB-Gerät angeschlossen ist."""
    global FEH_PROCESS
    FEH_PROCESS = subprocess.Popen(['feh', '--fullscreen', NO_USB_IMAGE_PATH])

def hide_no_usb_image():
    """Versteckt das Bild, wenn ein USB-Gerät angeschlossen wird."""
    global FEH_PROCESS
    if FEH_PROCESS:
        FEH_PROCESS.terminate()
        FEH_PROCESS = None

while True:
    devices = list(find_usb_device())
    if devices:
        hide_no_usb_image()
        for device in devices:
            mount_device(device)
            play_media()
            while os.path.exists(device):
                time.sleep(1)
            umount_device()
            print(f"Device {device} removed.")
    else:
        show_no_usb_image()
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
