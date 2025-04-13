#!/usr/bin/python
# -*- coding: utf-8-*-
VERSION="0.1.1"

from time import sleep
from os import system, name
from datetime import datetime

## Function to clear screen
def clear():
        if name == "nt":
            system("cls")
        else:
            system("clear")
                               
## Function to convert characters into block font
## If display errors, verify flat spacing around characters
## Day and month characters not implemented into clock yet
def translate(text):
    text = str(text)
    letters = []
    for letter in text:
        letters.append(LETTERS[letter])
    for i in range(5): ## check height of letters
        for letter in letters:
            print letter.splitlines()[i],
        print

                	
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
}

def clock():
	while 1:
		try:
			ctime = datetime.now()
			values = [ctime.hour, ctime.minute, ctime.second]
			join_values = []
			for value in values:
				svalue = str(value)
				svalue = svalue if len(svalue) == 2 else "0" + svalue
				join_values.append(svalue)
			translate(":".join(join_values))
			sleep(0.5)
			clear()
		except (KeyboardInterrupt, IOError):
			clear()
			break

clear()
clock()
