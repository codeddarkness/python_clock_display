#!/usr/bin/python
# -*- coding: utf-8-*-
VERSION="0.1.3"

from time import sleep
from os import system, name
from datetime import datetime

## Function to clear screen
def clear():
    if name == "nt":
        system("cls")
    else:
        system("clear")
                           
## Define block characters - original size, well-tested
LETTERS = {
"0":u"""\
███
█ █
█ █
█ █
███
""",
"1":u"""\
  █
 ██
  █
  █
  █
""",
"2":u"""\
███
  █
███
█  
███
""",
"3":u"""\
███
  █
███
  █
███
""",
"4":u"""\
█ █
█ █
███
  █
  █
""",
"5":u"""\
███
█  
███
  █
███
""",
"6":u"""\
███
█  
███
█ █
███
""",
"7":u"""\
███
  █
 █ 
█  
█  
""",
"8":u"""\
███
█ █
███
█ █
███
""",
"9":u"""\
███
█ █
███
  █
███
""",
"-":u"""\



███


""",
":":u"""\
   
 █ 
   
 █ 
   
""",
"?":u"""\
███
  █
 █ 
   
 █ 
""",
}

## Function to convert characters into block font
def translate(text, centered=True):
    text = str(text)
    letters = []
    
    # Collect all letter blocks
    for letter in text:
        if letter in LETTERS:
            letters.append(LETTERS[letter])
        else:
            letters.append(LETTERS["?"])
    
    # Calculate the height (all characters are 5 lines tall)
    height = 5
    
    # Generate lines with centering if requested
    lines = []
    for i in range(height):
        line = ""
        for letter in letters:
            line += letter.splitlines()[i] + " "  # Add extra space between characters
        lines.append(line)
    
    # Center text if requested (helps with screen filling)
    if centered:
        terminal_width = 40  # Estimate for 320px width TFT display
        centered_lines = []
        for line in lines:
            # Calculate padding for centering
            padding = (terminal_width - len(line)) // 2
            if padding > 0:
                centered_lines.append(" " * padding + line)
            else:
                centered_lines.append(line)
        lines = centered_lines
    
    # Print the output
    for line in lines:
        print(line)
    
    # Add empty lines to better fill the screen
    print("\n\n")

def calculate_time_to_election():
    # Election date: November 7, 2028
    election_date = datetime(2028, 11, 7, 0, 0, 0)
    now = datetime.now()
    time_left = election_date - now
    
    # If the election has passed
    if time_left.total_seconds() < 0:
        return "000:00:00"
    
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
    
    # Return in format similar to time (days:hours:minutes:seconds)
    return "{}:{}:{}:{}".format(days_str, hours_str, minutes_str, seconds_str)

def clock():
    show_clock = True  # Toggle between clock and countdown
    toggle_count = 0   # Counter to control switching
    
    while True:
        try:
            clear()
            
            # Print header with current mode
            if show_clock:
                print("\n")  # Extra lines to push content down
                print("[ CURRENT TIME ]".upper())
                #print("==========================")
                
                # Show current time
                ctime = datetime.now()
                values = [ctime.hour, ctime.minute, ctime.second]
                join_values = []
                for value in values:
                    svalue = str(value)
                    svalue = svalue if len(svalue) == 2 else "0" + svalue
                    join_values.append(svalue)
                
                translate(":".join(join_values), centered=True)
            else:
                print("\n")  # Extra lines to push content down
                print("[ ELECTION COUNTDOWN ]".upper())
                #print("=======================")
                
                # Show countdown
                countdown = calculate_time_to_election()
                translate(countdown, centered=True)
                
                print("[ DAYS : HOURS : MIN : SEC ]")
            
            # Increment counter and toggle display every 20 cycles (10 seconds)
            toggle_count += 1
            if toggle_count >= 20:
                show_clock = not show_clock
                toggle_count = 0
            
            sleep(0.5)  # Half-second refresh
            
        except (KeyboardInterrupt, IOError):
            clear()
            break

if __name__ == "__main__":
    clear()
    print("\n\n Block Clock with Election Countdown \n\n")
    print(" Press Ctrl+C to exit ")
    sleep(2)
    clear()
    clock()
