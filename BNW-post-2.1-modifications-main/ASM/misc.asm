arch 65816
hirom

table "menu.tbl", ltr ; Tabella per le stringhe di testo

;;-----------------------------------------------------
;;
;;Colosseum
;;
;;-----------------------------------------------------

;Change words position
org $C3B251
    db $EB,$78        ;Right item
org $C3B261
    db $CD,$78        ;Left item

;Change box dimension
org $C3B33F
	db $8b,$58,$0d,$01	;Left Item
	db $a9,$58,$0d,$01	;Right Item

;Moving challenger data
org $c3aefa
	ldy #$7c51

org $C3B427
	db $cd,$78,"?????????????",$00
	
;Fix gradient scale

org $D4CB42
;upper side
	dw $e001,$e702,$e603,$e503,$e403,$e302,$e203,$e103
	dw $e003,$e102,$e201,$e301,$e401,$e501,$e601,$e701

;bottom side
	dw $e070,$ea01,$e903,$e804,$e704,$e604,$e504,$e404
	dw $e304,$e204,$e104,$e004,$e104,$e204,$e304,$e404
	dw $e504,$e604,$e704,$e804,$e904,$ea02

;;-----------------------------------------------
;;Inside item submenu
;;-----------------------------------------------
org $C3331e
	ldy #$391b		;1 Name position
	
org $C3336a
	ldy #$3a9b		;2 Name position

org $C333B6
	ldy #$3c1b		;3 Name position
	
org $c33402
	ldy #$3d9b		;4 Name position


org $C38A4C
	dw #Itemowned
	
org $C38E41
Itemowned:
	db $8d,$79,"Owned:",$00

;Windows sizes
;	first value x start assis print
;	second value y start assis print
;	third value wide sizes
;	fourth value height sizes
 
org $C38A3B
	db $9d,$58,$13,$18	;Stats window
	db $8b,$58,$0c,$01	;Item window
	db $4b,$59,$07,$03	;Owned window

org $C38A54
	db $cb,$78			;Move Item name 1 line up 
org $C38a7c
	db $13,$7a			;Move quantity 1 line up

;------------------------------------------------------
;Hide rare counter item and expand description box
;------------------------------------------------------

org $c3837f 
    ldx #$7ac5        ;Set rare item conunter out of bounds and hide it
    
org $c38e4a
    db $c5,$7a,$ff,$ff,$ff,$00    ;Set blank tile over the numbers


;------------------------------------------------------------------
;Cinematic&Title Program&GFX
;------------------------------------------------------------------
check bankcross off
org $C2686C
	incbin "../asm/C2686C_Cinematic_Progam.bin"		;Cinematic Program
	
org $D8f000
	incbin "../asm/D8F000_Cinematich_Title_Isle_GFX.bin"	;Cinematic, Title, Isle GFX & Tilemap Properties
check bankcross on

;Brave New World data
org $C33BB8
	db $d1,$78,"Brave New World 2.1.1 b2",$00

;------------------------------------------------------------------
;Fixing Magitek Finger cursor position
;------------------------------------------------------------------

org $C1828A
	db $7F