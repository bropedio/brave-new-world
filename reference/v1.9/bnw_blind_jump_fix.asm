hirom
;header

; Written by dn
; Modified by Synchysi to allow the attack to ignore attacker row regardless of blind status

org $c2180b
jsl blind_jump
nop

org $c3f723
blind_jump:
stz $11a9
lda $3ee4,x							; status byte 1
lsr									; check for blind
lda #$20
bcs blinded
sta $11a4
bra end
blinded:
stz $11a4
end:
rtl
