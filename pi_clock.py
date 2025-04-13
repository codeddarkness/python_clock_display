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
  __  
 /  \ 
| () |
 \__/ 
      """,
"1":u"""\
 _ 
/ |
| |
|_|
   """,
"2":u"""\
 ___ 
|_  )
 / / 
/___|
     """,
"3":u"""\
 ____ 
|__ / 
 |_ \ 
|___/ 
      """,
"4":u"""\
 _ _  
| | | 
|_  _|
  |_| 
      """,
"5":u"""\
 ___  
| __| 
|__ \ 
|___/ 
      """,
"6":u"""\
  __  
 / /  
/ _ \ 
\___/ 
      """,
"7":u"""\
 ____ 
|__  |
  / / 
 /_/  
      """,
"8":u"""\
 ___  
( _ ) 
/ _ \ 
\___/ 
      """,
"9":u"""\
 ___  
/ _ \ 
\_, / 
 /_/  
      """,
"-":u"""\
 ___ 
|___|
     """,
":":u"""\
 _ 
(_)
 _ 
(_)
   """,
"a":u"""\
 __ _ 
/ _` |
\__,_|
      """,
"p":u"""\
 _ __ 
| '_ \
| .__/
|_|   
      """,
"m":u"""\
 _ __  
| '  \ 
|_|_|_|
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
