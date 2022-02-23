hirom
header

;Seibaby's Life Hack and Blow Fish Mod
;Life heals rand(250..500) HP, regardless of Spell Power or caster's stats
;v0.2 - Adds out of battle functionality, now requires free space
;v0.1 - Battle functionality only

!freespace = $C265BE ;requires 16 bytes of free space in C2

;Spell Effect $1A - Blow Fish
org $C24315
dw blowFish

;Spell Effect $22 - Stone
org $C23E11
dw lifeStone

;Stone
;Now Damage = rand(250..500)
org $C23922
lifeStone:
TDC            ;A = $0000
PHA            ;Push to stack
LDA #$FB       ;251
JSR $4B65      ;Random number 0..250
PHA            ;Push rand(0..250)
JSR $3F54      ;Pearl Wind (sets 16-bit A, clears Carry, sets no split loss and ITD)
PLA            ;Pull 16-bit rand(0..250)
ADC #$00FA     ;Carry is clear, so add 250
JMP storeDamage

;Blow Fish
;Now Damage = Spell Power * 50
org $C240FE
blowFish:
LDA $11A6      ;Spell Power
PHA            ;Push to stack
LDA #$32       ;50
PHA            ;Push to stack
JSR $3F54      ;Pearl Wind (sets 16-bit A, clears Carry, sets no split loss and ITD)
PLA            ;Pull 16-bit A
JSR $4781      ;Spell Power * 50
JMP storeDamage

;Modify Pearl Wind to also clear Carry
org $C23F5C
REP #$21

;Step Mine (not modified, but used)
org $C23EC6
storeDamage:
STA $11B0      ;Store Damage
RTS

;Out of battle functionality
org $C2474F
JMP newfunc
return:

org !freespace
reset bytes
newfunc:
JSR $2966
LDA $11A9
CMP #$44
BNE .exit      ;Exit if not special effect $22 (Stone)
JMP $3922      ;Jump there
.exit
JMP return
print bytes," bytes written to free space"
