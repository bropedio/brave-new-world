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
!land_drk = $294A
!land_med = $35AD
!mtn_edge = $4E73
!location = $7FFF

org $D2EEA2
  dw $1084     ; sea
  dw !land_drk ; land, dark
  dw !land_med ; land, medium
  dw !mtn_edge ; mountain edge
  dw !location ; location
  dw !land_drk ; land, dark (sealed cave)
  dw !land_med ; land, medium (sealed cave)
  dw !mtn_edge ; mountain edge (sealed cave)
  dw !location ; location (sealed cave)
  dw $5AD6     ; mountain, light
warnpc $D2EEB6

; Modify Sealed Gate removal helper to remove Mountain color, too
org $EE9B06
SetSeaColors:
  STA.l $7EE1A4    ; needed for sealed cave pixel -- but why?
  LDX #$0006
.loop
  STA.l $7EE1AC,X
  DEX #2
  BPL .loop
  NOP
warnpc $EE9B12

; ---------------------------------------------------------------------------
; Adjust pointer WOR minimap graphics
org $EEB24E : dw $E910 : db $EF

; ---------------------------------------------------------------------------
; Write updated minimap graphics (compressed)
; Note that the footprint is smaller, so Falcon graphics can stay
; Note we *could* shift and recompress them to free up more space
org $EFE49B : incbin bin/minimap-wob.bin ; 1141 length
org $EFE910 : incbin bin/minimap-wor.bin ; 865 length
