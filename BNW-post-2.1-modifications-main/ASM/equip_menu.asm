arch 65816
hirom

;;-----------------------------------------------------;;
;;-----------------------------------------------------;;
;;                                                     ;; 
;;						Equip menu                     ;; 
;;                                                     ;; 
;;-----------------------------------------------------;;
;;-----------------------------------------------------;;

; Changing HDMA table and rearrange text position

; Initialize variables for Equip menu
org $C31BDD
C31BDD:
	JMP $fff0	   ; Set new HDMA TABLE

org $C3fff0
	LDY #C395D8
	STY $4352
	LDA #$C0
	STA $4354
	JMP $A1C3
	
;New HDMA table

org $C0ECC5
C395D8:
	db $0f,$00,$00
	db $0c,$04,$00
	db $0c,$06,$00
	db $14,$0a,$00
	db $0c,$0c,$00
	db $0c,$10,$00
	db $0c,$14,$00
	db $08,$1c,$00
	db $0c,$20,$00
	db $0c,$24,$00
	db $0c,$28,$00
	db $0c,$2c,$00
	db $0c,$30,$00
	db $0c,$34,$00
	db $0c,$38,$00
	db $0c,$3c,$00
	db $0c,$40,$00
	db $00