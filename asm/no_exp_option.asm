hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Modifies the double exp code to grant zero exp for some reason.
; Also enables a "No Exp." option in the menu, removing the need for No Exp. Eggs

;org $C349F1		; Text for "Off"
;DB $A5,$39,$8E,$9F,$9F,$00

; The above is for documentation purposes only. The actual text change is in dash.asm

;org $C349AA		; Text for "Exp Gain"
;DB $8F,$39,$84,$B1,$A9,$C5,$86,$9A,$A2,$A7,$00

;org $C34918		; Text for "On"
;DB $B5,$39,$8E,$A7,$00

; The above is now handled in bnw_config_remove_battle_speed.asm

org $C25E4C
LDA $1D4D
BIT #$08		; Check if exp gains have been disabled
BEQ No_Exp		; Branch past the function that adds experience if it is
JSR $6235		; If not, grant exp as normal.
NOP	#3			; Dummying out excess instructions.

No_Exp:

; EOF