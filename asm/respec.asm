hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Uses event command $67 to reset the available ELs for the current party

; Change the pointer to free space
org $C09928
DB $36,$D6

org $C0D636
LDA #$16
STA $4202
LDA $EB			; Character ID
STA $4203
TAY
LDA $1D10,Y		; Get character's total esper levels
STA $1D1C,Y		; Store that in available esper levels
NOP
LDX $4216
PHX
JSR $9DAD		; Gets the character's info block and sets it in Y for indexing
PLX
LDA $ED7CA6,X	; Character's base vigor
STA $161A,Y
LDA $ED7CA7,X	; Character's base speed
STA $161B,Y
LDA $ED7CA8,X	; Character's base stamina
STA $161C,Y
LDA $ED7CA9,X	; Character's base magic
STA $161D,Y
LDA $ED7CA0,X	; Character's base level 1 HP
STA $160B,Y
LDA $ED7CA1,X	; Character's base level 1 MP
STA $160F,Y
TDC
STA $160C,Y
STA $1610,Y
STZ $20
STZ $21
LDA $1608,Y		; Get character's level
JMP $9F4A		; Jump to vanilla's level averaging function to set new max HP/MP and check
				; for new spells (Celes/Terra).

Exit:
LDA #$02
JMP $9B5C

; EOF