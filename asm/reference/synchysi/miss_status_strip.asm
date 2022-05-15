hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Alters some hit determination function to strip all statuses when an attack misses due to float
; Also removes the random target part of the suplex effect

org $C23B1D
JSR Clear_Status

org $C2428B
Clear_Status:
TYX
STZ $3DD4,X			; Clear all status bytes from the missed attack
STZ $3DE8,X
LDA $3018,Y			; Displace code from JSR above
RTS

; Removes the random target functionality of the suplex effect.

org $C24341
DB $8A,$3E

; EOF
