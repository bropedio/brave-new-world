hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Removes the check for enemy Roulette

org $C203B0
JSR $03E4
JMP $4ECB

org $C21B3B
NOP #3

; Frees up 16 bytes at C2/03B6

; Old code - Changed enemy Roulette pointers

;org $C203BC
;CMP #$D90C		; Old Roulette ID = $8C

;org $C203C1
;LDA #$D91E		; New Roulette ID = $D9

; EOF
