#!/usr/bin/python
# -*- coding: utf-8-*-
VERSION="0.1.2"

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
"|":u"""\
 █ 
 █ 
 █ 
 █ 
 █ 
""",
".":u"""\
   
   
   
   
 █ 
""",
"?":u"""\
███
  █
 █ 
   
 █ 
""",
}

## Function to convert characters into block font and return as lines
def get_text_lines(text):
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
    
    # Generate lines
    lines = []
    for i in range(height):
        line = ""
        for letter in letters:
            line += letter.splitlines()[i] + " "  # Add extra space between characters
        lines.append(line)
    
    return lines

## Function to center text
def center_text(text, width=40):
    # Calculate padding for centering
    padding = (width - len(text)) // 2
    if padding > 0:
        return " " * padding + text
    else:
        return text

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
    
    # Format with leading zeros
    days_str = str(days).zfill(3)  # Allow for hundreds of days
    hours_str = str(hours).zfill(2)
    minutes_str = str(minutes).zfill(2)
    
    # Return in format days:hours:minutes
    return "{}:{}:{}".format(days_str, hours_str, minutes_str)

def combined_clock():
    terminal_width = 40  # Estimated width for 320px display
    
    while True:
        try:
            clear()
            
            # Get current time
            ctime = datetime.now()
            values = [ctime.hour, ctime.minute, ctime.second]
            join_values = []
            for value in values:
                svalue = str(value)
                svalue = svalue if len(svalue) == 2 else "0" + svalue
                join_values.append(svalue)
            
            time_str = ":".join(join_values)
            time_lines = get_text_lines(time_str)
            
            # Get countdown
            countdown = calculate_time_to_election()
            countdown_lines = get_text_lines(countdown)
            
            # Get current date
            current_date = ctime.strftime("%Y/%m/%d")
            
            # Print header
            #print("\n")
            #print(center_text("============= CURRENT TIME =============", terminal_width))
            print(center_text("============== " + current_date + " ==============", terminal_width))
            #print(center_text("=" * 20, terminal_width))
            
            # Print time
            for line in time_lines:
                print(center_text(line, terminal_width))
            
            # Space between the two displays
            #print("\n")
            
            # Print countdown header and countdown labels
            #print(center_text("ELECTION COUNTDOWN", terminal_width))
            print(center_text("========== ELECTION COUNTDOWN ==========", terminal_width))
            #print(center_text("=" * 40, terminal_width))
            
            # Print countdown
            for line in countdown_lines:
                print(center_text(line, terminal_width))
            
            #print(center_text("=========== DAYS : HRS : MIN ===========", terminal_width))
            print(center_text("       [ DAYS ]     [ HRS ]     [ MIN ]          ", terminal_width))
            # Print countdown labels
            #print(center_text("DAYS : HRS : MIN", terminal_width))
            
            # Print current date at bottom
            #print(center_text(current_date, terminal_width))
            
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
    combined_clock()
