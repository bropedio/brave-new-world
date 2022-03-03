hirom

; C0 Bank

; #########################################################################
; Diagonal Movement Handlers
;
; Modified to add various handling to diagonal movement (eg on stairs)
; Original patch by Lenophis

org $C0496A
FancyWalking:
  JSR $4A03 ; add to step count, deal with poison damage, save point use, etc
  LDA #$01
  STA $57
  STZ $078E
  RTS
padbyte $FF : pad $C04978
warnpc $C04978+1

; #########################################################################
; General Actions pointer updates
;
; Action $7F (Change Character Name) is optimized and shifted to make
; room for a fix to Action $8D (Unequip Character).

org $C09958 : dw CharName

; #########################################################################
; Unequip Character (General Action $8D) [end of routine]
;
; Leet Sketcher's "Unequipium" patch adds handling at the end of this
; routine to ensure equipment properties and stat changes are removed
; when the equipment is removed.

org $C0A035
 	LDA $EB          ; character ID
 	JSL $C20006      ; recalculate properties from equipment
 	LDA #$02         ; args to advance
  BRA Advance      ; advance script

; #########################################################################
; Character Name Change (General Action $7F)
;
; Shifted and optimized to make room for code directly above. Otherwise
; unchanged. Note that the "Advance" label is now used by the code above.

CharName:
  JSR $9DAD        ; [?]
  LDA $EC          ; character ID
  PHA              ; store on stack
  STA $4202        ; save multiplicand
  LDA #$06         ; length of name
  STA $4203        ; multiply
  STA $EC          ; initialize counter
  NOP #2           ; wait for multiplication
  LDX $4216        ; offset to name
  PHX              ; store X
  PHY              ; store Y

.loop
  LDA $C478C0,X    ; next name char
  STA $1602,Y      ; save character name
  INX              ; next source index
  INY              ; next SRAM index
  DEC $EC          ; six characters total
  BNE .loop        ; loop through all 6 chars
  PLY              ; restore Y
  PLX              ; restore X
  PLA              ; restore $EC
  STA $EC          ; restore $EC value
  LDA #$03         ; advance script by 3

Advance:
  JMP $9B5C        ; advance script

padbyte $EA : pad $C0A07C
warnpc $C0A07C+1
