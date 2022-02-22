hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Changes the threshold to uncurse the Cursed Shield from 256 battles to 64
; All locations have only been tested in FF3US ROM version 1.0

org $C25FFE
XBA					; Top of A holds Cursed Shield ID, as we're only here if the Cursed Shield is equipped
INC $3EC0			; Increment number of battles fought with Cursed Shield
LDA $3EC0
CMP #$40			; Is it equal to 64?
BNE No_Change		; If not, branch
JSR Change_Shld		; If so, replace the Cursed Shield with the Paladin Shield

org $C2600D
No_Change:

org $C23C78
Change_Shld:
LDA #$01
TSB $F0
LDA #$67
STA $161F,X
RTS

; EOF