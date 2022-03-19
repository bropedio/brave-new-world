org $C4AFC3

table c3.tbl,rtl

dw Earth : dw Fire
dw Wind : dw Water
dw Ruin : dw Love
dw Soul : dw Mad

; Alternate format: odds prefixed
; Earth: db "7/16: Harvester, 5/16: Razor Leaf",$01,"3/16: Moonlight, 1/16: Raccoon",$00
; Fire: db "7/16: Fireball, 5/16: Elf Fire",$01,"3/16: Mirage, 1/16: Meerkat",$00
; Water: db "7/16: El Nino, 5/16: Plasma",$01,"3/16: Surge, 1/16: Toxic Frog",$00
; Wind: db "7/16: Mirage, 5/16: Sun Bath",$01,"3/16: Wind Slash, 1/16: Rabbit",$00
; 
; Love: db "7/16: Sun Bath, 5/16: Moonlight",$01,"3/16: Harvester, 1/16: Cockatrice",$00
; Ruin: db "7/16: Avalanche, 5/16: Surge",$01,"3/16: Sirocco, 1/16: Wild Boars",$00
; Soul: db "7/16: Bedevil, 5/16: Elf Fire",$01,"3/16: Devour, 1/16: Tapir",$00
; Mad: db "7/16: Cadenza, 5/16: Devour",$01,"3/16: Sirocco, 1/16: Wombat",$00

; Current format: odds suffixed
Earth: db "Harvester: 7/16, Razor Leaf: 5/16",$01,"Moonlight: 3/16, Raccoon: 1/16",$00
Fire: db "Fireball: 7/16, Elf Fire: 5/16",$01,"Mirage: 3/16, Meerkat: 1/16",$00
Wind: db "Mirage: 7/16, Sun Bath: 5/16",$01,"Wind Slash: 3/16, Rabbit: 1/16",$00
Water: db "El Nino: 7/16, Plasma: 5/16",$01,"Surge: 3/16, Toxic Frog: 1/16",$00

Ruin: db "Avalanche: 7/16, Surge: 5/16",$01,"Sirocco: 3/16, Wild Boars: 1/16",$00
Love: db "Sun Bath: 7/16, Moonlight: 5/16",$01,"Harvester: 3/16, Cockatrice: 1/16",$00
Soul: db "Bedevil: 7/16, Elf Fire: 5/16",$01,"Devour: 3/16, Tapir: 1/16",$00
Mad: db "Cadenza: 7/16, Devour: 5/16",$01,"Sirocco: 3/16, Wombat: 1/16",$00