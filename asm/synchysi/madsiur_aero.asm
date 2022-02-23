hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Speeds up the aero animation

org $D015DE
DB $89,$20

org $D015FC
DB $89,$60

org $D01611
DB $89,$03
