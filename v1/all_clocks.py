#!/usr/bin/python
# -*- coding: utf-8-*-
VERSION="1.1.0"

import os
import sys
import time
from datetime import datetime
import signal
import curses
import clock_chars

# Global variables
TERMINAL_WIDTH = 80
TERMINAL_HEIGHT = 24
CHAR_SET = "block"      # Default character set
LAYOUT = "combined"     # Default layout: combined, cycle, or single
ALIGNMENT = "center"    # Default alignment: left, center, right
COLOR_PAIR = 1          # Default color pair
CYCLE_DELAY = 10        # Number of half-second cycles before switching views in cycle mode
ELECTION_DATE = datetime(2028, 11, 7, 0, 0, 0)  # Election date

# Initialize curses
stdscr = None
color_pairs = [
    (curses.COLOR_WHITE, curses.COLOR_BLACK),    # White on black
    (curses.COLOR_GREEN, curses.COLOR_BLACK),    # Green on black
    (curses.COLOR_CYAN, curses.COLOR_BLACK),     # Cyan on black
    (curses.COLOR_YELLOW, curses.COLOR_BLACK),   # Yellow on black
    (curses.COLOR_RED, curses.COLOR_BLACK),      # Red on black
    (curses.COLOR_MAGENTA, curses.COLOR_BLACK),  # Magenta on black
    (curses.COLOR_BLUE, curses.COLOR_BLACK),     # Blue on black
]

def setup_colors():
    """Initialize color pairs for curses"""
    curses.start_color()
    curses.use_default_colors()
    
    # Initialize all color pairs
    for i, (fg, bg) in enumerate(color_pairs, 1):
        curses.init_pair(i, fg, bg)

def signal_handler(sig, frame):
    """Handle Ctrl+C to exit gracefully"""
    cleanup()
    sys.exit(0)

def cleanup():
    """Clean up curses before exiting"""
    if stdscr is not None:
        curses.echo()
        curses.nocbreak()
        curses.endwin()

def clear_screen():
    """Clear the screen using curses"""
    stdscr.clear()
    stdscr.refresh()

def get_text_lines(text, charset_name=None):
    """Convert text to block character lines"""
    if charset_name is None:
        charset_name = CHAR_SET
        
    text = str(text)
    letters = []
    charset = clock_chars.get_character_set(charset_name)
    
    # Collect all letter blocks
    for letter in text:
        if letter in charset:
            letters.append(charset[letter])
        else:
            letters.append(charset.get("?", "?"))
    
    # Calculate the height (all characters have the same height in a given charset)
    char_height = clock_chars.get_char_height(charset_name)
    
    # Generate lines
    lines = []
    for i in range(char_height):
        line = ""
        for letter in letters:
            line_parts = letter.splitlines()
            if i < len(line_parts):
                line += line_parts[i] + " "  # Add extra space between characters
            else:
                line += " " * (len(line_parts[0]) + 1)  # Maintain spacing if line is missing
        lines.append(line)
    
    return lines

def render_text(y, text, charset_name=None, alignment=None):
    """Render text at the specified y position with given charset and alignment"""
    if charset_name is None:
        charset_name = CHAR_SET
    if alignment is None:
        alignment = ALIGNMENT
        
    lines = get_text_lines(text, charset_name)
    
    for i, line in enumerate(lines):
        # Apply alignment
        if alignment == "center":
            x = (TERMINAL_WIDTH - len(line)) // 2
        elif alignment == "right":
            x = TERMINAL_WIDTH - len(line) - 1
        else:  # "left"
            x = 1
            
        x = max(0, x)  # Ensure x doesn't go negative
        
        # Render the line with current color
        stdscr.addstr(y + i, x, line, curses.color_pair(COLOR_PAIR))
        
    return y + len(lines)

def print_header(y, text, alignment=None):
    """Print a header text"""
    if alignment is None:
        alignment = ALIGNMENT
        
    if alignment == "center":
        x = (TERMINAL_WIDTH - len(text)) // 2
    elif alignment == "right":
        x = TERMINAL_WIDTH - len(text) - 1
    else:  # "left"
        x = 1
        
    stdscr.addstr(y, x, text, curses.color_pair(COLOR_PAIR) | curses.A_BOLD)
    return y + 1

def get_current_time():
    """Get current time formatted as HH:MM:SS"""
    ctime = datetime.now()
    values = [ctime.hour, ctime.minute, ctime.second]
    join_values = []
    for value in values:
        svalue = str(value)
        svalue = svalue if len(svalue) == 2 else "0" + svalue
        join_values.append(svalue)
    return ":".join(join_values)

def get_current_date():
    """Get current date formatted as YYYY.MM.DD"""
    ctime = datetime.now()
    year = str(ctime.year)
    month = str(ctime.month).zfill(2)
    day = str(ctime.day).zfill(2)
    return "{}.{}.{}".format(year, month, day)

def calculate_time_to_election():
    """Calculate time to election date"""
    now = datetime.now()
    time_left = ELECTION_DATE - now
    
    # If the election has passed
    if time_left.total_seconds() < 0:
        return "000:00:00:00"
    
    # Calculate days, hours, minutes, seconds
    days = time_left.days
    hours = time_left.seconds // 3600
    minutes = (time_left.seconds % 3600) // 60
    seconds = time_left.seconds % 60
    
    # Format with leading zeros
    days_str = str(days).zfill(3)  # Allow for hundreds of days
    hours_str = str(hours).zfill(2)
    minutes_str = str(minutes).zfill(2)
    seconds_str = str(seconds).zfill(2)
    
    # Return in format days:hours:minutes:seconds
    return "{}:{}:{}:{}".format(days_str, hours_str, minutes_str, seconds_str)

def display_time(y=2):
    """Display the current time"""
    y = print_header(y, "CURRENT TIME")
    y = render_text(y + 1, get_current_time())
    return y + 1

def display_date(y=2):
    """Display the current date"""
    y = print_header(y, "TODAY'S DATE")
    y = render_text(y + 1, get_current_date())
    return y + 1

def display_countdown(y=2):
    """Display the election countdown"""
    y = print_header(y, "ELECTION COUNTDOWN")
    y = render_text(y + 1, calculate_time_to_election())
    y = print_header(y + 1, "DAYS : HRS : MIN : SEC")
    return y + 1

def display_combined():
    """Display time, date, and countdown together"""
    y = 1
    
    # Get current date for header
    cdate = datetime.now().strftime("%Y/%m/%d")
    y = print_header(y, "============== " + cdate + " ==============")
    
    # Display time
    y = render_text(y + 1, get_current_time())
    
    # Display countdown header
    y = print_header(y + 2, "========== ELECTION COUNTDOWN ==========")
    
    # Display countdown
    y = render_text(y + 1, calculate_time_to_election())
    
    # Display countdown labels
    y = print_header(y + 1, "       [ DAYS ]     [ HRS ]     [ MIN ]     [ SEC ]")
    
    # Display date at the bottom
    y = print_header(y + 2, "TODAY'S DATE")
    y = render_text(y + 1, get_current_date())

def display_help():
    """Display help information"""
    y = 1
    
    help_text = [
        "BLOCK CLOCK HELP",
        "--------------",
        "Navigation:",
        "  Left/Right Arrow Keys: Change display layout",
        "  Up/Down Arrow Keys: Change display color",
        "  C: Cycle through character sets",
        "  A: Cycle through text alignments (left, center, right)",
        "  Q or Ctrl+C: Quit the program",
        "",
        "Layouts:",
        "  Combined: Shows time, date, and countdown together",
        "  Cycle: Automatically cycles through time, date, and countdown",
        "  Single: Shows only one display at a time, use Left/Right to change",
        "",
        "Current Settings:",
        f"  Character Set: {CHAR_SET}",
        f"  Layout: {LAYOUT}",
        f"  Alignment: {ALIGNMENT}",
        f"  Color: {COLOR_PAIR}",
        "",
        "Press any key to return..."
    ]
    
    for line in help_text:
        stdscr.addstr(y, 2, line, curses.color_pair(COLOR_PAIR))
        y += 1

def main(screen):
    """Main function"""
    global stdscr, TERMINAL_WIDTH, TERMINAL_HEIGHT, CHAR_SET, LAYOUT, ALIGNMENT, COLOR_PAIR
    
    # Save screen object globally
    stdscr = screen
    
    # Set up terminal
    curses.curs_set(0)  # Hide cursor
    curses.halfdelay(5)  # 0.5 second input delay
    stdscr.nodelay(True)  # Non-blocking input
    curses.noecho()
    stdscr.keypad(True)  # Enable special keys
    
    # Set up colors
    setup_colors()
    
    # Get terminal dimensions
    TERMINAL_HEIGHT, TERMINAL_WIDTH = stdscr.getmaxyx()
    
    # Initialize variables
    cycle_count = 0
    current_view = 0  # 0: time, 1: date, 2: countdown
    views = ["time", "date", "countdown"]
    
    # Display startup message
    stdscr.clear()
    stdscr.addstr(TERMINAL_HEIGHT // 2 - 2, (TERMINAL_WIDTH - 30) // 2, "Block Clock with Election Countdown", curses.color_pair(COLOR_PAIR) | curses.A_BOLD)
    stdscr.addstr(TERMINAL_HEIGHT // 2, (TERMINAL_WIDTH - 30) // 2, "Press '?' for help or 'Q' to quit", curses.color_pair(COLOR_PAIR))
    stdscr.refresh()
    time.sleep(2)
    
    # Main loop
    try:
        while True:
            # Clear screen
            stdscr.clear()
            
            # Get terminal dimensions (which might have changed)
            TERMINAL_HEIGHT, TERMINAL_WIDTH = stdscr.getmaxyx()
            
            # Handle different layouts
            if LAYOUT == "combined":
                display_combined()
            elif LAYOUT == "cycle":
                if cycle_count == 0:
                    current_view = (current_view + 1) % len(views)
                
                # Display the current view
                if views[current_view] == "time":
                    display_time()
                elif views[current_view] == "date":
                    display_date()
                else:  # "countdown"
                    display_countdown()
                    
                # Increment cycle counter
                cycle_count = (cycle_count + 1) % CYCLE_DELAY
            else:  # "single"
                if views[current_view] == "time":
                    display_time()
                elif views[current_view] == "date":
                    display_date()
                else:  # "countdown"
                    display_countdown()
            
            # Display footer with key information
            footer_text = "Press '?' for help or 'Q' to quit"
            stdscr.addstr(TERMINAL_HEIGHT - 1, (TERMINAL_WIDTH - len(footer_text)) // 2, 
                         footer_text, curses.color_pair(COLOR_PAIR))
            
            # Update the screen
            stdscr.refresh()
            
            # Get user input
            try:
                key = stdscr.getch()
            except:
                key = -1
                
            # Process user input
            if key == ord('q') or key == ord('Q'):
                break
            elif key == ord('?'):
                stdscr.clear()
                display_help()
                stdscr.refresh()
                # Wait for any key
                stdscr.nodelay(False)
                stdscr.getch()
                stdscr.nodelay(True)
            elif key == curses.KEY_LEFT:
                # Change layout or view
                if LAYOUT == "single":
                    current_view = (current_view - 1) % len(views)
                else:
                    LAYOUT = {"combined": "single", "single": "cycle", "cycle": "combined"}[LAYOUT]
            elif key == curses.KEY_RIGHT:
                # Change layout or view
                if LAYOUT == "single":
                    current_view = (current_view + 1) % len(views)
                else:
                    LAYOUT = {"combined": "cycle", "cycle": "single", "single": "combined"}[LAYOUT]
            elif key == curses.KEY_UP:
                # Change color
                COLOR_PAIR = (COLOR_PAIR % len(color_pairs)) + 1
            elif key == curses.KEY_DOWN:
                # Change color
                COLOR_PAIR = (COLOR_PAIR - 2) % len(color_pairs) + 1
            elif key == ord('c') or key == ord('C'):
                # Cycle through character sets
                charsets = clock_chars.get_available_charsets()
                current_idx = charsets.index(CHAR_SET) if CHAR_SET in charsets else 0
                CHAR_SET = charsets[(current_idx + 1) % len(charsets)]
            elif key == ord('a') or key == ord('A'):
                # Cycle through alignments
                ALIGNMENT = {"left": "center", "center": "right", "right": "left"}[ALIGNMENT]
            
            # Short delay to prevent high CPU usage
            time.sleep(0.05)
            
    except KeyboardInterrupt:
        pass

if __name__ == "__main__":
    # Set up signal handler for graceful exit on Ctrl+C
    signal.signal(signal.SIGINT, signal_handler)
    
    try:
        # Initialize and run curses application
        curses.wrapper(main)
    except Exception as e:
        cleanup()
        print(f"An error occurred: {e}")
        sys.exit(1)
    finally:
        cleanup()
