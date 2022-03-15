hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Allows characters to counter attacks that missed them.
; Also changes counter chance from 75% to 50%.

org $C233BA
JSR Set_Targ		; Interrupt combat routine to indicate a character index was targeted

;org $C2343C
;JSR Counter_Miss	; Interrupt combat routine to set counter variables early
;NOP

org $C25E31
Set_Targ:
STY $C0				; Y = battlefield index of target
JSR $220D			; Displaced code
RTS

Counter_Miss:
LDY $C0
LDA $3018,Y			; Load bitfield index for this target
BIT $3A5A			; Was this target missed during this round?
BEQ No_Targ			; If not, exit
JSR Counter_Init	; If so, initialize counter variables

No_Targ:
REP #$20
LDY #$12
RTS

org $C235E3
Counter_Init:

; Changing entry points into the black belt counter code.
org $C24CDD
BNE Counter

org $C24CE3
BCC Counter

org $C24CFC
Counter:

; Below deprecated by stam_counter.asm by SeiBaby
; Lowers counterattack chance from 75% to 50%.
;org $C24D03
;JSR $4B53			; RNG: 0-1 (carry set or unset)
;BCS No_Counter		; If carry is set, do not counter
;NOP
;NOP

;org $C24CC2
;No_Counter:

; EOF
