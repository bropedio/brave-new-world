arch 65816
hirom

;------------------------------------------------------------------
;Sap, Rerise, Regen
;------------------------------------------------------------------
	
org $C2ADE1
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	;overwrite KO
	db $ff,$20,$21,$22,$ff,$ff,$ff,$ff,$ff,$ff	;Regen
	db $ff,$20,$23,$24,$ff,$ff,$ff,$ff,$ff,$ff	;Rerise
	db $ff,$20,$21,$22,$ff,$20,$23,$24,$ff,$ff	;Regen Rerise
	db $ff,$28,$29,$ff,$ff,$ff,$ff,$ff,$ff,$ff	;Sap
	db $82,$87,$84,$80,$93,$84,$91,$ff,$ff,$ff
	db $ff,$28,$29,$ff,$ff,$20,$23,$24,$ff,$ff	;Sap Rerise
