hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; A (hopefully) working Gau status fix
; It should probably clear him of statuses when he dies/loses Rage status
; Written by Think

org $C22E17
JSR Jump_1

org $C228C1
JSR Jump_2

org $C2A742
Jump_1:
STA $3C6C,Y
LDA $CF0014,X		; blocked status bytes 1-2
AND $331C,Y			; and with the original status weaknesses
EOR #$FFFF			; invert 'em to get statuses to clear
AND $3EE4,Y
STA $3EE4,Y
RTS

Jump_2:
STA $3C6C, X
AND $3EE5, X		; equipment status byte 2 AND current status = status to actually have
STA $3EE5, X
LDA $D4
AND $3EF8, X		; equip status byte 3 and current status 3
STA $3EF8, X
LDA $3EF9, X		; load float byte
AND #$7F			; no float
STA $3EF9,X
RTS

; EOF