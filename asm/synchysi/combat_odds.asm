hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Simply changes the combat odds for the third and fourth formations in a pack to have 3/16 odds of showing up.
; All locations have only been tested in FF3US ROM version 1.0

org $C0C257
CMP #$D0

org $C0C3F0
CMP #$D0

; EOF
