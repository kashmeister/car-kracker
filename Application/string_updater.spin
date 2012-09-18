''********************************************
''*  Car Kracker String Updater              *
''*  Author: Nick McClanahan (c) 2012        *
''*  See end of file for terms of use.       *
''********************************************

{-----------------USAGE NOTES-----------------
Strings are stored on upper EEPROM, and can't be programmed the same way as the regular program.
This is s a small program to load the upper EEPROM with the strings the Car Kracker uses.
THIS PROGRM IS NOT NECESSARY - if you are using the kustomizer to update firmware.  It will Automatically update the upper eeprom after the firmware update 
}
DAT
Version  BYTE "V",13,"0.59",13,0 
version2 BYTE 16,"Kracker V 0.59",0

CON
  _clkmode = xtal1 + pll16x                             ' Crystal and PLL settings.
  _xinfreq = 5_000_000                                  ' 5 MHz crystal (5 MHz x 16 = 80 MHz).
  Menudelay = 5

  EEPROM_Addr   = %1010_0000   
  EEPROM_base   = $8000
  stack_base    = $7500

  RADsize       = 11 
  maincog =  4, LEDcog = 2  
'Cogs are custom mapped to reduce jitter - COG 0 goes with audio.  Definitions:
'COG7: Touch / SD __COG6: Kbus RX  __Cog 5: Debug Console  __Cog 4: Main Thread  __Cog 3: Audio Buffer __Cog 2: LED notifier __Cog 0: Audio

OBJ
  debug        : "DebugTerminal.spin" 
  i2cObject    : "i2cObject.spin"
  SD           : "FSRW"
  
  
VAR
'LED Notifier
BYTE ledctrl
LONG stack[25]
BYTE getorset[20]
'Variables for Config Mode
BYTE configbuffer[128]


 
PUB Initialize
'We use this method to dump running the main process in Cog 0
                                 
coginit(maincog, main, stack_base)
coginit(LEDcog, LEDnotifier, @stack)
debug.StartRxTx(31, 30, %0000, 115_200)
 
cogstop(0)


PUB main | i, c, delay
i2cObject.Init(29, 28, false)


debug.str(string("Updating Strings",13))
loadtextstrings
debug.str(string("Done!",13))


PUB loadtextstrings | i, x, y, strstart, offset, strlen, strcnt, strptr

strstart := 600    
offset := 400
strcnt := 0


repeat x from 0 to 62
  strptr := @@strings[x]
  strlen := strsize(strptr)
  BYTE[strptr + strlen - 9] := 0
  strlen := strsize(strptr)   
  EEPROM_set(offset,strstart.byte[0])   'Store the start address to the string
  EEPROM_set(offset+1,strstart.byte[1])

   repeat i from 0 to strlen
    IF BYTE[strptr + i] == "~"
       BYTE[strptr + i] := 13        
    EEPROM_set(strstart,BYTE[strptr + i])
    strstart++
  strstart++
  offset += 2




DAT

strings WORD @str00, @str01, @str02, @str03, @str04, @str05, @str06, @str07, @str08, @str09, @str10, @str11, @str12
        WORD @str13, @str14, @str15, @str16, @str17, @str18, @str19, @str20, @str21, @str22, @str23, @str24, @str25
        WORD @str26, @str27, @str28, @str29, @str30, @str31, @str32, @str33, @str34, @str35, @str36, @str37, @str38
        WORD @str39, @str40, @str41, @str42, @str43, @str44, @str45, @str46, @str47, @str48, @str49, @str50, @str51
        WORD @str52, @str53, @str54, @str55, @str56, @str57, @str58, @str59, @str60 


str00 BYTE "Hit d key for debug</string>",0
str01 BYTE "~DEBUG MENU~Main Modes:~ 0: Diagnostic~</string>",0
str02 BYTE " 1: Music~ 2: SerialRepeat~ 3: Remapper~ 4: DataLog~Test</string>",0
str03 BYTE "Modes: (e to escape test)~ 5: Hex Bus Sniffer~ 6: CMD B</string>",0
str04 BYTE "last Bus Watch~ 7: CMD Blast Single~ 8: Audio Player~ 9</string>",0
str05 BYTE ": Write text to Radio/NAV~ 10: Read EEPROM~ 11: Read E</string>",0
str06 BYTE "EPROM strings~ 12: Read KMB values~</string>",0
str07 BYTE "Read KMB~ 0: Return to Main Debug~ 1: Read Time Parsed</string>",0
str08 BYTE "~ 2: Read Date Parsed~ 3: Read Fuel Parsed~ 4: Read Ra</string>",0
str09 BYTE "nge Parsed~ 5: Check sync'ed time~</string>",0
str10 BYTE "(r)ead, (w)rite, or (e)xit?~</string>",0
str11 BYTE "Enter Address(0-500)</string>",0
str12 BYTE "Has Value: </string>",0
str13 BYTE "Enter new value: </string>",0
str14 BYTE "Done~</string>",0
str15 BYTE "w=CD Up, s=CD Down d=Track+, a=Track- 1=vol-, 2=vol+</string>",0
str16 BYTE " q=stop Track~r=Aux Mode, 3=Artist, 4= Album, </string>",0
str17 BYTE "5=Track, 6=Genre~</string>",0
str18 BYTE "Couldn't Mount SD Card!!~</string>",0
str19 BYTE "Enter String and press enter to write text to </string>",0
str20 BYTE "radio display~Or hit enter to go back</string>",0
str21 BYTE "Entering:Data Log Mode~</string>",0
str22 BYTE "Writing logfile Header~</string>",0
str23 BYTE "Writing logfile Entry~</string>",0
str24 BYTE "Entering: Connection Test Mode~</string>",0
str25 BYTE "Not Found - Nothing</string>",0
str26 BYTE "Prev Track</string>",0
str27 BYTE "Next Track</string>",0
str28 BYTE "Prev CD</string>",0
str29 BYTE "Next CD</string>",0
str30 BYTE "Change CD to #</string>",0
str31 BYTE "Change Aux</string>",0
str32 BYTE "Time Text</string>",0
str33 BYTE "Fuel Text</string>",0
str34 BYTE "Range Text</string>",0
str35 BYTE "Date Text</string>",0
str36 BYTE "(Kracker Vol+)</string>",0
str37 BYTE "(Kracker Vol-)</string>",0
str38 BYTE "Artist Name</string>",0
str39 BYTE "Album Name</string>",0
str40 BYTE "Track Name</string>",0
str41 BYTE "Genre</string>",0
str42 BYTE "NA</string>",0
str43 BYTE "NA</string>",0
str44 BYTE "NA</string>",0
str45 BYTE "NA</string>",0
str46 BYTE "Entered AuxIn Only Mode~</string>",0
str47 BYTE "Volume Set: </string>",0
str48 BYTE "Running with Remapper~</string>",0
str49 BYTE "Remaper disabled~</string>",0
str50 BYTE "Nothing, CD Announce~</string>",0
str51 BYTE "(CD Polled,Responded)</string>",0
str52 BYTE "(PowerDown,Stopped)</string>",0
str53 BYTE "(PowerUp,Stopped)</string>",0
str54 BYTE "Entering:Repeat Mode~</string>",0
str55 BYTE "Entering:Remapper Mode~</string>",0
str56 BYTE "Entering Music Mode~</string>",0
str57 BYTE "s + addr to view messages sent BY addr~</string>",0
str58 BYTE "d + addr to view messages sent TO addr~</string>",0
str59 BYTE "'r' to remove most recently set filter.  Up to five</string>",0
str60 BYTE "active filters~</string>",0

  
Pri EEPROM_set(addr,byteval)
setLED(99)
waitcnt(cnt + 200000)
i2cObject.writeLocation(EEPROM_ADDR, addr+EEPROM_base, byteval, 16, 8)
waitcnt(cnt + 200000)

Pri EEPROM_Read(addr) | eepromdata
setLED(199)

eepromdata := 0
eepromdata := i2cObject.readLocation(EEPROM_ADDR, addr+EEPROM_base, 16, 8)
waitcnt(cnt + 20000) 
return eepromdata


pri setLED(mode)
ledctrl := mode

      
PUB LEDnotifier  | switcher, i, delay
{{Notification Options:
23..20: Each LED    | 0:   All Off  |   1: Middle two |   2: Outer two
   199: Towards USB | 200: and back |  99: USB Away   | 100: And Back}}
delay~
dira[23..16] := %1111_1111



repeat
  case ~LEDctrl
     -1: outa[23..16] := %0000_0000
     1 : outa[23..16] := %0110_0000
     2 : outa[23..16] := %1001_0000
    99,100  :
         outa[23..16]:=  %1000_0000     
         waitcnt(clkfreq / 30 + cnt)     
         repeat 7                       
           waitcnt(clkfreq / 30 + cnt)   
           outa[23..16] ->= 1           
         IF ledctrl   == 100           
           waitcnt(clkfreq / 30 + cnt)
           repeat 7                    
             waitcnt(clkfreq / 30 + cnt)
             outa[23..16] <-= 1         
         outa[23..16] := %0000_0000
         LEDctrl~ 
    201 :
           outa[23..16] := %1010_1010
           repeat 4
              waitcnt(clkfreq / 30 + cnt)
              outa[23..16] ->= 1
              waitcnt(clkfreq / 30 + cnt)
              outa[23..16] <-= 1
           outa[23..16] := %0000_0000
           LEDctrl~

    199,200 :
      outa[23..16] := %0000_0001  
              waitcnt(clkfreq / 30 + cnt)          
              repeat 7                                        
                waitcnt(clkfreq / 30 + cnt)        
                outa[23..16] <-= 1                             

              IF ledctrl == 200                                                            
                waitcnt(clkfreq / 30 + cnt)                                     
                repeat 7                     
                  waitcnt(clkfreq / 30 + cnt)
                  outa[23..16] ->= 1         
              outa[23..16] := %0000_0000
              LEDCTRL~

    23..20 :  outa[23..20]~
              outa[ledctrl]~~  


DAT  'Config Mode text strings
get           BYTE "get",0
set           BYTE "set",0
sermon        BYTE "sermonitor",0
seroff        BYTE "seroff",0 
ComboBox      BYTE "ComboBox",0
CheckBox      BYTE "CheckBox",0  
testcmd       BYTE "TestCmd",0
sersend       Byte "sersend",0
serdone       Byte "serdone",0
default       Byte "default",0
modesel       BYTE "m",0
loadstrings   BYTE "loadstrings",0   


{{
                            TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
}}