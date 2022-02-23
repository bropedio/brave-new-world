hirom
header

;Lineup Menu doesn't restore MP fix

;Add/Subtract HP from characters
org $C0AE83
exit:
JMP $AF90         ;Exit via MP code instead

org $C0AEAC
BRA exit          ;Update branch

org $C0AEC7
BRA exit          ;Update branch

org $C0AED5
JMP $AF3E       ;After maxing HP, jump to MP code
