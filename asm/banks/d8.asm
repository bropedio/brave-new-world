hirom

; D8 Bank

; ########################################################################
; Menu Font Palette Data

org $D8E800

MenuCGRAM:
.p0
  dw $0000,$0000,$39CE,$7FFF ; user editable color 
  dw $0000,$0000,$2108,$3DEF ; gray font for unavailable choiches
  dw $0000,$0000,$39CE,$03BF ; yellow font
  dw $0000,$0000,$39CE,$6F60 ; light blue font 
.p1
  dw $0000,$0000,$39CE,$6F60 ; light blue font
  dw $0000,$7FFF,$1084,$7FFF ; user editable color - vwf
  dw $0000,$0000,$39CE,$7FFF ; white font
  dw $0000,$0000,$39CE,$6F60 ; light blue font
.p2
  dw $0000,$0000,$2108,$3DEF ; gray font
.p3
  dw $0000,$3C00,$2108,$3DEF ; gray font with blue shadow
.p4
  dw $0000,$1084,$5294,$7FFF ; white font with gray shadow
.p5
  dw $0000,$0000,$39CE,$03BF ; yellow font (esper bonus points)
.p6
  dw $0000,$0000,$39CE,$7FFF ; white font

%free($D8E8A0)
