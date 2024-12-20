#!/bin/bash

# Ensure we're at the root of the pi-gen project
if [[ ! -f "build.sh" ]]; then
    echo "Error: This script must be run at the root of the pi-gen repository."
    exit 1
fi

echo "Setting up your digital signage image..."

# Step 1: Create and configure the 'config' file
cat <<EOF > config
IMG_NAME='digital-signage-os'
RELEASE='bookworm'
ENABLE_SSH=1
LOCALE_DEFAULT='en_US.UTF-8'
TIMEZONE_DEFAULT='America/New_York'
FIRST_USER_NAME='pi'
FIRST_USER_PASS='raspberry'
EOF
echo "Created 'config' file."

# Step 2: Add necessary packages for kiosk mode
mkdir -p stage2/00-packages
cat <<EOF > stage2/00-packages
chromium-browser
xserver-xorg
x11-xserver-utils
unclutter
lightdm
htop
watchdog
EOF
echo "Added necessary packages to 'stage2/00-packages'."

# Step 3: Create kiosk mode script
mkdir -p stage2/rootfs/usr/local/bin
cat <<'EOF' > stage2/rootfs/usr/local/bin/kiosk.sh
#!/bin/bash
xset -dpms      # Disable power management
xset s off      # Disable screen saver
xset s noblank  # Disable blanking
unclutter &     # Hide the mouse cursor
chromium-browser --kiosk --noerrdialogs --disable-infobars --disable-translate --incognito "https://gratitude-kappa.vercel.app/"
EOF
chmod +x stage2/rootfs/usr/local/bin/kiosk.sh
echo "Created kiosk script at 'stage2/rootfs/usr/local/bin/kiosk.sh'."

# Step 4: Configure auto-login and auto-start
mkdir -p stage2/rootfs/etc/lightdm
cat <<EOF > stage2/rootfs/etc/lightdm/lightdm.conf
[SeatDefaults]
autologin-user=pi
autologin-session=lightdm-autologin
EOF
echo "Configured LightDM for auto-login."

mkdir -p stage2/rootfs/home/pi
cat <<EOF > stage2/rootfs/home/pi/.xinitrc
/usr/local/bin/kiosk.sh
EOF
chmod +x stage2/rootfs/home/pi/.xinitrc
echo "Configured auto-start with '.xinitrc'."

# Step 5: Configure watchdog
mkdir -p stage2/rootfs/etc
cat <<EOF > stage2/rootfs/etc/watchdog.conf
max-load-1 = 24
watchdog-device = /dev/watchdog
interval = 10
pidfile = /var/run/chromium.pid
EOF
echo "Configured 'watchdog' at 'stage2/rootfs/etc/watchdog.conf'."

# Step 6: Disable screen blanking
cat <<EOF >> stage2/rootfs/boot/config.txt
hdmi_blanking=0
EOF
echo "Disabled HDMI blanking in 'config.txt'."

# Step 7: Configure Wi-Fi (optional, remove if unnecessary)
mkdir -p stage2/rootfs/etc/wpa_supplicant
cat <<EOF > stage2/rootfs/etc/wpa_supplicant/wpa_supplicant.conf
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
network={
    ssid="YourSSID"
    psk="YourPassword"
}
EOF
chmod 600 stage2/rootfs/etc/wpa_supplicant/wpa_supplicant.conf
echo "Added optional Wi-Fi configuration."

# Final step: Confirmation
echo "Setup complete! You can now build your image using './build.sh' or './build-docker.sh'."