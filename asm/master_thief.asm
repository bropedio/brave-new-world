hirom
header

;BNW Steal Function
;mod: Speed affects rare steal chance (Speed / 256)
org $C2399E
stealFunction:
LDA $05,S       ;Attacker
TAX
LDA #$01
STA $3401       ;= 1 (Sets message to "Doesn't have anything!")
CPX #$08        ;Check if attacker is monster
BCS enemySteal  ;Branch if monster
REP #$20        ;Set 16-bit accumulator
LDA $3308,Y     ;Target's stolen items
INC A
SEP #$20        ;Set 8-bit Accumulator
BEQ failSteal   ;Fail to steal if no items
INC $3401       ;now = 2 (Sets message to "Couldn't steal!!")
LDA $3B19,X     ;Attacker's Speed
ASL A           ;Double it
BCS .success    ;Automatically steal if Speed >= 128
ADC #$70        ;Add 112
BCS .success    ;Automatically Steal if > 255
STA $EE         ;save StealValue
JSR $4B5A       ;Random: 0 to 255
BRA .skip       ;Branch past unused code
NOP #11
.skip
CMP $EE
BCS failSteal   ;Fail to steal if the random number >= StealValue
.success
PHY
JSR $4B5A       ;Random: 0 to 255
CMP $3B19,X     ;Chance for Rare = Attacker's Speed / 256
BCC .rare       ;branch so Rare steal slot will be checked
INY             ;Check the 2nd [Common] slot
.rare
LDA $3308,Y     ;Target's stolen item
PLY
CMP #$FF        ;If no item
BEQ failSteal   ;Fail to steal
STA $2F35       ;save Item stolen for message purposes in
                ;parameter 1, bottom byte
STA $32F4,X     ;Store in "Acquired item"
LDA $3018,X
TSB $3A8C       ;flag character to have any applicable item in
                ;$32F4,X added to inventory when turn is over.
LDA #$FF
STA $3308,Y     ;Set to no item to steal
STA $3309,Y     ;in both slots
INC $3401       ;now = 3 (Sets message to "Stole #whatever ")
RTS

org $C23A01
failSteal:
org $C23A09
enemySteal: