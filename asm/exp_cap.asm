hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Changes the experience cap from 15,000,000 to 999,999.

org $C26276
DB $3F,$42,$0F

; EOF