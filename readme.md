# Block Clock (v1.1.0)

A customizable terminal-based clock program with multiple display modes, character sets, and visual options.

## Features

### Display Modes
- **Combined Display:** Shows time, date, and election countdown together on one screen
- **Cycle Display:** Automatically rotates between time, date, and countdown views
- **Single Display:** Shows one view at a time (time, date, or countdown)

### Character Sets
- **Block:** Simple ASCII block characters
- **ASCII:** Terminal-friendly ASCII art style
- **Unicode:** Elaborate Unicode block art style

### Visual Customization
- **Multiple color schemes** (change with Up/Down arrow keys)
- **Text alignment options:** left, center, right (toggle with 'A' key)
- **Customizable layouts** (change with Left/Right arrow keys)

### Navigation Controls
- **Left/Right arrow keys:** Change display layout or cycle through views
- **Up/Down arrow keys:** Change display colors
- **'C' key:** Toggle between character sets
- **'A' key:** Toggle between text alignments
- **'?' key:** Show help screen
- **'Q' key or Ctrl+C:** Exit the program

### Election Countdown
The program includes a countdown to the next election (currently set to November 7, 2028). This is configurable in the code.

## Installation

### Manual Installation
1. Clone or download this repository
2. Make sure you have Python 3 installed
3. Run the program with: `python3 block_clock.py`

### Automatic Installation (Raspberry Pi or Linux)
For installation as a system service that runs at boot:

1. Clone or download this repository
2. Make the installer script executable: `chmod +x setup_block_clock.sh`
3. Run the installer with sudo: `sudo ./setup_block_clock.sh`
4. Reboot your system: `sudo reboot`

The clock will start automatically on the console at boot.

### Uninstallation
If you used the automatic installation method, you can uninstall with:
```
sudo /usr/local/bin/blockclock/uninstall_block_clock.sh
```

## Files
- **block_clock.py:** Main program file with the interactive clock interface
- **clock_chars.py:** Library file containing different character sets
- **setup_block_clock.sh:** Installation script for setting up as a system service
- **README.md:** This documentation file

## Requirements
- Python 3
- Terminal with color support (for best experience)
- Support for Unicode characters (for the Unicode character set)

## Customization
You can customize the program by modifying the constants at the top of the `block_clock.py` file:
- `CHAR_SET`: Default character set to use
- `LAYOUT`: Default layout mode
- `ALIGNMENT`: Default text alignment
- `COLOR_PAIR`: Default color scheme
- `CYCLE_DELAY`: Number of half-second cycles before switching views in cycle mode
- `ELECTION_DATE`: Target date for countdown timer

## Troubleshooting

### Terminal Display Issues
- If the characters appear misaligned, try a different terminal or font
- For best results with the Unicode character set, use a terminal that supports Unicode
- If colors don't display correctly, make sure your terminal supports colors

### Service Installation Issues
- If the service doesn't start, check its status with: `sudo systemctl status block-clock`
- If you see login loops, try the manual installation instead
- For Raspberry Pi, make sure your user has proper permissions

## License
This project is open-source and available under the MIT License.

## Credits
This program combines and extends multiple clock implementations with character set styling from various sources.

## Future Improvements
- Additional character sets
- User-configurable countdown targets
- Weather display integration
- Custom color schemes
- Configuration file support
