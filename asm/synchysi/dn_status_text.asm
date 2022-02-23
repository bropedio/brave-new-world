hirom
;header

; Bugfix by Seibaby

org $c14587
;At end of routine: bit 0 = Regen, Bit 1 = Rerise, Bit 2 = Sap
XBA
PHA
XBA
LDA $2EBE,X   ; Status byte 2 (for Sap)
ROL #2        ; Rotate Sap into carry
TDC           ; Clear A
ROL           ; Rotate Sap into bit 0
XBA           ; Save Sap
	LDA $2EC0,X   ; Status byte 4 (Rerise byte)
LSR #3        ; Shift Rerise into carry
XBA           ; Get Sap again
ROL           ; Rotate Rerise into bit 0, Sap into bit 1
XBA           ; Save Sap and Rerise
	LDA $2EBF,X   ; Status byte (for Regen)
LSR #2        ; Shift Regen into carry
XBA           ; Get Sap and Rerise
ROL           ; Rotate Regen into bit 0, Rerise into bit 1, Sap into bit 2
XBA
PLA
XBA
RTS

padbyte $FF : pad $c145b3

; $20-$23 = Regen
; $24-$25 = Sap
; $20, $26-$28 = Rerise
org $c2ade1
    db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF    ; nothing
    db $20,$21,$22,$23,$FF,$FF,$FF,$FF,$FF,$FF  ; Regen
    db $20,$26,$27,$28,$FF,$FF,$FF,$FF,$FF,$FF    ; Rerise
    db $20,$21,$22,$23,$20,$26,$27,$28,$FF,$FF    ; Regen, Rerise
    db $24,$25,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF    ; Sap
    db $82,$87,$84,$80,$93,$84,$91,$FF,$FF,$FF    ; Sap, Regen
    db $24,$25,$FF,$20,$26,$27,$28,$FF,$FF,$FF    ; Sap, Rerise
    db $82,$87,$84,$80,$93,$84,$91,$FF,$FF,$FF    ; Sap, Rerise, Regen

org $c481c0
    db $F0,$E0,$F8,$90,$DB,$93,$FF,$E4,$F7,$A7,$FF,$94,$DF,$93,$DB,$00
    db $00,$00,$00,$00,$9C,$18,$FF,$A5,$F7,$25,$BF,$1D,$DF,$84,$DE,$18
    db $00,$00,$00,$00,$EF,$CA,$FF,$2D,$FF,$C9,$ED,$09,$FD,$E9,$FD,$00
    db $00,$00,$00,$00,$00,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00
    db $70,$70,$F0,$80,$C3,$83,$F7,$64,$7E,$14,$1E,$14,$FF,$E3,$F3,$00
    db $00,$00,$00,$00,$9E,$1C,$DF,$92,$DB,$92,$DF,$9C,$FE,$50,$78,$10
    db $00,$00,$03,$02,$BF,$28,$FF,$B2,$FB,$22,$33,$22,$F3,$A2,$F3,$00
    db $00,$00,$00,$00,$7B,$73,$FF,$84,$77,$67,$7F,$14,$FF,$E3,$F3,$00
    db $00,$00,$00,$00,$80,$00,$C0,$80,$C0,$00,$00,$00,$C0,$80,$C0,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
