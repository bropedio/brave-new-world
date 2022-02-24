hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Changes the Atma Weapon's damage formula to now use stamina instead of vigor
; Changes the HP modification done to Atma strikes
; HP modification formula: Damage * ((current HP / 256) + 1) / ((max HP / 256) + 1)

org $C20E41
STA $E8			; $E8 = ((current HP / 256) + 1)
LDA $F0			; Damage
JSR $47B7		; 24-bit $E8 = damage * (former $E8)
LDX $3C1D,Y		; Load Max HP / 256
INX
PHX				; Preserve X
REP #$20		; 16-bit A
LDA $E8
JSR $4792		; Result from above / ((Max HP / 256) + 1)
STA $F0			; Store damage so far
PLX				; X = ((Max HP / 256) + 1) again
PHY
LDY $EA
BEQ Exit		; If $EA is 0, the earlier multiplication didn't overflow, so exit
JSR Finish_Atma	; Else, jump off to some free space to finish up
NOP

Exit:			; this part
PLY

org $C202AD
Finish_Atma:
TDC				; With $EA > 1, we need to tack on a bit more damage
DEC				; A = #$FFFF
JSR $4792		; 65535 / ((Max HP / 256) + 1)
CLC
ADC $F0
STA $F0			; Store final damage result
RTS				; $EA can't realistically get higher than 1, so there's no reason to loop

; Uses stamina instead of vigor if it's an Atma Weapon attack
; Jump now handled in blind.asm, as that function was re-written
;org $C229FB
;JSR Atma_Chk

org $C2FBEE
;Atma_Chk:
STA $11A9		; Displaced from JSR above
CMP #$04		; Is it Atma's special effect?
BNE End			; If not, branch
LDA $3B40,X		; Stamina
ASL				; Double it, since it'll get halved in the physical damage formula
STA $11AE		; Vigor*2 was in here before, now we're replacing it with Stamina*2

End:
RTS

; EOF