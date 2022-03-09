hirom

; C1 Bank

; ########################################################################
; Rage Battle Menu
;
; Modify max scroll value for shortened rage battle menu (dn)

org $C184F9 : CMP #$1C ; (64 rages / 2) - 4(onscreen)

; ########################################################################
; Damage number color palette routine
;
; Intercept to check for new MP dmg flag at bit6, part of Imzogelmo's 
; "MP Colors" patch

org $C12D2B : NOP : NOP : JSL PaletteMP
org $C12B9B : NOP : NOP : JSL PaletteMP_mass

; #######################################################################
; Battle Dynamics Commands Jump Table

; Add aliases for existing damage number commands
; Part of "MP Colors" patch

org $C191A0 : dw $A4B3  ; battle dynamics $05, alias to $0B (cascade)
org $C191A6 : dw $9609  ; battle dynamics $08, alias to $03 (mass)

; ######################################################################
; Damage Numbers Animation Handler(s)

; Add MP dmg flags based on battle dynamics command ID, for MP Colors
; patch

org $C1A5A9 : NOP : JSL SetMPDmgFlag
org $C1A6E6 : NOP : JSL SetMPDmgFlagMass
