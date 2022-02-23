hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Think's nATB hack
; Also alters speed multipliers for slow/normal/haste and status timers

org $C17792
NOP
NOP
NOP

org $C17D25
NOP
NOP
NOP

org $C1953B
JSL MagicFunction1

org $C19544
JSL MagicFunction2

; The following all modify the condemned timer calculation
org $C209BB
NOP
NOP
NOP

org $C209C1
LDA #$1E

org $C209C8
ADC #$0A

; ATB multiplier changes - now handled in speed.asm
;org $C209D4
;DB #$3C			; Slow

;org $C209DD
;DB #$4B			; Normal

;org $C209E3
;DB #$5A			; Haste

; End ATB multiplier changes

;org $C209F3		; Also now handled in speed.asm
;ADC #$14		; add the constant speed bonus (+20)
;XBA
;BRA Label1		; skip some unused code

org $C20A00
Label1:

org $C21124
ORA $3A8F		; The key to the whole hack! We check if we are in a menu OR an animation has started! (The variable is repurposed from Wait/Active)

org $C215D1		; Enabling desperation attacks at any time
NOP
NOP

org $C2247A:
STZ $3A8F		; Initialize battle, skip active/wait set
NOP
NOP
NOP
NOP

; Adjusting debuff timers
org $C24637
LDA #$09		; Sleep

org $C24680
LDA #$09		; Stop

;org $C2468A
;LDA #$0D		; Reflect - no longer has a debuff timer, so commented out. Handled now by sei_reflect_timer.asm - Syn

org $C24694
LDA #$0A		; Freeze

org $C25AEA
DB $45,$5B		; Regen
DB $3B,$5B		; Poison
DB $45,$5B		; Regen
DB $E8,$5A		; RTS
DB $45,$5B		; Regen
DB $3B,$5B		; Poison
DB $45,$5B		; Regen
DB $E8,$5A		; RTS

org $C25AFE
DB $FC,$5B
DB $FC,$5B		; increment battle timers 2 more times per tick

org $C25BDE
AND #$30		; increased chances of running

org $C3F1A6
MagicFunction1:
LDA ($76)
CMP #$FF
BEQ Exit
INC $3A8F

Exit:
RTL

MagicFunction2:
DEC $3A8F
REP #$20
LDA $76
RTL

; EOF
