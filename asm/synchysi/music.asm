hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Expands the total number of songs the game can use and adds a pointer to the new song
; Music by Jackimus

org $C53C5E
DB $56

org $C53F95
DB $06,$F8,$D4

; EOF
