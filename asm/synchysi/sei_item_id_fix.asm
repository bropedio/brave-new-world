;xkas 0.06
hirom
header
	; Index of Optimize-excluded gear
org $ED82E4
db $66      ; 102 Hero Shield (cursed)
db $24      ; 36  Pointy Stick
db $65      ; 101 Multiguard
db $9B      ; 155 Lazy Shell
db $1C      ; 28  Atma Weapon
db $33      ; 51  Spook Stick
db $17      ; 23  Omega Weapon
db $FF
db $FF
db $FF
db $FF
db $FF
db $FF
db $FF
db $FF
db $FF
	; Draw weapon's Bat.Pwr in gear data menu
org $C387A3
CMP #$1C       ; Atma Weapon?
org $C387A7
CMP #$17       ; Omega Weapon?
org $C387AB
CMP #$51       ; Dice?
org $C387AF
CMP #$52       ; Fixed Dice?
