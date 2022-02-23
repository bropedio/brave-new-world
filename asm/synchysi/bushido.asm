hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Checks the user for the gauntlet flag and hard sets it if it's present, using much of the space formerly used by the now-deprecated Retort
; Changes Cyan's Retort ability from a reactive counter-strike to a proactive ability like his other SwdTechs
; Renames SwdTech to Bushido in all menus
; All locations have only been tested in FF3US ROM version 1.0

org $C2185B
LDA $3C58,X
BIT #$08		; Check if the character should be getting the gauntlet bonus
BEQ End
LDA #$40
TRB $B3			; Set the gauntlet property
BRA End

org $C2187D
End:

; Change the word "SwdTech" to "Bushido" in all menus

org $C35C59
DB $8D,$7A,$81,$AE,$AC,$A1,$A2,$9D,$A8

org $C35CB8
DB $B7,$81,$81,$AE,$AC,$A1,$A2,$9D,$A8

org $C38E26
DB $2F,$82,$81,$AE,$AC,$A1,$A2,$9D,$A8

; Speeds up Cyan's Sword Tech gauge
; Hack by ArmorVil, modified by Synchysi for efficiency

org $C17D8A
JSR SwdTech

org $C1FFEC
SwdTech:
INC $7B82
LDA $7B82
ADC $36			; Adds the number of Sword Techs known to speed up the Sword Tech gauge
STA $7B82
RTS
NOP				; Why is this necessary? xkas won't write the previous instruction without something here, it seems

; EOF
