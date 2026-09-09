hirom

; Patch: Eddie Background
; Author: Gens
; From: eddit-bg.ips
;
; $D744E8:$D744FA - Field Sprite Graphics
; $D7AB83:$D7AB9A - Field Sprite Graphics
; $E68000:$E68002 - Character Color Palettes
; $E68021:$E68022 - Character Color Palettes
; $E68081:$E68082 - Character Color Palettes
; $E71862:$E718A9 - Pointers to Battle BG Tile Formations
; $E739CA:$E739CB - Battle BG Tile Formations (compressed)
; $E73A3A:$E73A3B - Battle BG Tile Formations (compressed)
; $E73A61:$E73A62 - Battle BG Tile Formations (compressed)
; $E73A81:$E7A9DE - Battle BG Tile Formations (compressed)
; $E935D6:$E935E5 - Battle BG Graphics (compressed)
; $E93651:$E93652 - Battle BG Graphics (compressed)
; $E93678:$E9454B - Battle BG Graphics (compressed)
; $E9461E:$E94620 - Battle BG Graphics (compressed)
; $E94752:$E94753 - Battle BG Graphics (compressed)
; $E94776:$E955E9 - Battle BG Graphics (compressed)
;
; This is my masterpiece: Eddie face appears in all its splendor
; into the Final Kefka battle background

org $D744E8 : db $34 ; field sprite gfx
org $D744F8 : db $38,$F8 ; field sprite gfx
org $D7AB83 : db $0F,$19,$0E,$1B,$0E,$1F,$06 ; field sprite gfx
org $D7AB93 : db $0F,$08,$06,$00,$0E,$00,$06 ; field sprite gfx
org $E68000 : dw $0000 ; zero out some color palette bytes
org $E68020 : dw $0000 ; zero out some color palette bytes
org $E68080 : dw $0000 ; zero out some color palette bytes
org $E71862 : incsrc eddie-bg-tile-pointers.bin
org $E739CA : db $89 ; battle bg tile formations (compressed)
org $E73A3A : db $18 ; battle bg tile formations (compressed)
org $E73A61 : db $41 ; battle bg tile formations (compressed)
org $E73A81 : incsrc eddie-bg-tile-formations.bin
org $E935D6 ; battle bg gfx (compressed)
  db $75,$0f,$ff,$00,$ff,$00,$ff,$01,$fe,$07,$f8,$f8,$de,$0f,$e8
org $E93651 : db $FB
org $E93678 : incsrc eddie-bg-gfx-1.bin
org $E9461E : db $CC,$0F ; battle bg gfx (compressed)
org $E94752 : db $79 ; battle bg gfx (compressed)
org $E94776 : incsrc eddie-bg-gfx-2.bin
