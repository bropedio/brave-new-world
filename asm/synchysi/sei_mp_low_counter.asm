; HP/MP low counter redesign
; By Seibaby
	; FC command $06 (HP low counter) normally checks HP versus <parameter> * 128 while
; FC command $07 (MP low counter) checks MP versus <param> only. This makes it so that
; MP is compared to <param> * 128 as well.
hirom
header
	; FC command $06 (HP low counter)
org $C21D61
dw mpLowCounter
	
; FC command $07 (MP low counter)
org $C21D63
dw mpLowCounter
	org $C21BB7
mpLowCounter:
        JSR $1D34
        BCC .exit
	        TDC
        LDA $3A2F
        XBA
        REP #$20
        LSR
	        CPX #$0E     ; is it command $07 - MP low counter?
        BCC .hp     ; branch if it's not (ie. it's $06 - HP low counter)
        CMP $3C08,Y ; MP
        BRA .exit
.hp        CMP $3BF4,Y ; HP
.exit    RTS
;        padbyte $FF : pad $C21BD6
        warnpc $C21BD7