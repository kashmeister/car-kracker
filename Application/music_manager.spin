''********************************************
''*  Music Manager 1.0                       *
''*  Author: Nick McClanahan (c) 2012        *
''*  See end of file for terms of use.       *
''********************************************
{-----------------REVISION HISTORY-----------------
1.0 - Initial Release
* Added Aux In - flip state with AuxIn Method
}


CON

  _clkmode = xtal1 + pll16x                             ' Crystal and PLL settings.
  _xinfreq = 5_000_000                                  ' 5 MHz crystal (5 MHz x 16 = 80 MHz).


  AudioBufferCog = 3

OBJ
  player : "audio_player.spin"
    
VAR
BYTE playerstatus
WORD CurrCD
WORD CurrTrack
LONG stack[90]
BYTE Aux
PUB start(vol) | i

Aux := FALSE
i := player.start(vol)
return i

PUB stop

stopplaying
player.stop

PUB settrack(CD,track) | tens, i 
tens := 0

IF CD > 0
    currCD := CD
    repeat while CD > 9
      tens++
      CD -= 10
    byte[@playfile]   := $30 + tens 
    byte[@playfile+1] := $30 + cd      

    byte[@CDnotplay+9]   := cd + (tens * 16)
    byte[@CDplaying+9]   := cd + (tens * 16)
    byte[@CDstartplay+9] := cd + (tens * 16)
    byte[@CDtrackend+9]  := cd + (tens * 16)
    byte[@CDseek+9]      := cd + (tens * 16)



tens := 0                        

IF track > 0
  currtrack := track
  repeat while track > 9
    tens++
    track -= 10
  byte[@playfile+3]   := $30 + tens 
  byte[@playfile+4]   := $30 + track
  byte[@CDnotplay+10]   := track + (tens * 16)
  byte[@CDplaying+10]   := track + (tens * 16)
  byte[@CDstartplay+10] := track + (tens * 16)
  byte[@CDtrackend+10]  := track + (tens * 16)
  byte[@CDseek+10]      := track + (tens * 16)



PUB notplayCode
return @CDnotplay

PUB playingCode
return @Cdplaying

PUB startplayCode
return @CDstartplay

PUB TrackENDCode
return @CDTrackEnd

PUB SeekingCode
return @CDSeek

PUB startsong
IF Aux == FALSE
  stopplaying
  waitcnt(clkfreq / 30 + cnt)  
  coginit(AudioBufferCog, bgplay, @stack)        
  waitcnt(clkfreq / 30 + cnt) 
  
PRI bgplay
player.play(@playfile)

PUB changevol(newval)
player.changevol(newval)
return TRUE

PUB trackcompleted
IF Aux == TRUE 
  return FALSE
ELSE  
  return player.checkplaying

PUB stopplaying
player.endtrack

PUB AuxIn
!AUX
stopplaying
RETURN AUX

DAT

playfile      BYTE "00_00.wav",0

'CD Status                                                        dd   tt  Disc (01-06 / track)
CDnotplay     BYTE $18, $0A, $68,  $39, $00, $02, $00, $3F, $00, $00, $00 
CDplaying     BYTE $18, $0A, $68,  $39, $00, $09, $00, $3F, $00, $00, $00
CDtrackend    BYTE $18, $0A, $68,  $39, $07, $09, $00, $3F, $00, $00, $00

CDseek        BYTE $18, $0A, $68,  $39, $08, $09, $00, $3F, $00, $00, $00        
CDstartplay   BYTE $18, $0A, $68,  $39, $02, $09, $00, $3F, $00, $00, $00