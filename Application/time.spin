''********************************************
''*  Car Kracker Time Functions, V0.58       *
''*  Author: Nick McClanahan (c) 2012        *
''*  See end of file for terms of use.       *
''********************************************
CON
  _clkmode = xtal1 + pll16x                             ' Crystal and PLL settings.
  _xinfreq = 5_000_000                                  ' 5 MHz crystal (5 MHz x 16 = 80 MHz).

   MaxAlarms = 5
   multiplier = 1

VAR
LONG systemtimer
LONG nexttimecheck
BYTE epochdays
BYTE epochhours
BYTE epochmin
BYTE epochs
WORD epochms
LONG totalseconds

WORD Carhours
WORD Carminutes
LONG carsyncstatus

byte timestamp[11]
byte timetxtstamp[11]
byte hrdisplay
byte mastercog

'Will hold the minute the textstamp was last refreshed 
byte timestamprefresh


{
OBJ
  debug        : "DebugTerminal.spin"


PUB testrun | a, b, c, i, x, y, z, up
debug.StartRxTx(31, 30, %0000, 115200)  
start(12)
z := 2
synctime(@samplestamp2)
oneshot(@z, (z :=0) +4 )
oneshot(@x, (x :=0) + 7 )
repeat
  up := uptime
  wait(50)
  if up < uptime
    debug.newline
    debug.str(gettimestamp)

  IF oneshot(@z,4)
    debug.str(string("Triggered One shot z (10Sec) "))
  IF oneshot(@x,0)
    debug.str(string("Triggered One shot x no repeat "))

}

'If you call an unassigned alarm with a positive number, it won't work.
'Call it with a negative id, first

PUB start(hourstyle)
mastercog := cogid
BYTEfill(@epochdays, 0, 4)
epochms~
totalseconds~
timestamprefresh~
carsyncstatus~

hrdisplay := FALSE
IF hourstyle == 12
  hrdisplay := TRUE

ctra := %00110_000 << 23 + 31 << 9 + 31 'Establish mode duty
frqa := multiplier 
systemtimer := 0
refreshcheck


PUB oneshot(valptr, delay) | i
'Call with delay = -1 to release timer
'Call with delay => 0 to check / set timer

IF delay < 0
  long[valptr] := -1  
  return FALSE 

if delay => 0
  IF LONG[valptr] == -1
    return FALSE                ' Already triggered
  If LONG[valptr] == 0
    long[valptr] := uptime + delay      
    return FALSE
  IF uptime => LONG[valptr]
    if not delay
      long[valptr]~~
    else
      long[valptr]~     
    return TRUE
            '
PUB GetTimestamp
buildtimestamp
return @timestamp

PUB GetTimeText
'buildtimetext
'return @timetxtstamp
return @samplestamp  


pri buildtimestamp | i


i :=decimaltostring(epochhours,@timestamp) + @timestamp
 
BYTE[i++] := ":"
IF epochmin < 10
  BYTE[i++] := "0"  
i += decimaltostring(epochmin,i)
 
 
BYTE[i++] := ":"
IF epochs < 10
  BYTE[i++] := "0"                  
i += decimaltostring(epochs,i)
 
 
 
BYTE[i++] := "."              
If epochms < 100
  BYTE[i++] := "0"
IF epochms < 10
  BYTE[i++] := "0"
i += decimaltostring(epochms,i)
i := 0
 


pri buildtimetext | i, x

IF hrdisplay
  if carhours == 0
    x := 12
  if carhours > 12
    x -= 12
ELSE
  x := carhours

i :=decimaltostring(x,@timetxtstamp) + @timetxtstamp
BYTE[i++] := ":"
if carminutes < 10
  BYTE[i++] := "0"

i += decimaltostring(carminutes,i)
IF hrdisplay
  IF carhours > 11
    BYTE[i++] := "P"
  ELSE
    BYTE[i++] := "A"        
  BYTE[i++] := "M"    

BYTE[i++] := 0


PUB uptime  | i
{Time freom local epoch, in seconds}
return totalseconds  

 

PUB wait(ms) | endsecond
refreshcheck
endsecond := uptime

IF (ms += epochms) > 999
  endsecond += ms / 1000
  ms -= endsecond * 1000    

repeat until endsecond =< uptime
  refreshcheck
repeat until epochms => ms
  refreshcheck



PRI refreshcheck
IF mastercog <> cogid
  return FALSE

systemtimer += phsa~
repeat while systemtimer > 80000           
  systemtimer -= 80000
  IF ++epochms >  999
    epochms~
    ++totalseconds
    IF ++epochs > 59
      epochs~
      updatecarminute
      IF ++epochmin > 59
        epochmin~
        IF ++epochhours > 23
          epochhours~   
          ++epochdays
return TRUE

PRI updatecarminute
{{ Update our copy of the car's time when with each new minute}}
IF carsyncstatus
  IF ++carminutes > 59
    carminutes~
    IF ++carhours > 23
      carhours~   
 





PRI StrToBase(stringptr, base) : value | chr, index
{Converts a zero terminated string representation of a number to a value in the designated base.
Ignores all non-digit characters (except negative (-) when base is decimal (10)).}

  value := index := 0
  repeat until ((chr := byte[stringptr][index++]) == 0)
    chr := -15 + --chr & %11011111 + 39*(chr > 56)                              'Make "0"-"9","A"-"F","a"-"f" be 0 - 15, others out of range     
    if (chr > -1) and (chr < base)                                              'Accumulate valid values into result; ignore others
      value := value * base + chr                                                  
  if (base == 10) and (byte[stringptr] == "-")                                  'If decimal, address negative sign; ignore otherwise
    value := - value

Pri decimaltostring(value,strptr)  | i,x,strstart
strstart := strptr

  x := value == NEGX                                           
  if value < 0
    value := ||(value+x)                                       
    byte[strptr] := "-"
    strptr++    
                                                               
  i := 1_000_000_000                                           

  repeat 10                                                    
    if value => i
      byte[strptr] := value / i + "0" + x*(i == 1)             
      strptr++
      value //= i                                              
      result~~                                                 
    elseif result or i == 1
      byte[strptr] :="0"                                       
      strptr++
    i /= 10                                                    

byte[strptr] := 0
return strptr - strstart


PUB CarIsSynced
return carsyncstatus

PUB Synctime(strptr) | i, strlen
carhours := 0
strlen := strsize(strptr)

{{
if strlen == 0
  return -10
carsyncstatus := TRUE

carhours := 8
carminutes := 14


repeat i from 0 to strlen
  IF BYTE[strptr+i] == ":"
     carminutes := ((BYTE[strptr + i+1] -$30) * 10)
'     carminutes += BYTE[strptr + i+2] -$30) 
     carhours :=  (BYTE[strptr + i-1] -$30)   
'   IF BYTE[strptr + i-2] == $31
'    carhours += 10

  IF (BYTE[strptr+i] == "A") OR (BYTE[strptr+i] == "a")     
    IF carhours-- == 12
      carhours := 0

  IF (BYTE[strptr+i] == "P") OR (BYTE[strptr+i] == "p")
    IF (carhours += 12) == 24
      carhours :=  12
}}

DAT
samplestamp  BYTE "11:57PM",0
samplestamp3 BYTE "11:55PM",0    
samplestamp2 BYTE "11:55PM",0