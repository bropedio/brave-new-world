hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Adjusts various Mog-related mechanics.
; All locations have only been tested in FF3US ROM version 1.0

; Runs a check to see if the attacker is jumping, and then checks for the Moogle Charm
; to adjust the wait timer if applicable.
org $C203EE
JSR Charm_Chk

org $C23A9E
Charm_Chk:
XBA
CMP #$16
BNE No_Jump
LDA $3C59,X
BIT #$20
BEQ No_Charm_Jump
LDA #$0E
BRA No_Jump

No_Charm_Jump:
LDA #$16

No_Jump:
CMP #$1E
RTS

; Changes the odds each dance step shows up.
org $C205CE
DL $104090		; 10/FF; 30/FF; 60/FF

; Prevents the Dance status from being set if the Moogle Charm is equipped.
org $C219ED		; Point of origin for Dance.
DB $82,$3C

org $C23C82
LDA $3C59,Y
BIT #$20
BNE Exit_Chk	; If the dancer has the Moogle Charm equipped, don't set the Dance status.
JMP $177D

Exit_Chk:
JMP $1785

; Ties a dancer's success of dancing on non-native terrain to their stamina.
org $C2179D
JSR Dance

org $C23AB3
Dance:
PHA
JSR $4B5A		; RNG 0 - 255
PHA
LDA $3B40,Y		; Load dancer's stamina
ASL
ADC #$60		; A = (Stam * 2) + 96
BCS End			; If carry is set, then then dancer will automatically succeed, so end
CMP $01,S

End:
PLA
PLA
RTS

; EOF
