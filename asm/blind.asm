hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Makes the Blind status apply to physical specials in addition to Fight
; Sets the accuracy penalty to a flat 50% rather than half of the original hit rate
; Removes the "can't be dodged" flags for Throw, Coin Toss, and Tools

; Have Blind status apply on skills with 255 hit rate and sets the accuracy of a blinded
; attacker to 50%

org $C22306
JSR Back_Chk
BRA Skip_Code

org $C22315
Skip_Code:

org $C26719
Back_Chk:
LDA $3EE4,X
LSR
BCC Not_Blind	; Branch if attacker is not blinded
LDA $11A7		; If they are blinded, check to see if the attack should be affected
BIT #$04
BNE Stam_Atk	; Branch if it's a stamina-based attack, which Blind should affect
LDA $11A2
LSR
BCC Mag_Atk		; Branch if it's a magical attack, which Blind doesn't affect

Stam_Atk:
LDA #$32		; Else, set hit rate to 50
RTS

Not_Blind:
REP #$20		; 16-bit A
LDA $3018,Y
BIT $3A54
SEP #$20
BEQ Mag_Atk		; Branch if not hitting in the back
LDA #$FF		; If you are and not blinded, set hit rate to 255
BRA Store_Hit

Mag_Atk:
LDA $11A8		; Load hit rate

Store_Hit:
RTS

; Re-writes function that loads weapon data to change how accuracy is affected by "fight can't miss" effects
org $C2299F
PHP
LDA $3B2C,X
STA $11AE		; Vigor * 2 / Magic Power)
JSR $2C21		; Put attacker level (or sketcher) in $11AF
LDA $B6
CMP #$EF
BNE Not_Special
LDA #$06
STA $3412

Not_Special:
PLP
PHX
ROR $B6			; Handles the attack sequence - see commentary at C2/29C9
BPL RH_Swing	; If carry wasn't set, branch and use right hand
INX				; Else, use left hand

RH_Swing:
JSR Sketch_Chk
STA $11A6		; Battle power
LDA #$62
TSB $B3			; Turn off always crit and gauntlet, and turn on ignore attacker row
LDA $3BA4,X
AND #$60		; Isolate "same damage from back row" and "2-hand" properties
EOR #$20		; Flip "same damage from back row" to get "damage affected by attacker row"
TRB $B3			; Bit 6 = 0 for Gauntlet and Bit 5 = 0 for "damage affected by attacker row"
LDA $3B90,X
STA $11A1		; Element
LDA $3B7C,X
STA $11A8		; Hit rate
LDA $3D34,X
STA $3A89		; Random weapon spellcast
LDA $3CBC,X
AND #$F0
LSR
LSR
LSR
JSR Atma_Chk
LDA $3CA8,X		; Get equipment in current hand
INC
STA $B7
PLX
LDA $3C45,X
BIT #$10
BEQ No_Blk_Belt	; Branch if no "Fight can't miss" effect
LDA #$FF
STA $11A8		; Set hit rate to 255

No_Blk_Belt:
LDA $3C58,X		; Check for offering (Daryl's Soul)
LSR
BCC No_Offering
LDA #$02
TSB $B2			; Set no critical and ignore True Knight

No_Offering:
RTS

org $C2FBEE		; Actual function in atma.asm
Atma_Chk:

org $C26642
Sketch_Chk:		; Actual function in sketch_fix.asm

; Bypass old Blind check (now done above)
org $C2234A
BRA Skip_Blind

org $C22358
Skip_Blind:
LDA $3C58,Y

; Removes the "can't be dodged" flag for Coin Toss
; Removal of this flag for Throw is handled in throw.asm
org $C21908
JSR Coin_Toss

org $C23C3D
Coin_Toss:
JSR $298A		; Displaced code from above
STZ $11A4		; Clears "can't be dodged" flag (among others Coin Toss doesn't use)
LDA #$FF
STA $11A8
RTS

; EOF