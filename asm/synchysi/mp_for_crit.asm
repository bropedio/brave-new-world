hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Changes the MP cost for MP-for-crit weapons to 1/2 the attacker's level.

org $C242EF
DB $25,$3F		; Change pointer to accomodate other changes
				; (see shock.asm and wpn_effects.asm)

org $C23F25
LDA $B2
BIT #$02
BNE Exit		; Exit function if "no critical and ignore true knight" is set.
LDA $3EC9
BEQ Exit		; Exit function if there are no targets.
TDC				; A = 0
LDA $3B18,Y
LSR				; Load attacker's level and divide it by 2.
REP #$20		; Set 16-bit A
STA $EE
JSR Think_Func	; Something about auto critting with a Gem Box? Written but not commented by Think
LDA $3C08,Y		; Attacker's current MP.
CMP $EE
BCC Exit		; Exit function if attack would drain more MP than the attacker has.
SBC $EE			; Subtract MP consumed from attacker's current MP.
STA $3C08,Y		; Current MP = current MP - (level / 2)
LDA #$0200
TRB $B2			; Set always critical.

Exit:
RTS

org $C202A2
Think_Func:
LDA $3C45,y
BIT #$0020
BEQ skip
LSR $EE
skip:
RTS

; EOF
