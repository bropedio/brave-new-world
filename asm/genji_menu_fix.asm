hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Makes the equip screen render properly when dealing with dual wield-enabled equipment
; All locations have only been tested in FF3US ROM version 1.0

org $C39A5D
JSR Wpn_Index

org $C39A90		; Right hand
JMP DW_Chk_RH

org $C39ABC		; Left hand
JMP DW_Chk_LH

org $C3F137
Wpn_Index:
LDA $1869,X
;STA $1D1D
STA $A3				; Store weapon index
RTS

; C3F4A1
DW_Chk_RH:
LDA $0020,Y			; Load index of weapon in left hand (if applicable)
BRA Item_Chk

DW_Chk_LH:
LDA $001E,Y			; Load index of weapon in right hand (if applicable)

Item_Chk:
PHA					; Preserve A
;LDA $1D1D
LDA $A3
CMP #$5A			; Check if current item in equipment list is a weapon
PLA					; Restore A
BCS Allow			; If not, allow all equippables
LDA $D8500C,X		; Load weapon properties - special byte 3
AND #$18			; Isolate the genji glove and gauntlet flags
CMP #$08			; Check for only gauntlet property (i.e., a spear)
BEQ Exit			; If enabled, disallow all off-hand weapons
CMP #$10			; Check for dual wield property
BEQ Spear_Chk
JSR Get_Wpn_Offset	; We've reached here if a weapon either 1) has neither the gauntlet or genji glove flags enabled, or 2) is a katana, and therefore has both flags enabled
CMP #$10			; Check for dual wield property of weapon in equipment list
BEQ Allow			; If enabled, allow the current weapon in the off hand; otherwise, disallow it

Exit:
CLC					; Carry clear = unequippable
RTS

Spear_Chk:			; Only ran for main-hand dual wield-enabled weapons
JSR Get_Wpn_Offset
CMP #$08
BEQ Exit

Allow:
SEC					; Carry set = equippable
RTS

Get_Wpn_Offset:
;LDA $1D1D
LDA $A3				; Load index of weapon in equipment list
JSR $8321			; Multiply by 30 for equipment properties offset
LDX $2134			; Load offset into X
LDA $D8500C,X		; Load weapon properties - special byte 3
AND #$18			; Isolate the genji glove and gauntlet flags
RTS

; EOF