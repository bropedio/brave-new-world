hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Changes the odds Rage will select a certain attack from 50/50 to any desired split (examples in comments)
; All locations have only been tested in FF3US ROM version 1.0
; Uses 8 bytes of free space

org $C20600
JSR Rage

org $C23978
Rage:
PHA
JSR $4B5A		; 0-255 RNG
; CMP #$C0		; 75% chance of the carry being clear
CMP #$AB		; ~67% chance of the carry being clear
; CMP #$A0		; 62.5% chance of the carry being clear
; CMP #$9A		; ~60% chance of the carry being clear
				; Carry is set by default, and the CMP operand is subtracted from the RNG result
				; If the RNG returns a number smaller than the operand, it will need to borrow from (read: clear) the carry
				; A clear carry means the ability in Rage slot 1 will be used
PLA
RTS

; EOF
