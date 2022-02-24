hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Changes the Ogre Nix special effect to randomly cast Aero
; Changes the Drain MP special effect to randomly cast Net
; Changes the Randomly Kill special effect to 2x damage to humans and randomly cast Net
; Allows gauntlet/genji glove effects to apply to random Wind Slash/Aero casts
; Changes the multiplier on "randomly thrown" weapons to 2
; Changes the final effect (0xF) to auto-kill undead, or crit on undead bosses
; Corrects a problem with rolling more dice than intended due to changes in how hit rate is applied

; Mutsunokami - Aero
org $C23ECA
JSR $4B5A		; Generates a random number between 0 and 255
CMP #$80
BCS Exit		; 50% chance of exiting
STZ $11A6		; Clears battle power (since the attack itself does no damage)
LDA #$99		; Spell number for Aero v2

Finish:
STA $3400
INC $3A70

Exit:
RTS

; Randomly cast Net
org $C23F6E
JSR $4B5A		; 0 - 255 random number
CMP #$80
BCS No_Cast		; 50% chance to exit
LDA #$AD		; Net spell number
JMP Finish		; Finishing prep for the spell cast

No_Cast:
RTS

; Change the random wind slash to point to the new version
org $C23FA9
LDA #$98
JMP Finish

; Since Wind Slash originally used some of the Magicite code, we need to redirect it
; to other places it can still get its jollies.
org $C23F9E
Exit2:

org $C23FA4
BCS Exit2

; Forces the random Net cast to maintain the current target
org $C2380F
BEQ BR1			; See commentary at $C2/380F for explanation
JSR Net_Target
BRA BR2			; Ditto
BR1:

org $C2382D
BR2:

org $C23F18
Net_Target:
LDA $B6
CMP #$AD		; Is the random cast Net?
BNE Random_Target
JMP $3816		; If so, treat it as a normal spellcast and maintain current target

Random_Target:
STZ $3415		; If not, zero $3415 (which makes the attack random targeted) and return
RTS

; Note: Starting at $C23F25, other special effects use the remainder of the Ogre Nix effect.
; Namely, anything that consumes MP for critical hits.

org $C22B9A
JMP Wpn_Chk

org $C23A4F
Wpn_Chk:
SEP #$20
LDA $11A7		; Load special byte 3
BIT #$08		; Test if bit 4 is set (consider weapon effects)
BEQ End			; If not, exit
REP #$20
LDA $B2
BIT #$4000		; If so, check for the gauntlet effect's presence
BNE GG			; If no gauntlet effect, then apply the genji glove effect
LDA $11B0
LSR
ADC $11B0		; Damage * 1.50
BRA Return

GG:
LDA $11B0
LSR
LSR
EOR #$FFFF
SEC
ADC $11B0		; Damage * 0.75

Return:
STA $11B0
SEP #$20

End:
RTS

; Increases the incrementer for "randomly thrown" weapons to 2
org $C23905
INC $BC
LDA $3EF9,Y
BPL No_Float	; Exit if target not floating
LDA $B5
CMP #$00
BNE No_Fight	; Exit if command isn't Fight (?)

org $C23916
No_Float:

org $C238FD
No_Fight:

; Modifies special effect 0x3 (randomly kill) to deal double damage to humans and randomly cast Net
org $C23D43
JSR $38F2		; Jump to double damage to humans function
JMP $3F6E		; Jump to function to randomly cast Net

; Adds a special effect for auto-killing undead, or critting undead bosses
org $C23DEB
DB $AE,$3F		; Change the old pointer

org $C23FAE
LDA $3C95,Y		; Load special byte 3
BPL Not_Undead	; If bit 7 is clear, the target isn't undead, so exit function
LDA #$7E
JMP Kill_Zombie	; Otherwise, branch to Zantetsuken code for cleave-kill/boss-crit
Not_Undead:
RTS

org $C202BE		; See zantetsuken.asm
Kill_Zombie:

; Corrects dice issue (by Seibaby)
org $C2418F
JSR newfunc ;(untested)

;New function
org $C2239C
newfunc:
LDA $3A70 ;Which hand is striking (odd = right; even = left)
LSR
BCC .lefthandstrike ;Striking with left hand; branch
LDA $3B7C,Y ;Hit rate of right hand
BRA .exit
.lefthandstrike
LDA $3B7D,Y ;Hit rate of left hand
.exit
RTS
; EOF