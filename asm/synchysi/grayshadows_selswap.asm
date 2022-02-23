hirom
;header

!freespace_swapHP =  $C3F444

org $C10CFA
C10CFA:     JSR check_sel

org $C1FFE5
check_sel:  JSL swapgauge
            JMP $0B73
            
print "free space in C1 starts at: ",pc

org !freespace_swapHP

swapgauge:  LDA $1D4E       ; Is gauge disabled in config?
            BMI gauge_off

gauge_on:   LDA $0B
            BIT #$20
            BEQ .skip
            STZ $2021
            BRA .exit
.skip       LDA #$FF
            STA $2021
.exit       RTL

gauge_off:  LDA $0B
            BIT #$20
            BNE .skip
            STZ $2021
            BRA .exit
.skip       LDA #$FF
            STA $2021
.exit       RTL
            
warnpc $C40000

; Fixes a vanilla bug where the Select button was getting mapped to the R button

org $C3A5D7
LDY #$0756
