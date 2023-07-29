arch 65816
hirom

;------------------------------------------------------------------
;Sap, Rerise, Regen
;------------------------------------------------------------------
	
org $C2ADE1
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	;overwrite KO
	db $12,$13,$14,$15,$ff,$ff,$ff,$ff,$ff,$ff	;Regen
	db $12,$18,$19,$1a,$ff,$ff,$ff,$ff,$ff,$ff	;Rerise
	db $12,$13,$14,$15,$12,$18,$19,$1a,$ff,$ff	;Regen Rerise
	db $16,$17,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	;Sap
	db $82,$87,$84,$80,$93,$84,$91,$ff,$ff,$ff
	db $16,$17,$ff,$12,$18,$19,$1a,$ff,$ff,$ff	;Sap Rerise
