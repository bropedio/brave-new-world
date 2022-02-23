hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Changes Morph from a charge ability to a toggled ability.
; The Morph toggle will increase Terra's damage dealt by 50% and damage received by 100%.
; Her stamina will decrease the extra damage she receives while Morphed.
; Prevents damage incrementers from being ignored on defense-ignoring attacks

; The following branch bypasses the function that adjusts Terra's Morph supply.
; It also frees up 24 bytes from $C25E31 - $C25E48.
org $C25E2F
BRA Cont

org $C25E49
Cont:

; The following changes the Morph damage bonus from +100% to +50%
org $C2336B
NOP
NOP

; The following changes the Morph menu entry so it will never be unavailable.
; This change is actually handled by the swordless runic patch, since it adjusts
; the location of this table. The code remains here for documentation purposes.
;org $C204E8
;DB $19,$05			; Jumps to an RTS

;;;;;;;;;;;;;;; Old Morph code - retained in case the new one breaks it ;;;;;;;;;;;;;;;;
; The following makes Morph permanent once it's activated.
; It makes use of the same method the game uses to make her Morph in the final Phunbaba
; battle permanent.
;org $C20B01
;BRA Permamorph

;org $C20B33
;Permamorph:

;org $C20AE8
;NOP
;NOP
;NOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $C20AE5
RTS

; Deprecating more Morph timers/calculations.
org $C21143
BRA BypassMorphCalc

org $C2114B
BypassMorphCalc:

org $C24903
NOP #3

org $C25326
CLC
RTS

; Forces Morph/Revert to reset the ATB when used. Disabled for now, but left as comments for documentation purposes.
;org $C20AA8
;BRA Dest

;org $C20AB7
;Dest:

; The following modifies the damage taken by a Morphed character.
org $C20CC9
BNE Ignore_Def		; Changes the branch for defense ignoring attacks so incoming damage is still modified by Morph

org $C20D15
Ignore_Def:
LDA $3EF9,Y
BIT #$08
BEQ NoMorph			; Branch if target not morphed.
LDA $3B40,Y
JSR MorphDmg
NoMorph:

org $C2A65A
MorphDmg:
CMP #$60
BCC No_Cap
LDA #$60			; If stamina > 96, set equal to 96.

No_Cap:
STA $E8				; Store stamina.
REP #$20			; Set 16-bit A.
ASL $F0
LDA $F0				; Double damage.
JSR $47B7			; ((Damage * 2) * stamina) / 256
PHA
LDA $F0
SBC $01,S			; (Damage * 2) - result from above.
STA $F0
PLA
RTS

; Re-writes the code that bypasses the damage increment function if the attack ignores
; defense, and instead applies that exception to fractional attacks
org $C2370B			; Start of the increment function
PHY
LDY $BC
BEQ Exit			; If $BC is zero, then there are no increments, so exit
PHA
SEP #$20
LDA $11A7			; Special byte 3
AND $11A2			; Bit 5 will be set if the above was set AND the attack ignores defense
ASL
ASL
ASL
REP #$20
PLA
BCS Exit			; If carry is set, ignore damage increments. So exit.
STA $EE				; Store damage in $EE
LSR $EE

Loop:
CLC
ADC $EE				; Add 50% damage
BCC No_Cap_2
TDC					; We're here if the damage has overflowed
DEC					; In that case, set damage to 65535

No_Cap_2:
DEY
BNE Loop
STY $BC				; Y = 0 at this point

Exit:
PLY
RTS

; The following is a tiny hack from assassin that fixes a display issue while trying to run
org $C1353F
AND #$02

; EOF
