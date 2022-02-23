hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Converts Terii Senshi's Vanish/Doom fix to assembly for modification purposes.
; Probably need to come back and try to comment this at some point.
; Also something suplex bit-related.

org $C22215
;JSR Suplex_Bit
LDA $11A2			; Remove this line if reverting to the old suplex bit code (i.e., uncommenting the bottom)
BIT #$02
BEQ $07
LDA $3AA1,Y
BIT #$04
BNE $6E
LDA $B3
BPL $1C
LDA $3EE4,Y
BIT #$10
BEQ $15
LDA $11A4
ASL
BMI $07
LDA $11A2
LSR
JMP $22B3
LDA $3DFC,Y
ORA #$10
STA $3DFC,Y
LDA $11A3
BIT #$02
BNE $0F
LDA $3EF8,Y
BPL $0A
REP #$20
LDA $3018,Y
TSB $A6
;JMP $22E5		; This is replaced by a JMP instruction in sei_reflect_timer.asm

;org $C24341
;DB $8A,$3E

;org $C23E2D
;DB $8C,$38

;org $C2FC3F
;Suplex_Bit:
;LDA $3C80,Y
;BIT #$04		; Check for "Block suplex" flag
;BEQ Exit		; Exit if it's not set
;LDA $11A9		; Special effect of attack
;CMP #$60		; Is it suplex? (meaning the attack should not set statuses if the enemy is set to block ;suplex)
;BNE Exit		; If not, exit
;LDX #$03		; Otherwise, remove all statuses the attack could set
				; This should also prevent accidentally rerising a boss
;Loop:
;STZ $11AA,X
;DEX
;BPL Loop

;LDA #$02
;TSB $11A2

;Exit:
;LDA $11A2		; Displaced instruction from the JSR
;RTS

; EOF
