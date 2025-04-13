#!/usr/bin/python
# -*- coding: utf-8-*-
VERSION="1.1.0"

# Character set library for block clock displays

# Original block characters (from block_clock.py)
BLOCK_CHARS = {
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
".":u"""\
   
   
   
   
 █ 
""",
" ":u"""\
   
   
   
   
   
""",
"|":u"""\
 █ 
 █ 
 █ 
 █ 
 █ 
""",
"?":u"""\
███
  █
 █ 
   
 █ 
""",
"*":u"""\
█ █ █
 █ █
█ █ █
 █ █
█ █ █
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
}

# ASCII terminal characters (from pi_clock.py)
ASCII_CHARS = {
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
".":u"""\
   
   
   
 _ 
(_)""",
" ":u"""\
    
    
    
    
    """,
"?":u"""\
 ___ 
|__ )
 |_ )
  /_)
 (_) """,
"a":u"""\
 __ _ 
/ _` |
\__,_|
      
      """,
"p":u"""\
 _ __ 
| '_ \\
| .__/
|_|   
      """,
"m":u"""\
 _ __  
| '  \\ 
|_|_|_|
       
       """,
}

# Unicode block characters (from clock_v1.py)
UNICODE_BLOCK_CHARS = {
"0":u"""\
 ██████╗ 
██╔═████╗
██║██╔██║
████╔╝██║
╚██████╔╝
 ╚═════╝ """,
"1":u"""\
 ██╗
███║
╚██║
 ██║
 ██║
 ╚═╝""",
"2":u"""\
██████╗ 
╚════██╗
 █████╔╝
██╔═══╝ 
███████╗
╚══════╝""",
"3":u"""\
██████╗ 
╚════██╗
 █████╔╝
 ╚═══██╗
██████╔╝
╚═════╝ """,
"4":u"""\
██╗  ██╗
██║  ██║
███████║
╚════██║
     ██║
     ╚═╝""",
"5":u"""\
███████╗
██╔════╝
███████╗
╚════██║
███████║
╚══════╝""",
"6":u"""\
 ██████╗ 
██╔════╝ 
███████╗ 
██╔═══██╗
╚██████╔╝
 ╚═════╝ """,
"7":u"""\
███████╗
╚════██║
    ██╔╝
   ██╔╝ 
   ██║  
   ╚═╝  """,
"8":u"""\
 █████╗ 
██╔══██╗
╚█████╔╝
██╔══██╗
╚█████╔╝
 ╚════╝ """,
"9":u"""\
 █████╗ 
██╔══██╗
╚██████║
 ╚═══██║
 █████╔╝
 ╚════╝ """,
":":u"""\
   
██╗
╚═╝
██╗
╚═╝
   """,
" ":u"""\
  
  
  
  
  
  """,
"-":u"""\


███████╗
╚══════╝

""",
".":u"""\
    
    
    
    
 ██╗
 ╚═╝""",
"?":u"""\
██████╗ 
╚════██╗
   ██╔╝ 
   ╚═╝  
   ██╗  
   ╚═╝  """,
"d":u"""\
   
   
 ██╗
 ╚═╝
   
   """,
"h":u"""\
   
   
 ██╗
 ╚═╝
   
   """,
"m":u"""\
   
   
 ██╗
 ╚═╝
   
   """,
"s":u"""\
   
   
 ██╗
 ╚═╝
   
   """,
}

def get_character_set(name):
    """Return character set dictionary by name"""
    if name.lower() == "block":
        return BLOCK_CHARS
    elif name.lower() == "ascii":
        return ASCII_CHARS
    elif name.lower() == "unicode":
        return UNICODE_BLOCK_CHARS
    else:
        # Default to block chars if name not recognized
        return BLOCK_CHARS

def get_available_charsets():
    """Return list of available character set names"""
    return ["block", "ascii", "unicode"]

def get_char_height(charset_name):
    """Return character height for the specified charset"""
    sample_char = get_character_set(charset_name)["0"]
    return len(sample_char.splitlines())
