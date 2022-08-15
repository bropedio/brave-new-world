arch 65816
hirom

;;-----------------------------------------------------
;;-----------------------------------------------------
;;
;;Status menu
;;
;;-----------------------------------------------------
;;-----------------------------------------------------

;Pointers manager
org $c35d60	;Blue text
	ldx #statusstatsandaccent			;Start pointer address
	ldy #charapoint-statusstatsandaccent	;Pointers to read (2 bytes each pointer)

org $C35D52	;Blue text
	ldx #charapoint						;Start pointer address
	ldy #slashes-charapoint				;Pointers to read (2 bytes each pointer)

org $C35D45	;White text
	ldx #slashes							;Start pointer address
	ldy #statusstatssecondpart-slashes	;Pointers to read (2 bytes each pointer)
	
org $C35d6d	;Blue text
	ldx #statusstatssecondpart			;Start pointer address
	ldy #$000C							;Pointers to read (2 bytes each pointer)


;Pointers table
org $C36437
statusstatsandaccent:
	dw #statusvigor
	dw #statusstamina
	dw #statusmagic
	dw #statusevade
	dw #statusmagicevade

charapoint:
	dw #statusLV
	dw #statusHP
	dw #statusPM

slashes:
	dw #statusslash
	dw #statusslash2

statusstatssecondpart:
	dw #statusspeed
	dw #statusattack
	dw #statusdefense
	dw #statusmagicdefense
	dw #statusexp
	dw #statusnextlv


;Data

statusslash:
	db $ab,$39,$c0,$00

statusslash2:
	db $eb,$39,$c0,$00

statusLV:
	db $5d,$39,"LV",$00
	
statusHP:
	db $9d,$39,"HP",$00
	
statusPM:
	db $dd,$39,"MP",$00
	
statusexp:
	db $cd,$7a,"Exp.",$00
	
statusnextlv:
	db $4d,$7b,"Next LV",$00
	
statusvigor:
	db $4d,$7c,"Vigor",$00
	
statusmagic:
	db $cd,$7c,"Magic",$00
	
statusspeed:
	db $4d,$7d,"Speed",$00
	
statusstamina:
	db $cd,$7d,"Stamina",$00
	
statusattack:
	db $4d,$7f,"Attack",$00
	
statusdefense:
	db $cd,$7f,"Defense",$00
	
statusmagicdefense:	
	db $eb,$7f,"M.Defense",$00
	
statusevade:
	db $4d,$88,"Evade",$00
	
statusmagicevade:
	db $6b,$88,"M.Evade",$00

padbyte $ff
pad $c3652d
warnpc $C3652D