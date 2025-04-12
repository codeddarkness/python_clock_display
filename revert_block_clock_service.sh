#!/bin/bash
# Script to revert the block clock service setup
# Run with sudo privileges

# Check if run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

echo "Reverting block clock service setup..."

# Define paths and file locations
CLOCK_FILE="/usr/local/bin/block_clock.py"
SERVICE_FILE="/etc/systemd/system/block-clock.service"

# Stop and disable service
echo "Stopping and disabling block-clock service"
systemctl stop block-clock.service 2>/dev/null
systemctl disable block-clock.service 2>/dev/null
systemctl daemon-reload

# Remove service file
if [ -f "$SERVICE_FILE" ]; then
  echo "Removing systemd service file"
  rm "$SERVICE_FILE"
fi

# Remove clock script
if [ -f "$CLOCK_FILE" ]; then
  echo "Removing block clock script"
  rm "$CLOCK_FILE"
fi

# Re-enable desktop environment
echo "Restoring desktop environment..."
RASPI_CONFIG_EXISTS=$(command -v raspi-config > /dev/null 2>&1; echo $?)

if [ $RASPI_CONFIG_EXISTS -eq 0 ]; then
  # This is a Raspberry Pi, use raspi-config to enable desktop
  echo "Raspberry Pi detected, using raspi-config to set boot to desktop"
  raspi-config nonint do_boot_behaviour B4
else
  # For other systems, use systemd approach
  echo "Setting default target back to graphical.target (desktop mode)"
  systemctl set-default graphical.target
  
  # Try to re-enable common display managers
  for DM in lightdm gdm gdm3 sddm xdm; do
    if [ -f "/usr/lib/systemd/system/$DM.service" ]; then
      echo "Re-enabling display manager: $DM"
      systemctl enable $DM
    fi
  done
fi

echo "Revert complete!"
echo "The block clock service has been removed and desktop mode restored."
echo "Changes will take effect after reboot."
echo "You can reboot now with: sudo reboot"
