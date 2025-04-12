#!/usr/bin/python
# -*- coding: utf-8-*-

from time import sleep
from os import system, name
from datetime import datetime, timedelta

## Function to clear screen
def clear():
    if name == "nt":
        system("cls")
    else:
        system("clear")
                           
## Function to convert characters into block font
def translate(text):
    text = str(text)
    letters = []
    for letter in text:
        if letter in LETTERS:
            letters.append(LETTERS[letter])
        else:
            # Handle any characters not in our dictionary
            letters.append(LETTERS["?"])
    
    # Calculate the height to draw (all characters should be 5 lines tall)
    height = 5
    
    # Print each line of the characters
    for i in range(height):
        for letter in letters:
            print(letter.splitlines()[i]),
        print("")

# Add question mark for unknown characters and days/hours/min/sec labels
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
"d":u"""\
   
   
 d 
   
   
   """,
"h":u"""\
   
   
 h 
   
   
   """,
"m":u"""\
   
   
 m 
   
   
   """,
"s":u"""\
   
   
 s 
   
   
   """,
"?":u"""\
███
  █
 █ 
   
 █ 
   """,
}

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
    
    # For simpler display, convert days to hours if needed
    # Just show a simple format similar to the clock - no labels
    days_str = str(days).zfill(3)  # Allow for hundreds of days
    hours_str = str(hours).zfill(2)
    minutes_str = str(minutes).zfill(2)
    seconds_str = str(seconds).zfill(2)
    
    # Return in format similar to time (but with days as first component)
    return "{}:{}:{}:{}".format(days_str, hours_str, minutes_str, seconds_str)

def clock():
    show_clock = True  # Toggle between clock and countdown
    toggle_count = 0   # Counter to control switching
    
    while True:
        try:
            if show_clock:
                # Show current time
                ctime = datetime.now()
                values = [ctime.hour, ctime.minute, ctime.second]
                join_values = []
                print("\nCURRENT TIME")
                for value in values:
                    svalue = str(value)
                    svalue = svalue if len(svalue) == 2 else "0" + svalue
                    join_values.append(svalue)
                translate(":".join(join_values))
            else:
                # Show countdown
                print("\nCOUNTDOWN TO ELECTION")
                countdown = calculate_time_to_election()
                translate(countdown)
            
            # Increment counter and toggle display every 10 cycles (5 seconds)
            toggle_count += 1
            if toggle_count >= 10:
                show_clock = not show_clock
                toggle_count = 0
            
            sleep(0.5)  # Half-second refresh
            clear()
            
        except (KeyboardInterrupt, IOError):
            clear()
            break

if __name__ == "__main__":
    clear()
    print("Block Clock with Election Countdown")
    print("Press Ctrl+C to exit")
    sleep(2)
    clear()
    clock()
