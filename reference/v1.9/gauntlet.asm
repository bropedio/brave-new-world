hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Changes the character sheets to properly display a two-handed weapon's battle power.
; Copy/pasted wholesale from assassin's patch, modified slightly to change the
; gauntlet bonus from 75% to 50%.
; Also makes the off-hand weapon slot gray with blue shading instead of just gray when
; using a 2-handed weapon.

org $C36002
BRA $0C		; (skip over our nested function)

; (The next 5 instructions are relocated from C3/9384 to save space.)
LDX #$300C		; (want to use addresses $300C and $300D for hand Battle Powers when calling General)
STX $E0			; (save in temp variable)
LDX $CE			; (just want bottom half, top half will be ignored)
CLC
LDA $A0			; (check for Gauntlet, setting Zero Flag accordingly)
NOP
RTS

Skip:
JSR $052E

org $C39182
JSR $9382		; (modify hands' Battle Powers as needed [for display purposes], and save their sum in $F1-$F2.)

org $C3934F
JSR $9382		; (modify hands' Battle Powers as needed [for display purposes], and save their sum in $F1-$F2.)

org $C39371
LDX #$11AC		; (want to use addresses $11AC and $11AD for hand Battle Powers when calling General)
STX $E0			; (save in temp variable)
LDX $CD			; (just want bottom half, top half will be ignored)
CLC
LDA $A1			; (check for Gauntlet, setting Zero Flag accordingly)
JSR General
STA $F3			; (save 16-bit sum of hands' Battle Powers)
BRA $08			; (do cleanup and return)

org $C39382
JSR $6004		; (do relocated first 5 instructions for this function.  were moved to save space.)
JSR General
STA $F1			; (save 16-bit sum of hands' Battle Powers)
TDC				; (clear top half of A, because that's how it is in original game, and i'm being uber safe. probably unnecessary.)
SEP #$20		; (set 8-bit Accumulator again)
RTS

; (helper function used by both "first_function" and "second_function", as the two had a LOT of overlap in the original game.)

org $C3938E
General:
BEQ skip		; (branch if Gauntlet not present)
SEC				; (set Carry if it is)

skip:
PHB
LDA #$7E
PHA
PLB				; (set Data Bank to 7Eh.  the second function we're replacing explicitly addresses many variables with that bank.  the first function we're replacing originally used Bank $00 to address many variables, but since they're in the $0000-$1FFF Offset range, that's a mirror of Bank $7E anyway.)
LDY #$0001
PHP
BCS add_em		; (skip Genji Glove check if Gauntlet in use)

genji_check:
TXA				; (copy bottom half of 16-bit X to 8-bit A. iow, get value of Variable $CD or $CE, Genji Glove presence.)
ORA #$00		; (shouldn't be needed.  just to be safe; i'm paranoid.)
BNE add_em		; (branch if Genji Glove)
LDA ($E0)		; (get right hand Battle Power)
BEQ add_em
TDC
STA ($E0),Y		; (if it's above zero, then zero left hand Battle Power)

add_em:
TDC				; (make sure top half of A is clear for addition)
LDA ($E0)
CLC
ADC ($E0),Y		; (get sum of two hands' [modified] Battle Powers.)
XBA
ADC #$00		; (carry into top byte)
XBA				; (now 16-bit A = sum of hands' Battle Powers)
PLP				; (get old Carry Flag, which indicates Gauntlet presence)
REP #$20		; (Set 16-bit Accumulator)
BCC no_gauntlet	; (branch if no Gauntlet) [Label renamed by me for formatting purposes.]
JSR OneAndAHalf	; (A = A * 7/4) [Label renamed by me since BNW doesn't use 7/4]

no_gauntlet:
PLB				; (restore old Data Bank, whatever that was.)
RTS

OneAndAHalf:	; Function modified to reflect the change in gauntlet bonus.
PHA				; (save Battle Power)
LSR				; BP / 2
CLC
ADC $01,S		; (BP / 2) + BP
STA $01,S		; New BP = BP * 1.5
PLA				; (retrieve increased Battle Power)
RTS

; 32 bytes freed starting at C3/93C9.

org $C399BD
LDA #$28		; Yellow

org $C399E2
LDA #$28		; Yellow

; EOF
