hirom

; Patch: Drained Pool Tile
; Author: Gi Nattak
; From: drained-pool-tile.ips
;
; Corrects a map tile after the pool of water is drained from
; the Serpent Trench cave and the menu is opened & closed.

org $CA8AD5 : db $F7 ; background scroll speed reduced?

org $CAEE83
  db $B2,$A0,$F1,$1C         ; JSL $E6F1A0 [see below]
  db $FE                     ; RTL
  db $FF,$FF                 ; freespace

org $E6F1A0
  db $74,$31,$6A,$01,$01 ; [x] Replace Layer 2 at (49, 106) with 1x1 chunk
  db $01                 ; [>] The chunk for ^
  db $74,$2D,$A7,$01,$02 ; [+] Replace Layer 2 at ($2D, $A7) with 1x2 chunk
  db $00,$00             ; [+] The chunk for ^
  db $75                 ; [+] Refresh map after alteration (TODO: needed?)
  db $FE                 ; [+] RTL
warnpc $E6F1AF
