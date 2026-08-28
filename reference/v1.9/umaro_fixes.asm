hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Various fixes/improvements for Umaro
; All locations have only been tested in FF3US ROM version 1.0

; Allows the player to equip Umaro manually.
org $C31E6E
CMP #$0E

; Sets the battle power of Umaro's Tackle attack to 255 (utilizing space freed up below).
org $C2167F
JSR Tackle

; Allows Umaro's Rage attack (throwing an ally) to crit if he throws Mog.
org $C216D6
LDA #$12		; Clears always critical and ignore damage increment on ignore defense.
				; This means that when throwing Mog, the attack will always crit. If not,
				; the attack can't crit at all. No idea why the screen won't flash.
				; Find a place for these two commands: LDA #$20 TSB $A0
				; and the screen should flash.

; Sets the battle power of Umaro's Rage attack to 255 + gauntlet bonus (so effectively 382).
org $C216DA
LDA #$40
TRB $B3			; Sets gauntlet effect.
BRA Cont

Tackle:			; Tackle enters here from above.
JSR $17C7
LDA #$FF
STA $11A6
RTS

Cont:			; Destination of branch from above.

; Adjusts the odds of each attack showing up for Umaro. Structured thusly:
; Row 1: No relics				Column 1: Fight
; Row 2: Rage Belt only			Column 2: Tackle
; Row 3: Blizzard Orb only		Column 3: Snowstorm
; Row 4: Both relics			Column 4: Rage

org $C25269
DB $B2,$4B,$FF,$FF			; 70% Fight, 30% Tackle
DB $66,$4B,$FF,$4B			; 40% Fight, 30% Tackle, 30% Rage
DB $66,$4B,$4B,$FF			; 40% Fight, 30% Tackle, 30% Snowstorm
DB $1A,$4B,$4B,$4B			; 10% Fight, 30% Tackle, 30% Rage, 30% Snowstorm

; EOF
