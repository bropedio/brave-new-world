hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Modifies the cleave effect for the Zantetsuken to deal critical damage to enemies
; with the "Can't suplex" flag set.
; Set the Zantetsuken to do critical damage to bosses if the cleave effect procs.
; A boss is determined by whether they have the "Can't suplex" flag set.
; Also removes the "cleave" effect from the Odin summon animation.

org $C23DE7
DB $A3,$66

org $C202BC			; Undead killer weapon effect enters here due to 50% proc rate
LDA #$EE			; Separates cleave-kill from X-kill.
XBA
JSR $4B5A			; Random number 0-255.
CMP #$80
JMP Undead_Killer

org $C266A3
LDA #$EE			; Separates cleave-kill from X-kill.
XBA
JSR $4B5A			; Random number 0-255.
CMP #$40

Undead_Killer:
BCS Exit
LDA $3AA1,Y			; Check for instant death immunity.
BIT #$04
BNE Auto_Crit		; If the target is immune to instant death, set the attack to crit.
LDA #$7E
XBA
JMP $38A6			; Otherwise, execute cleave-kill.

Auto_Crit:
LDA $BC				; Check if the attack already crit.
BNE Exit			; If it did, exit.
INC $BC
INC $BC				; If not, set damage to double as though it did.
LDA #$20
TSB $A0				; Set screen to flash.

Exit:
RTS

; Removes the cleave effect from the Odin animation

org $C1B0E4
BRA No_Smn_Cleave

org $C1B0EC
No_Smn_Cleave:

; Moves the instant death pointer to space freed up by heal_rod.asm

org $C23E13
DW ID_Jump

org $C25310
ID_Jump:
STZ $341A

; EOF
