hirom

; Bank $E7

; ###########################################################################
; Battle Background Tile Formations and Pointers [?]

; ---------------------------------------------------------------------------
; Modified as part of `eddie-bg.asm` patch

org $E71862 : incbin bin/eddie-bg-tile-pointers.bin : warnpc $E718A9
org $E739CA : db $89 ; battle bg tile formations (compressed)
org $E73A3A : db $18 ; battle bg tile formations (compressed)
org $E73A61 : db $41 ; battle bg tile formations (compressed)
org $E73A81 : incbin bin/eddie-bg-tile-formations.bin : warnpc $E7A9DE
