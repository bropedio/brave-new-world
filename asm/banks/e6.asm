hirom

; E6 Bank

; ########################################################################
; Freespace (?)

; ------------------------------------------------------------------------
; Helpers for Ebot's Rock Coral event changes

org $E6CD3D
CoralHelper1:
  db $D3,$D8          ; clear event bit $1D8 (removes coral from rare items)
  db $B2 : dl $017137 ; JSR $CB7137
  db $FE              ; RTS
org $E6CD44
CoralHelper2:
  db $C0,$D8,$01      ; if !(coral in rare items)
  dl $01711B          ; JMP $CB711B
  db $EB,$07,$15,$00  ; compare $1FC2 variable to 0x0015
  db $BE,$03          ; if in caseword (3 checks)
  dw $7127 : db $21   ; less than: JSR $CB7127
  dw $7127 : db $01   ; equal to:  JSR $CB7127
  dw $7141 : db $11   ; more than: JSR $CB7141
  db $FE              ; RTS

; ------------------------------------------------------------------------
; Helper for `drained-pool-tile.asm` bugfix

org $E6F1A0
  db $74,$31,$6A,$01,$01 ; [x] Replace Layer 2 at (49, 106) with 1x1 chunk
  db $01                 ; [>] The chunk for ^
  db $74,$2D,$A7,$01,$02 ; [+] Replace Layer 2 at ($2D, $A7) with 1x2 chunk
  db $00,$00             ; [+] The chunk for ^
  db $75                 ; [+] Refresh map after alteration (TODO: needed?)
  db $FE                 ; [+] RTL
warnpc $E6F1AF
