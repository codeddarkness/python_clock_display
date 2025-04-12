#!/bin/bash
# Script to set up block clock as a service running at boot on the console
# Run with sudo privileges

# Check if run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

echo "Setting up block clock as a boot service..."

# Define paths and file locations
CLOCK_FILE="/usr/local/bin/block_clock.py"
SERVICE_FILE="/etc/systemd/system/block-clock.service"

# Copy the Python script to system location
echo "Installing clock script to $CLOCK_FILE"
cp countdown_block_clock.py $CLOCK_FILE
chmod +x $CLOCK_FILE

# Create the systemd service file
echo "Creating systemd service file"
cat > $SERVICE_FILE << EOL
[Unit]
Description=Block Clock and Election Countdown
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python $CLOCK_FILE
Restart=always
StandardInput=tty
StandardOutput=tty
TTYPath=/dev/tty1
TTYReset=yes
TTYVHangup=yes

[Install]
WantedBy=multi-user.target
EOL

# Set permissions on service file
chmod 644 $SERVICE_FILE

# Disable the desktop environment (Raspberry Pi specific)
echo "Configuring system for console mode..."
RASPI_CONFIG_EXISTS=$(command -v raspi-config > /dev/null 2>&1; echo $?)

if [ $RASPI_CONFIG_EXISTS -eq 0 ]; then
  # This is a Raspberry Pi, use raspi-config to disable desktop
  echo "Raspberry Pi detected, using raspi-config to set boot to console"
  raspi-config nonint do_boot_behaviour B1
else
  # For other systems, try systemd approach
  echo "Setting default target to multi-user.target (console mode)"
  systemctl set-default multi-user.target
  
  # Disable display manager if present
  for DM in lightdm gdm gdm3 sddm xdm; do
    if systemctl is-enabled $DM 2>/dev/null; then
      echo "Disabling display manager: $DM"
      systemctl disable $DM
    fi
  done
fi

# Enable and start the service
echo "Enabling and starting block-clock service"
systemctl daemon-reload
systemctl enable block-clock.service
systemctl start block-clock.service

echo "Setup complete!"
echo "The block clock will start automatically on next boot."
echo "You can manually start it with: sudo systemctl start block-clock"
echo "You can check its status with: sudo systemctl status block-clock"
echo "To return to desktop mode in the future, run: sudo systemctl set-default graphical.target"
