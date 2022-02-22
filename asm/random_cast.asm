hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Utilizes an unused bit to increase the odds of a random weapon cast activating
; All locations have only been tested in FF3US ROM version 1.0

org $C23651
JSR RandomCast
NOP
NOP

org $C23A3C
RandomCast:
JSR $4B5A		; Random number, 0 - 255
PHA				; Store result in stack
LDA $3C58,X		; Load battle effect 2
BIT #$80		; Test bit 7
BEQ NoChange	; If clear, branch
PLA
CMP #$80		; 1/2 chance of activating random weapon cast
RTS

NoChange:
PLA
CMP #$40		; 1/4 chance of activating random weapon cast
RTS

; EOF