#!/bin/bash
VERSION="1.2.0"
# Script to set up block clock as a service running at boot on the console
# Run with sudo privileges

# Check if run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

echo "Setting up block clock as a boot service..."

# Define paths and file locations
INSTALL_DIR="/usr/local/bin"
CLOCK_DIR="$INSTALL_DIR/blockclock"
CLOCK_MAIN="$CLOCK_DIR/block_clock.py"
CLOCK_CHARS="$CLOCK_DIR/clock_chars.py"
SERVICE_FILE="/etc/systemd/system/block-clock.service"

# Create installation directory
echo "Creating installation directory $CLOCK_DIR"
mkdir -p $CLOCK_DIR

# Copy the Python scripts to system location
echo "Installing clock scripts"
cp block_clock.py $CLOCK_MAIN
cp clock_chars.py $CLOCK_CHARS
chmod +x $CLOCK_MAIN
chmod +x $CLOCK_CHARS

# Create the systemd service file with proper TTY handling
echo "Creating systemd service file"
cat > $SERVICE_FILE << EOL
[Unit]
Description=Block Clock and Election Countdown
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 $CLOCK_MAIN
Restart=on-failure
StandardInput=tty
StandardOutput=tty
TTYPath=/dev/tty1
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes
KillMode=process
KillSignal=SIGTERM
TimeoutStopSec=5
SendSIGHUP=yes

[Install]
WantedBy=multi-user.target
EOL

# Set permissions on service file
chmod 644 $SERVICE_FILE

# Create a systemd override to properly handle TTY
mkdir -p /etc/systemd/system/block-clock.service.d/
cat > /etc/systemd/system/block-clock.service.d/override.conf << EOL
[Service]
TTYReset=yes
TTYVHangup=yes
EOL

# Configure system for console mode
echo "Configuring system for console mode..."
if command -v raspi-config > /dev/null 2>&1; then
  # This is a Raspberry Pi, use raspi-config to disable desktop but keep auto-login
  echo "Raspberry Pi detected, using raspi-config to set boot to console with auto-login"
  raspi-config nonint do_boot_behaviour B2
else
  # For other systems, try a more gentle approach
  echo "Setting getty@tty1 to auto-start the clock service"
  
  # Create a systemd override for getty
  mkdir -p /etc/systemd/system/getty@tty1.service.d/
  cat > /etc/systemd/system/getty@tty1.service.d/override.conf << EOL
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $(whoami) --noclear %I $TERM
EOL
  
  # We'll keep the graphical target but modify the getty
  # This ensures the system still boots normally but auto-logs in on TTY1
  systemctl daemon-reload
fi

# Enable the service
echo "Enabling block-clock service"
systemctl daemon-reload
systemctl enable block-clock.service

# Create an uninstall script
UNINSTALL_SCRIPT="$CLOCK_DIR/uninstall_block_clock.sh"
cat > $UNINSTALL_SCRIPT << EOL
#!/bin/bash
VERSION="1.2.0"
# Script to remove the block clock service
# Run with sudo privileges

if [ "\$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

echo "Removing block clock service..."

# Stop and disable the service
systemctl stop block-clock.service
systemctl disable block-clock.service

# Remove service files
rm -f /etc/systemd/system/block-clock.service
rm -rf /etc/systemd/system/block-clock.service.d

# Remove getty override if it exists
rm -rf /etc/systemd/system/getty@tty1.service.d

# Reload systemd
systemctl daemon-reload

# Remove installation directory
rm -rf $CLOCK_DIR

# Restore desktop environment if needed
if command -v raspi-config > /dev/null 2>&1; then
  # For Raspberry Pi, restore desktop with auto-login
  raspi-config nonint do_boot_behaviour B4
fi

echo "Block clock service has been removed."
echo "You may need to reboot your system to restore normal operation."
EOL

chmod +x $UNINSTALL_SCRIPT

echo "Setup complete! The block clock will start automatically on next boot."
echo "You can manually start it with: sudo systemctl start block-clock"
echo "You can check its status with: sudo systemctl status block-clock"
echo "To uninstall, run: sudo $UNINSTALL_SCRIPT"
echo ""
echo "A reboot is recommended to start the service: sudo reboot"
