; Time Magic affects the ATB bar colors
; By Seibaby 2018-09-23
	; It also changes the endcaps on the ATB bar based on whether ATB is full or not.
; This requires two new glyphs in the 8x8 font tileset (the two tiles immediately following
; the ATB endcaps, left and right). The endcaps are changed so that the uncharged ones don't
; use colors 2 or 4, just the grey and transparency. Then the charged endcaps use colors
; 4 (the brightest) and optionally color 2 like the vanilla endcaps did.
	 
	; Palette color order
;       0: transparency
;       1: Text Drop shadow / ATB gauge outline
;       2: Text Grey magic dot / ATB gauge border
;       3: Text / ATB gauge core
	; $2EAF01: Palette #1: $21 - White text
; $2EAF09: Palette #2: $25 - Grey text
; $2EAF11: Palette #3: $29 - Yellow text / Full ATB gauge
; $2EAF19: Palette #4: $2D - Blue
; $2EAF21: Palette #5: $31 - All black (???)
; $2EAF29: Palette #6: $35 - White (charging) ATB gauge
; $2EAF31: Palette #7: $39 - Green Morph gauge
; $2EAF39: Palette #8: $3D - Red Condemned gauge (unused)
	hirom
header
	!freespace = $EEB15F
	; Add checks for statuses to ATB drawing routine
org $C16872
drawGauge:
         LDA $2021        ; ATB gauge setting
         LSR              ; Gauge enabled?
         BCC drawMaxHP    ; Branch if disabled
         LDA $3A8F        ; nATB: is ATB paused?
         LSR              ; (01 = paused)
         BCS .exit        ; Don't update bars while ATB is paused
         
         LDA $4E          ; Text color
         PHA              ; Save it
         LDA $18          ; Which character is it (0-3)
         TAX              ; Index it
         LDA $619E,X      ; Character's ATB gauge value
         PHA              ; Save it for later
         TXA              ; A = character 0-3
         ASL              ; Double it
         JSL newfunc
         macro newfunc()
         newfunc:
         TAX              ; Character index (0-6)
         LDA $3EF8,X      ; Status byte 3
         BIT #$10         ; Is Stop status set?
         BEQ .slow        ; Branch if not Stopped
         LDA #$3D         ; Select palette #8           STOPPED
         BRA .store       ; Store palette
.slow    LDA $3EF8,X      ; Status byte 3
         BIT #$04         ; Is Slow status set?
         BEQ .haste       ; Branch if not Slowed
         LDA #$2D         ; Select palette #4           SLOW
         BRA .store       ; Store palette
.haste   LDA $3EF8,X      ; Status byte 3
         BIT #$08         ; Is Haste status set?
         BEQ .normal      ; Branch if not Hasted
         LDA #$39         ; Select palette #7           HASTE
         BRA .store       ; Store palette
.normal  LDA #$35         ; Select palette #6           NORMAL
.store   RTL
         endmacro
         STA $4E          ; Store palette
         PLA              ; Restore ATB gauge value
         JSR $6854        ; Draw the gauge
         PLA              ; Get saved text color
         STA $4E          ; Store text color
.exit    RTS
         print "c1/6872 ends at: ", pc,", should be c16898"
	org $C16898
drawMaxHP:
LDA #$C0                  ; Draw a "/" as HP divider
	; Endcaps stuff
org $C16854
endcaps:
PHA
JSL newfunc2
	macro newfunc2()
newfunc2:
LSR A
AND #$FC
TAX
LDA $04,S
INC
BEQ .leftfull
LDA #$F9
BRA .drawleftcap
.leftfull
LDA #$FB
.drawleftcap
RTL
endmacro
	JSR $66F3      ; Draw opening end of ATB gauge
LDA #$04
STA $1A
.loop
LDA $C168AC,X  ; Get the ATB gauge character
JSR $66F3      ; Draw tile A
INX
DEC $1A        ; Decrement tiles to do
BNE .loop      ; Branch if we haven't done 4
PLA
JML newfunc3
macro newfunc3()
newfunc3:
INC
BEQ .rightfull
LDA #$FA
BRA .drawrightcap
.rightfull
LDA #$FC       ; Draw tail end of ATB gauge
.drawrightcap
JML $C166F3    ; Draw tile A
endmacro
NOP
print "c1/6854 ends at: ",pc,", should be c16872"
	
; Relocate 2bpp palettes
org !freespace
print "palettes written to ",pc
palettes:
incbin palettes-bnw.bin       ; Use SNESpal to edit the palettes
print "new code written to ", pc
%newfunc()
%newfunc2()
%newfunc3()
	org $C140A8
LDA palettes,X            ; Load battle text palettes white and gray
	org $C140AF
LDA palettes+16,X         ; Load battle text palettes yellow and cyan
	org $C14100
LDA palettes+40,X         ; Load battle gauge palette
