; #########################################################################
; Yellow Palette for BG1
;
; Original author: Ryo
; Expanded and Optimized by: Bropedio
; 11/3/23

; -------------------------------------------------------------------------
; Load Gauge Color Palette
;
; Optimizing the palette data at $D8E800 shifted palette 4's
; data into a new spot

org $C33967 : LDA.l MenuCGRAM_p4,X ; New location for palette 4

; #########################################################################
; Load Font and Background Color Palettes
;
; Remove writes to CGRAM, which are handled by NMI (TODO: is this safe?)

org $C36BBC
ResetSkinColors:
  PHP               ; store flags
  REP #$21          ; 16-bit A, clear carry
  LDX #$0008        ; skins left: 8
  STX $E7           ; set counter
  LDY #$1D57        ; destination address
  LDX #$1C02        ; source address
.chunk
  LDA #$000D        ; size of 7-color chunk (-1)
  MVN $7E,$ED       ; move from ED1C02,X to 7E1D57,Y
  TXA               ; source address
  ADC #$0012        ; reach next skin
  TAX               ; update source index
  DEC $E7           ; decrement iterator
  BNE .chunk        ; loop till all 8 skins moved
  SEP #$20          ; 8-bit A
  RTS

LoadPalHelp:
  REP #$21          ; 16-bit A, clear carry
  LDA #$0005        ; number of blocks we will be moving
  STA $E3           ; zero iterator
  RTS
warnpc $C36BE8

!t_d8 = MenuCGRAM>>16

org $C36BE8
LoadPalettes:       ; [36 bytes]
  PHP               ; store flags
  PHB               ; store current databank
  JSR LoadPalHelp   ; prepare iterator
  LDX #MenuCGRAM    ; source offset
  LDY #$3049        ; destination offset
  LDA #$0047        ; 64+8 bytes to move (all BG3 palettes, plus third BG1)
.loop
  MVN $7E,!t_d8     ; move block of palette colors (72 or 8)
  TYA               ; prepare to skip some destination bytes
  ADC #$0018        ; skip to next 4bpp palette offset (carry stays clear)
  TAY               ; update destination offset
  LDA #$0007        ; next MVN should move 8 bytes
  DEC $E3           ; decrement iterator
  BNE .loop         ; loop until all chunks moved
  PLB               ; restore databank
  PLP               ; restore flags
  RTS
warnpc $C36C09

; Rewrite routine to assume yellow palette exists (it does now)
org $C3F46A
DrawEsperName:
  LDA #$24          ; "blue" palette
  STA $29           ; set palette color
  STA $29           ; set palette color
  PHY               ; store tile position
  JSR $34CF         ; draw character name
  LDA #$34          ; "yellow" palette
  STA $29           ; set palette color
  REP #$21          ; 16-bit A, clear carry
  PLA               ; get tile position
  ADC #$0020        ; advance 16 spaces
  TAY               ; store new tile position
  SEP #$20          ; 8-bit A
  JSR $34E6         ; draw esper name 
  LDA #$20          ; "white" palette
  STA $29           ; set palette color
  RTS

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

warnpc $D8E8A0
