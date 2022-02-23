hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Changes the formula used for Coin Toss/GP Rain.
; Uses 8 bytes of space freed up by the proactive Retort hack
; GP Rained = Stam * 10 | Dmg = (GP Tossed * Lv) / (3 * (# of targets + 1))

; Changing the Coin Toss pointer
org $C24383
DW CoinToss

; Actual Coin Toss function.
org $C266C7
CoinToss:
LDA $3B40,Y		; Attacker's stamina.
XBA
LDA #$0A
JSR $4781		; Coins tossed = stamina * 10.
REP #$20		; 16-bit A.
CPY #$08
BCS Enemy_Toss	; Branch if coin tosser is a monster.
JSR $37B6		; Deduct cash from party's bankroll.
BNE Not_Broke

Broke:
STZ $A4			; Attack now targets nothing.
LDX #$08
STX $3401		; Attack miss with text.
RTS

Enemy_Toss:
STA $EE
LDA $3D98,Y		; Monster's bankroll.
BEQ Broke		; Branch if they drop nothing.
SBC $EE
BCS Deduct_Cash	; If enemy has sufficient cash, branch.
LDA $3D98,Y
STA $EE			; If monster didn't have sufficient cash, store what they do have in $EE.
TDC

Deduct_Cash:
STA $3D98,Y		; Store new cash drop.
LDA $EE			; Get cash to toss.

Not_Broke:
LDX $3B18,Y		; Attacker's level.
STX $E8
JSR $47B7		; (stamina * 10) * level. Result stored in 24-bit $E8.
SEP #$20		; 8-bit A
LDA $3EC9		; Number of targets.
INC
XBA				; Place in top byte of A
LDA #$02
JSR $4781		; (Number of targets + 1) * 2
TAX
REP #$20		; 16-bit A
LDA $E8
JSR $4792		; (((stamina * 10) * level) / (targets + 1) * 2)
STA $11B0		; Sets damage.
RTS

; EOF
