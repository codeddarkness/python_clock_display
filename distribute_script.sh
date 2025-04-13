#!/bin/bash
VERSION="1.0.0"
# Script to distribute files to their correct version directories

# Create version directories if they don't exist
mkdir -p v0.1 v0.2 v0.3 v1 v2

# Distribute v0.1 files
echo "Distributing v0.1 files..."
cat > v0.1/README.md << 'EOL'
# Block Clock (v0.1.0)

This is the initial version of the Block Clock program featuring basic time display functionality with different character styles.

## Features

- Real-time digital clock display in terminal
- Three different character style options:
  - Simple block characters (block_clock.py)
  - Unicode block characters (clock_v1.py)
  - ASCII art characters (pi_clock.py)
- Clean display with automatic screen refresh
- Easy to read large character display

## Files

- **block_clock.py**: Simple block character clock
- **clock_v1.py**: Unicode-based block character clock
- **pi_clock.py**: ASCII art character clock

## Usage

Run any of the clock scripts directly:

```
python block_clock.py
```

or

```
python clock_v1.py
```

or

```
python pi_clock.py
```

## Controls

- **Ctrl+C**: Exit the clock

## Notes

This is the first basic implementation of the Block Clock project, providing a simple terminal-based clock display with no additional features like date display or countdown.
EOL

cp v0.1/block_clock.py v0.1/ 2>/dev/null || cp block_clock.py v0.1/ 2>/dev/null
cp v0.1/clock_v1.py v0.1/ 2>/dev/null || cp clock_v1.py v0.1/ 2>/dev/null  
cp v0.1/pi_clock.py v0.1/ 2>/dev/null || cp pi_clock.py v0.1/ 2>/dev/null

# Distribute v0.2 files
echo "Distributing v0.2 files..."
cat > v0.2/README.md << 'EOL'
# Block Clock (v0.2.0)

This version adds countdown functionality and multiple display layouts to the Block Clock program.

## Features

- Election countdown display showing days, hours, minutes, and seconds
- Multiple layout options:
  - Countdown only display
  - Time and countdown split display
  - Time, date, and countdown combined display
- Block character styling
- Configurable election target date
- Auto-switching display modes

## Files

- **countdown.py**: Basic countdown display
- **countdown_block_clock.py**: Clock with date and countdown display
- **countdown_block_clock_tcd.py**: Time, countdown, and date display
- **countdown_block_clock_v4_wide.py**: Wide format display
- **countdown_latest.py**: Latest version with optimized layout
- **countdown_v1.py**: First version of countdown with time display
- **countdown_wip.py**: Work in progress version

## Usage

Run any of the scripts directly:

```
python countdown_latest.py
```

or

```
python countdown_block_clock.py
```

## Controls

- **Ctrl+C**: Exit the program

## Notes

This version represents a significant enhancement from v0.1, adding countdown functionality and multiple display layouts, although it still lacks interactivity beyond basic start/stop.
EOL

cp v0.2/countdown.py v0.2/ 2>/dev/null || cp countdown.py v0.2/ 2>/dev/null
cp v0.2/countdown_block_clock.py v0.2/ 2>/dev/null || cp countdown_block_clock.py v0.2/ 2>/dev/null
cp v0.2/countdown_block_clock_tcd.py v0.2/ 2>/dev/null || cp countdown_block_clock_tcd.py v0.2/ 2>/dev/null
cp v0.2/countdown_block_clock_v4_wide.py v0.2/ 2>/dev/null || cp countdown_block_clock_v4_wide.py v0.2/ 2>/dev/null
cp v0.2/countdown_latest.py v0.2/ 2>/dev/null || cp countdown_latest.py v0.2/ 2>/dev/null
cp v0.2/countdown_v1.py v0.2/ 2>/dev/null || cp countdown_v1.py v0.2/ 2>/dev/null
cp v0.2/countdown_wip.py v0.2/ 2>/dev/null || cp countdown_wip.py v0.2/ 2>/dev/null

# Distribute v0.3 files
echo "Distributing v0.3 files..."
cat > v0.3/README.md << 'EOL'
# Block Clock (v0.3.0)

This version introduces switching display modes and improved layout management.

## Features

- Auto-switching between time and countdown displays
- Toggle display functionality
- Improved block character rendering
- Centered text display for better visibility
- Election countdown with days, hours, minutes, and seconds
- Combined time, date, and countdown displays

## Files

- **block_countdown_switch.py**: Toggles between clock and countdown
- **time_countdown_block_clock.py**: Displays time and countdown together
- **time_countdown_date_block_clock.py**: Shows time, countdown, and date in a single display
- **toggle_time_countdown.py**: Toggles between displays with a timer

## Usage

Run any of the scripts directly:

```
python toggle_time_countdown.py
```

or

```
python block_countdown_switch.py
```

## Controls

- **Ctrl+C**: Exit the program
- Automatic display switching occurs at predefined intervals

## Notes

Version 0.3 focuses on improving the user experience by adding auto-switching display modes and better organization of the visual elements. This represents an intermediate step toward the full interactive version.
EOL

cp v0.3/block_countdown_switch.py v0.3/ 2>/dev/null || cp block_countdown_switch.py v0.3/ 2>/dev/null
cp v0.3/time_countdown_block_clock.py v0.3/ 2>/dev/null || cp time_countdown_block_clock.py v0.3/ 2>/dev/null
cp v0.3/time_countdown_date_block_clock.py v0.3/ 2>/dev/null || cp time_countdown_date_block_clock.py v0.3/ 2>/dev/null
cp v0.3/toggle_time_countdown.py v0.3/ 2>/dev/null || cp toggle_time_countdown.py v0.3/ 2>/dev/null

# Ensure v1 and v2 have README files (copying the existing ones if they exist)
if [ -f "v1/readme.md" ]; then
    cp v1/readme.md v1/README.md 2>/dev/null
elif [ -f "readme.md" ]; then
    cp readme.md v1/README.md 2>/dev/null
fi

if [ -f "v2/readme.md" ]; then
    cp v2/readme.md v2/README.md 2>/dev/null
elif [ -f "README.md" ]; then
    cp README.md v2/README.md 2>/dev/null
fi

# Apply version numbers to all files
echo "Applying version numbers to files..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_SCRIPT="$SCRIPT_DIR/version_script.sh"

if [ ! -f "$VERSION_SCRIPT" ]; then
    echo "Error: Version script not found at $VERSION_SCRIPT"
    echo "Please make sure version_script.sh exists and is in the same directory as this script."
else
    chmod +x "$VERSION_SCRIPT"
    "$VERSION_SCRIPT" 0.1.0 v0.1 || echo "Warning: Could not apply version to v0.1 files"
    "$VERSION_SCRIPT" 0.2.0 v0.2 || echo "Warning: Could not apply version to v0.2 files"  
    "$VERSION_SCRIPT" 0.3.0 v0.3 || echo "Warning: Could not apply version to v0.3 files"
    "$VERSION_SCRIPT" 1.1.0 v1 || echo "Warning: Could not apply version to v1 files"
    "$VERSION_SCRIPT" 1.2.0 v2 || echo "Warning: Could not apply version to v2 files"
fi

echo "File distribution complete!"
