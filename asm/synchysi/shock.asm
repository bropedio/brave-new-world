hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Enables Leo's Crest to replace Runic with Shock
; Also modifies the Shock command to behave more like Cecil's Dark Wave from FF4

; Replaces Runic with Shock if Leo's Crest is equipped
org $C3619A			; Commands that can be replaced due to Relics
DB $0B				; Runic

org $C3619F			; Commands to replace above due to Relics
DB $1B				; Shock

; Greys out shock if the user doesn't have a runic-enabled weapon equipped
org $C252E2
DB $1B

org $C252EB
DB $22,$53

org $C35EE6
JSR Grey_Shock

; Force-enable Shock if a certain event bit is set - only for escape from FC sequence
org $C36176
JSR Shock_Chk

org $C3F17C
Shock_Chk:
LDA $1E9C			; Event byte (0E0 - 0E7) - Unused bits
BIT #$10			; Event bit 0E4 - used for enabling Shock during FC escape sequence
BEQ End				; If it's clear, exit
LDA #$10			; Else, set the requisite bit in $11D6
TSB $11D6

End:
LDA $11D6
RTS

Grey_Shock:
PHA
CMP #$1B
BNE Next
JMP $5F16

Next:
JMP $5F12

; Shock formula - ((3 * ((Level * stamina) + current HP)) / 4) & [Attacker takes 1/8th MHP damage.]
org $C24367
DB $DD,$3E

org $C23EDD
LDA $3B18,Y			; Attacker's level
XBA					; Place level in top nibble of A
LDA $3B40,Y			; Attacker's stamina
JSR $4781			; Top nibble of A * bottom nibble of A (Lvl * Stam)
REP #$20			; Set 16-bit A
ADC $3BF4,Y			; Result from above + cHP
STA $11B0
ASL
ADC $11B0			; Result from above * 3
LSR
LSR					; Result from above / 4
STA $11B0
LDA $3C1C,Y			; Attacker's max HP
LSR
LSR
LSR					; Max HP / 8
PHA
LDA $3BF4,Y			; Attacker's current HP
SEC
SBC $01,S			; Current HP - (Max HP / 8)
STA $3BF4,Y			; Store in current HP
BCS Exit			; If carry is clear, self-inflicted damage exceeded current HP
JSR $1390

Exit:
PLA					; Clear stack
RTS

; EOF
