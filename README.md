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
