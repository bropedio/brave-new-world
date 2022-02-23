hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Alters Throw to include the weapon's properties in the attack
; Patch by Think0028 - need to come through and properly comment this patch later
; Modified by Synchysi for efficiency and to exchange Throw's "can't be dodged" flag
; for 255 hit rate

org $C22A71
JSR Throw

org $C2FBD0
Throw:
PHP
STA $11A1		; Displaced from JSR above
LDA $D8501B,X
AND #$F0
LSR
LSR
LSR
STA $11A9
STZ $11A4		; Clears "can't be dodged" flag, among others Throw doesn't use
LDA #$FF
STA $11A8		; Hit rate = 255
PLP
RTS

;;;;;;;;;;;;;;; Think's original code below, in case my modifications don't work

;org $C22A66
;JSR Throw
;NOP

;org $C20AE6
;Throw:
;PHP
;LDA $D8500F,X
;AND #$F0
;LSR
;LSR
;LSR
;STA $11A9
;LDA $D85014,X
;PLP
;RTS

; EOF
