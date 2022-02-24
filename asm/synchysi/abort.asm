hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Hijacks the old L? spell targeting bit to create an "abort on enemies" flag
; Hard-codes it into Item (with an exception for HappyFunBalls)
; May need another exception for Dried Meat - testing required

; Create the jump for aborting on enemies
org $C25902
JSR Abort

; Creates the jump for setting the "hits mult. of success" flag for the Item command
org $C22A78
JSR Set_Bit

; Both functions jumped to from above
org $C2FC17
Abort:
LDA $11A4
ASL
ASL				; Abort on enemies flag now in carry
BCC Exit
STZ $B9			; Clear enemy targets

Exit:
JMP $5917

Set_Bit:
TRB $11A2		; Displaced from JSR above.
LDA $03,S		; Load A (item ID) from stack
CMP #$E7
BCC Set_Abort	; If the item ID is below 231 (which is all equipment), set abort flag
CMP #$F0
BEQ Set_Abort	; If the item is a Phoenix Down, set abort flag
CMP #$F1
BEQ Set_Abort	; If the item is a Holy Water, set abort flag
CMP #$F9
BEQ Set_Abort	; If the item is a Phoenix Tear, set abort flag
RTS				; Else, exit function. Every other item is fine

Set_Abort:
LDA #$40
TSB $11A4		; Set "hits mult. of success" - the old L? spell targeting flag
RTS

; EOF