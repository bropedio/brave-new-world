hirom
;header


org $C22A44
    LDA #$20
    STA $11A4
    INC
    STA $11A2
    INC
    STA $11A3
    STZ $BA

org $C22ACD
    LDA #$08
    TSB $BA : NOP
