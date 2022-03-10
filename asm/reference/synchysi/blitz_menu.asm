hirom
;header

; Adds blitz names to the Blitz menu
; Original hack by DN

ORG $C3565D
JSR $F4F0

ORG $C3F4F0
PHA
phy
ASL A
pha
ASL A
ASL A
adc $01,s
;ASL A
TAX
LDY #$9E8B
STY $2181
LDA #$20
STA $29
ldy #$000A
blitz_loop:
LDA $E6F831,X
STA $2180
INX
dey
cpy #$0000
bne blitz_loop
STZ $2180
ply
JSR $7FD9
REP #$21
LDA $7E9E89
ADC #$0084
STA $7e9e89
TDC
SEP #$20
PLA
pla
JMP $5683
