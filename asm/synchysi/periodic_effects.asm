hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Removes the two bytes that divide periodic damage/healing by four
; Also slows the poison effect's incremental damage
; Removes the halving of sap damage on allies as well
; Resets the incrementer on poison damage once it's been removed

org $C20D24			; Half sap damage on party
JSR Sap_Chk

org $C25041			; Poison
NOP

org $C2505B			; Re-written formulas for periodic effects.
JSR Tick_Calc

org $C2505E
NOP					; Remove both instances of halving periodic effects. That will
NOP					; instead be handled in the new formulas below.

org $C20AEF
Sap_Chk:
LDA $11A7			; Load special byte 3
BIT #$0080			; Test if bit 8 is set
BNE Skip_Halving	; If it is, branch
LDA $11A4			; Else, restore displaced code at $C20D24 and return
RTS

Skip_Halving:
PLA					; No longer need to RTS
JMP $0D34			; Jump back, skipping the damage halving instruction

Tick_Calc:
PHA					; Preserve A, which holds Max HP
LDA $3EF8,Y
AND #$0002			; Check for regen
BEQ No_Regen		; If regen is not present, branch
SEP #$20			; 8-bit A
LDA $E8				; Load stamina
XBA
LDA $3B18,Y			; Load level
JSR $4781			; Stam * Lvl
REP #$20			; 16-bit A
LSR
LSR
LSR
LSR					; Result from above / 16
STA $E8
PLA					; Load max HP from the stack
LDX #$40
JSR $4792			; Max HP / 64
CLC
ADC $E8				; (Max HP / 64) + ((Stam * Lvl) / 16)
BRA End

No_Regen:
SEP #$20			; 8-bit A
LDA $E8				; Load stamina
LSR
LSR
LSR					; Stamina / 8
CLC
ADC #$10			; Result + 16
TAX					; Move result to X for upcoming division.
REP #$20			; 16-bit A
PLA					; A = Max HP
JSR $4792			; Max HP / (16 + (Stamina / 8)

End:
PHA					; Preserve A.
SEP #$20			; 8-bit A
LDA $11A7			; Load special byte 3
ORA #$80
STA $11A7			; Set bit 8
REP #$20			; 16-bit A
PLA					; Restore A.
RTS

; Clears the damage increment for poison once it's been removed.

org $C246F4
DW Poison

org $C2FBC6
Poison:
PHP
SEP #$20
LDA #$00
STA $3E24,Y			; Zero poison damage incrementer
PLP
RTS

;;;;;;; +25% damage effect fix ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $C20D4B			; Earring/Atlas Armlet function starts at C2/0D4A
JSR Sap_Chk2
ASL

org $C22874
Sap_Chk2:
LDA $B5
CMP #$01
BEQ No_Bonus
LDA $11A7			; Load special byte 3
RTS

No_Bonus:
PLA
PLA
JMP $0D85

; The above function actually removes an unintended effect from magic damage +25% relics:
; Originally, the magic damage boost did not affect heals. This check has been replaced
; with a check for sap damage, so characters with a +25% magic damage relic will not
; increase sap damage on themselves.

;;;;;;; Magic damage stacking removal ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $C20D6A
NOP
NOP					; Remove instructions to branch on double earring

; EOF