hirom

; Patch: Minimap
; Author: Madsiur
; Editor: Bropedio
;
; Add mountain colors to the minimap.
;
; The original IPS for this patch modified more code than was strictly
; necessary, possibly as a result of an overly aggresive tool of some
; sort. This edited version is slimmer and only changes what is needed.

; Modify some WoB minimap colors
; TODO: Maybe tweak WoR colors, too
org $D2EEA4
  dw $294A,$35AD,$4E73,$7FFF,$294A,$35AD,$4E73,$7FFF,$5AD6
warnpc $D2EEB6

; Modify Sealed Gate removal helper to remove Mountain color, too
org $EE9B06
SetSeaColors:
  LDX #$0006
.loop
  STA.l $7EE1AC,X
  DEX #2
  BPL .loop
  NOP
warnpc $EE9B12

; ---------------------------------------------------------------------------
; Adjust pointer WOR minimap graphics
org $EEB24E : dw $E90E : db $EF

; ---------------------------------------------------------------------------
; Write updated minimap graphics (compressed)
; Note that the footprint is smaller, so Falcon graphics can stay
; Note we *could* shift and recompress them to free up more space
org $EFE49B : incbin bin/minimap-wob.bin ; 1139 length
org $EFE90E : incbin bin/minimap-wor.bin ; 865 length
