hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Lowers the gauntlet battle power bonus to +50%
; Drastically alters the physical damage formula used by PCs and re-writes the enemy's formula to save space.
; Removes the spear damage bonus for jumping.
; Changes the odds of additional bounces from the Dragon Horn effect.
; Changes the Offering from four attacks to two and alters some of its properties.
; Changes enemy vigor from 56-63 to 24-30

; Some modification by Bropedio for stamina-based non-physical attacks to respect row, further modified by me

org $C22BB3
CPX #$08		; Check if the attacker is a monster
BCS Enemy
JMP Player

Enemy:
ASL
ASL				; BP * 4
ADC #$003C		; Add 60 (instead of enemy vigor)
SEP #$20
JSR $47B7		; ((BP * 4) + 60) * level
LDA $E8
STA $EA
PLA				; Level
STA $E8
REP #$20		; 16-bit A
LDA $E9
XBA
JSR $47B7		; Result from above * level / 256
STA $11B0
PLP
RTS

org $C26469
Player:
PHA				; Attack BP
SEP #$20
LDA $B5			; Command
CMP #$07		; Is it Bushido?
BNE No_Bushido	; If not, branch

; If the command is Bushido, modify the BP to include the user's weapon(s) and the skill modifier
LDA $01,S
STA $E8
LDA $3B68,X		; Load up RH weapon's BP
CLC
ADC $3B69,X		; Add LH weapon's BP to it. If Gauntlet bonus is active, this will be 0
XBA
ADC #$00		; Add carry to the top byte if the ADC above overflowed.
XBA
REP #$20		; 16-bit A
LSR
LSR
LSR				; BP / 8
JSR $47B7		; (BP / 8) * $E8
LDA $E8			; BP for this attack, including Bushido multiplier
STA $01,S

No_Bushido:
REP #$20
LDA $B2
BIT #$4000
BNE NoGaunt		; If Gauntlet is not equipped, branch
LDA $01,S		; Battle Power * 3/2
LSR
CLC
ADC $01,S
STA $01,S

NoGaunt:
PLA				; Battle power.
STA $D0			; Store in scratchpad location for later usage
LSR
LSR
LSR
LSR				; Battle power / 16
STA $11B0
SEP #$20		; 8-bit A
LDA $11AE
LSR				; Vigor
XBA				; Puts vigor in the high byte of A
PLA				; Level is pulled from the stack into the low byte of A
STA $E8
JSR $4781		; Vigor * Level. Result is stored in A
REP #$20
LSR
LSR
LSR
LSR				; (Vigor * Level) / 16
JSR $47B7		; Result from above * 8-bit level, and put 24-bit product in variables $E8 through $EA
SEP #$20
LDA $EA
BNE DmgCap		; If $EA is greater than zero, we've overflowed the 16-bit register. If that's the case at this point in the calculation, the player will damage cap
LDA $11B0
PHA
REP #$20		; Set 16-bit accumulator
LDA $E8			; Level * Level * Vigor / 16
STA $11B0
SEP #$20		; Set 8-bit accumulator
PLA
STA $E8
REP #$20		; Set 16-bit accumulator
LDA $11B0
JSR $47B7		; Multiply (Lvl * Lvl * Vig / 16) by (Pwr / 16)
LDA $E8
PHX
LDX #$18
JSR $4792		; Divide result from above by 24
STA $11B0
TDC				; A = 0
SEP #$20		; Set 8-bit accumulator.
LDA $EA
BEQ EndLoop		; If $EA = 0, no need to check for overflow, so branch

ChkCap:
CMP #$07		; If the result from the above multiplication is greater than #$FFFF, $EA will be greater than 0.
BCS DmgCap		; If $EA is greater than 7, just give the player the damage cap.
TAY				; Otherwise, we utilize that excess damage.
REP #$20		; Set 16-bit accumulator.

Loop:
LDA #$0AAB		; 65536 / 24 [#$10000 / #$18]
ADC $11B0
STA $11B0
DEY
BNE Loop
TDC				; A = 0

EndLoop:
SEP #$20		; Set 8-bit accumulator.
LDA $D0			; Battle power.
ADC $11AE		; Add Vigor * 2.
XBA
LDA $D1			; Load top byte of battle power, if any.
ADC #$00		; Add carry from the bottom byte of attack into the top byte.
XBA
REP #$20		; Set 16-bit accumulator.
ADC $11B0		; Adds ((Lvl * Lvl * Vig / 16) by (Pwr / 16) / 24) to the result from above.
STA $11B0		; New maximum damage.
BRA Exit

DmgCap:
REP #$20		; Set 16-bit accumulator
LDA #$7530		; Loads 30000 into maximum damage - this leaves room for crits to not overflow the 16-bit limit.
STA $11B0

Exit:
PLX
JMP PhysDmgJump

Row_Chk:
EOR #$FF		; Flip bits so bit 4 is now "respect row"
ASL				; Move to bit 5 to match $B3
ORA $B3			; Combine row-respecting bytes
AND #$20		; If attack respects row, bit 5 should be set
RTS

;SEP #$20		; Set 8-bit accumulator.
;LDA $11A7
;BIT #$10
;BEQ Finish		; Branch if the attack does not consider row
;LDA $3AA1,X
;BIT #$20
;BEQ Finish		; Branch if attacker is in the front row
;REP #$20		; Set 16-bit accumulator
;LSR $11B0		; Cut damage in half

;Finish:
;JMP PhysDmgJump

org $C23392
LDA $11A7		; Special byte 3
JSR Row_Chk

org $C22D65
ADC #$18		; Add 24 to enemy's vigor, giving them a range of 24-30

; Changes some of the properties of the Offering
; Now handled in blind.asm, since this entire function was rewritten

;org $C22A0B
;TSB $B2			; Set no critical and ignore True Knight
;BRA Offering

;org $C22A1B
;Offering:

; The following removes some code that is no longer used and utilizes that freed space

org $C22BDA
PhysDmgJump:
SEP #$20		; 8-bit accumulator
LDA $B5			; Load command ID
CMP #$07
REP #$20		; 16-bit accumulator
BCS End			; If the command ID >= 7, branch. It won't branch if the command is Fight, Item, Magic, Morph, Revert, Steal, or Mug. Of these, only Fight and Mug will be affected by the damage modification
LDA $3C58,X		; Load relic properties
LSR
BCC DualWield	; Damage down by 25% if the offering property is present
JSR DmgQtr

DualWield:
BIT #$0008
BEQ End			; Damage down by 25% if the genji glove property is present
JSR DmgQtr

End:
PLP
RTS

org $C22BF7
DmgQtr:
PHA
LDA $11B0		; Since this is the physical damage formula, only Fight and Mug matter.
LSR
LSR
EOR #$FFFF
SEC
ADC $11B0
STA $11B0		; Subtract 1/4 from maximum damage
PLA
RTS

; The Offering's target randomization is removed by heal_rod.asm
; Changes the Offering from four attacks to two
; Also re-enables crits with the Offering

org $C21624
LDA #$03

; Alters the Dragon Horn property to allow a 25% chance of a second jump
; Eliminates the third and fourth jumps altogether

org $C21823
BPL EndJump

org $C2182B
CMP #$40
BCS EndJump		; 1/4 chance of jumping twice
INC $3A70		; Add 1 to the number of attacks

EndJump:
LDA $3EF9,X
AND #$DF
STA $3EF9,X		; Clear hide status
JMP $317B

; EOF
