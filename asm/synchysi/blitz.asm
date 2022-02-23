hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Modifies three of Sabin's blitzes in the following ways
; Mantra - Amount healed is now modified by stamina
; Spiraler - Special effect has been re-worked for Chakra
; Chakra - Restores MP equal to level plus a stamina modifier, with slight variance
; All locations have only been tested in FF3US ROM version 1.0

; Chakra
org $C24234		; Spiraler
LDA #$60
TSB $11A2		; No split damage and ignore defense
REP #$20		; Set 16-bit accumulator
LDA $3018,Y
TRB $A4			; Miss the caster
SEP #$20		; Set 8-bit accumulator
LDA $3B40,Y		; Load stamina
JMP Chakra
NOP
NOP
RTS				; Just in case

; Mantra - (((Current HP / 64) + Level ) * Stamina) / 4
org $C2426B		; Mantra starts at $C24263
JSR Mantra
LDA $E8
LSR
LSR				; Result from previous multiplication / 4
STA $11B0
LDA $3018,Y
TRB $A4			; Miss caster
RTS

org $C242A4
Mantra:
LDA $3B40,Y		; Load caster's stamina
STA $E8
REP #$20		; Set 16-bit accumulator
LDA $3BF4,Y		; Load caster's current HP
LDX #$40
JSR $4792		; cHP / 64
SEP #$20		; Set 8-bit accumulator
ADC $3B18,Y		; (cHP / 64) + caster's level
REP #$20
JMP $47B7		; Result from above * caster's stamina

Chakra:
CLC
ADC $3B18,Y		; Add caster's level to stamina...
LSR				; ...and cut it in half
STA $11B0		; Set MP recovered
RTS

; EOF
