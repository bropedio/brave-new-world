hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Fixes the evade bug
; All locations have only been tested in FF3US ROM version 1.0
; Hack by Terii Senshi

org $C222D1
Miss:			; Code for missed attack

org $C2232C
BEQ NoImg		; Branch if the target does not have Image status
JSR $4B5A
CMP #$56		; 33% chance to clear Image status
BCS Miss
LDA $3DFD,Y
ORA #$04
STA $3DFD,Y		; Clears Image status
BRA Miss
LDA $3B55,Y		; 255 - (MBlock *2) + 1
PHA
BRA HitCalc
NoImg:
LDA $3B54,Y		; Handled in sei_tank_n_spank.asm - originally at C2/2345

org $C22348
PHA
NOP

org $C22388
HitCalc:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Removes evasion penalty from Life 3 status, and removes evasion bonuses from all status effects.

org $C2235E
PEA $0004

org $C22372
BRA No_Boost

org $C22388
No_Boost:

; EOF
