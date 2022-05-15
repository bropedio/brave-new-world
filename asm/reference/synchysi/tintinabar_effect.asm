hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Removes the effect that causes item #229 to heal the wearer with each step.

org $C04A65
BRA Cont

org $C04A93
Cont:
