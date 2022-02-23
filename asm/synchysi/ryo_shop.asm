hirom
;header

table menu.tbl,ltr
	
;;-----------------------------------------------------
;;-----------------------------------------------------
;;
;;Shop Menu
;;
;;-----------------------------------------------------
;;-----------------------------------------------------
org $C3C357
	db $8f,$7b,"Attack",$00
	
org $C3FB0A

	db $1f,$79,"Hold",$fe,"Y",$fe,"for",$fe,"details",$c5,$00
	db $0d,$82,"Vigor",$00
	db $0d,$83,"Speed",$00
	db $8d,$83,"Stamina",$00
	db $8d,$82,"Magic",$00
	db $2b,$82,"Defense",$00
	db $2b,$83,"M",$C5,"Def",$C5,$00
	db $ab,$82,"Evade",$00
	db $ab,$83,"M",$C5,"Evade",$00
	db $2b,$81,"Attack",$00

org $C3F972
	db $23,$83	;Speed value

org $C3F987
	db $a3,$83	;Stamina value

org $C3F9A1
	db $a3,$82	;Magic value
	
org $C3FA29
	db $bf,$82	;Evade value
	
org $C3FA44
	db $bf,$83	;M.Evade

org $C3F9CE
	db $3f,$82	;Defense value

org $C3F9DE
	db $3f,$83	;M.Defense Value
	
org $C3FB77
	db $3f,$81,$c4,$c4,$c4,$00	;Attack hyphens
	db $3f,$82,$c4,$c4,$c4,$00	;Defense hyphens
	db $3f,$83,$c4,$c4,$c4,$00	;M.Defense hyphens
	
