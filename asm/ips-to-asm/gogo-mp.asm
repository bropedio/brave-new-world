hirom

; Gogo MP
; author: Assassin [?]
; editor: Bropedio

incsrc brushless-sketch.asm

; Change BCS to BRA so MP is never zeroed due to commands
org $C253D8 : db $80
