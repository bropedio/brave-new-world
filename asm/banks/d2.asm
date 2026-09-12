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
org $D2EEA4
  dw $294A,$35AD,$4E73,$7FFF,$294A,$35AD,$4E73,$7FFF,$5AD6
warnpc $D2EEB6
