hirom

; D2 Bank (data)

; Compressed tile data
; Current miss tiles input starts at D2E000
; 097C is offset to instruction to fill 00s

org $D2E000
BattleStatusGraphics:
incbin bin/battle-status-graphics.bin

