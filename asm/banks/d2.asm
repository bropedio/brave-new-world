hirom

; D2 Bank (data)

; Compressed tile data
; Current miss tiles input starts at D2E000
; 097C is offset to instruction to fill 00s

org $D2E000
BattleStatusGraphics:
incbin bin/battle-status-graphics.bin

; ---------------------------------------------------------------------------
; Misc WoB Palettes

; Modify some WoB minimap colors
; From `minimap.asm`

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
