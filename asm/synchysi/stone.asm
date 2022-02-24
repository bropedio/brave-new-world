hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Rearranges Stone in the magic list to show up with the other black magic spells

; Re-ordering magic menu in battle
org $C255BD
CMP #$19

; Spell placement for battle menu - see commentary at C2/574B
org $C2574B
DB $09,$1D,$00,$00,$1D,$14		; Black magic placement
DB $09,$F0,$00,$09,$E7,$E7		; Grey magic placement
DB $D3,$D3,$00,$EC,$E7,$00		; White magic placement

; Data table for magic order in menus
org $C34F49
DB $2D,$00,$19,$FF
DB $2D,$19,$00,$FF
DB $00,$19,$2D,$FF
DB $00,$2D,$19,$FF
DB $19,$2D,$00,$FF
DB $19,$00,$2D,$FF

org $C34F69
LDX #$0014			; The number of grey magic spells

org $C34F6E
LDX #$0019			; The number of black magic spells

; EOF