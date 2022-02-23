hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Forces magic attacks to take defending targets into consideration
; Changes the back row defense boost from 50% damage reduction to 25%
; Also changes the order of some damage modification checks, and removes
; the 1.5x multiplier enemies get to their magic power.

; Damage modification check order:
; Defend - Row - Morph

org $C20CFF
LDA $3AA1,Y
BIT #$02
BEQ NoDef		; Branch if target not defending.
LSR $F1
ROR $F0			; Cut damage in half.

NoDef:
PLP
BCC SkipRow		; Skip row check if magical attack.
BIT #$20
BEQ SkipRow		; Branch if target is in the front row.
JSR Row_Dmg		; Else, lower damage by 25%
NOP

; $C2/0D15
SkipRow:		; Following is the morph check, handled in morph.asm

org $C250F4
Row_Dmg:
PHP
REP #$20		; 16-bit A
LDA $F0			; Damage
LSR
LSR
EOR #$FFFF
SEC
ADC $F0
STA $F0			; Subtract 1/4 damage
PLP
RTS

; Removes the 1.5x spell power enemies get
org $C22D30
NOP #3

; EOF
