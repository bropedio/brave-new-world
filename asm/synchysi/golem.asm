hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Alters the Golem Wall effect to use the caster's max HP instead of current

org $C23F67
LDA $3C1C,Y

; EOF