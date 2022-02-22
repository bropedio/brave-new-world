hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Uses event command $66 to set a character's level equal to 18, unless they're over that level

; Change the pointer to free space
org $C09926
DB $13,$D6

org $C0D613
LDA $1D4D
BIT #$08		; If exp gains have been disabled, do nothing
BEQ Exit
JSR $9DAD		; Gets the character's info block and sets it in Y for indexing
LDA $1608,Y		; Get character's level
CMP #$12
BCS Exit		; If character's level is greater than or equal to 18, exit
DEC
STA $20
STZ $21
LDA #$12
STA $1608,Y		; Otherwise, set their level equal to 18.
JMP $9F4A		; Jump to vanilla's level averaging function to set new max HP/MP and check
				; for new spells (Celes/Terra).

Exit:
LDA #$02
JMP $9B5C

; EOF