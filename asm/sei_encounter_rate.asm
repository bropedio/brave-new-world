	;Random encounters mod for BNW
;v3 - re-jiggered some numbers courtesy of nowea
;v2 - should actually work now 
	;Should raise the minimum number of steps for a random encounter to 10, while still maintaining the overall rate
hirom
header
	!freespaceC2 = $C2FBEA
!freespaceC0 = $C0FF90
	; Overworld encounters
org $C0C48C
LDA #$E9      ; 233
JSR longCall
CLC
ADC #$04      ; Random 4..236
	; Town/dungeon encounters
org $C0C4A9
LDA #$E9      ; 233
JSR longCall
CLC
ADC #$04      ; Random 4..236
	org !freespaceC0
longCall:
JSL c2rand  ; Random 0..232
RTS
	org !freespaceC2
c2rand:
JSR $4B65
RTL