hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Makes the Moogle Suit no longer turn the wearer into a moogle
; All locations have only been tested in FF3US ROM version 1.0

org $C22872
BRA NoMog

org $C22883
NoMog:

; EOF