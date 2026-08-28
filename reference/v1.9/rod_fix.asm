hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Alters using rods as items to no longer pierce defense
; All locations have only been tested in FF3US ROM version 1.0

org $C21897
NOP #3			; NOP'ing out the instruction that ignores damage modifications

org $C218C1
JSR Item		; Carry is set at this point for Throw or Tools

org $C20557
Item:
BCS No_Item
STZ $3414		; Ignore modifiers if an actual item is being used

No_Item:
LDA $3411		; Diplaced code from the JSR above
RTS

; EOF
