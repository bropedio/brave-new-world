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
    
;;-------------------------------------------------------
;;-------------------------------------------------------
;;
;;Setting animated sprite on tool and throwing item
;;
;;-------------------------------------------------------
;;-------------------------------------------------------

;Setting new routine that can avoid equip unequippable item
org $c2552c							;Start btl routine and set equippable item 
	jml avoid_btl_equip_routine				;Jump to routine that unequip throwing item
	
org $c39b91							;Start equip menu routine 
	jml avoid_menu_equip_routine				;Jump to routine that unequip throwing item
	nop							;Erasing old data
	nop							;Erasing old data
	
org $d86f30							;New routines
avoid_menu_equip_routine:
	rep #$20						;16-bit A
	cpx #$079e						;Is Shuriken in stock?	
	beq 13							;Skip to $C39ba3 if is it
	cpx #$07da						;Is Ninja Star in stock?	
	beq 08                          			;Skip to $C39ba3 if is it
	lda $d85001,x						;Load Compatibility item
	jml $c39b97						;Go on Check
	jml $c39ba3						;Go on to next item

avoid_btl_equip_routine:
	lda #$0000						;Set no equippable character item in Accumulator
	cpx #$079e						;Is Shuriken in stock?
	beq 29							;Skip to $c25530
	cpx #$07da						;Is Ninja star in stock?
	beq 24							;Skip to $c25530
	cpx #$1428						;Is Ninja scroll water in stock?
	beq 19							;Skip to $c25530
	cpx #$140a						;Is Ninja scroll fire in stock?
	beq 14							;Skip to $c25530
	cpx #$1446						;Is Ninja scroll bolt in stock?
	beq 09							;Skip to $c25530
	cpx #$1482						;Is Ninja scroll smoke in stock?
	beq 04							;Skip to $c25530
	lda $d85001,x 						;Set Item's equippable characters
	jml $c25530						;Go on check if onscreen character can equip item

org $c3fa9a	
	jmp set_100_scroll					;Jump to new code instead of Shop 0 Attack value

org $c3fe50
set_100_scroll:
	ldy #shop100attack		;Load "100" attack value in Shop Menu
	cpx #$1428			;Are you on Ninja scroll water?
	beq	13			;Branch to 100 if is it
	cpx #$140a              	;Are you on Ninja scroll fire?
	beq	8                   	;Branch to 100 if is it       
	cpx #$1446			;Are you on Ninja scroll bolt?
	beq	3			;Branch to 100 if is it
	ldy	#shop0attack		;Load "0" attack value in Shop Menu
	jmp $fa9d			;Go back to original routine and start print


;;-----------------------------------------------------
;;
;;Fix Tools bug
;;
;;-----------------------------------------------------

;Fix print routine
org $c3f9b6 : lda $d85000,x  ;Load Item Code
org $c3f9ba : and #$07       ;Check if #$00 is set
org $c3f9bc : beq $39	     ;Branch if is it (fixed, original code excludes print routine)

;Set Attack print value
org $d863ec : db $00,$10,$10    ;Autocrossbow 
org $d8631a : db $00,$10,$10    ;Noiseblaster 
org $d86338 : db $00,$10,$10    ;Bio Blaster
org $d863b0 : db $00,$10,$10    ;Drill value
org $d86356 : db $00,$10,$10    ;Flash value
org $d86392 : db $00,$10,$10    ;Defibrillator

;Set value number
org $d86400 : db $b4        ;Autocrossbow 
org $d8632e : db $00        ;Noiseblaster 
org $d8634c : db $2d        ;Bio Blaster
org $d863c4 : db $c8        ;Drill value
org $d8636a : db $3c        ;Flash value
org $d863a6 : db $0a        ;Defibrillator

;;-----------------------------------------------------
;;
;;Fix Scroll bug and set Shadow&Gogo animated sprite
;;
;;-----------------------------------------------------

;Set Attack print value

org $d8579e : db $11,$08,$10	;Shuriken
org $d857da : db $11,$08,$10	;Ninja Star
org $d86428 : db $16,$08,$10	;Ninja scroll water
org $d8640a : db $16,$08,$10	;Ninja scroll fire
org $d86446 : db $16,$08,$10	;Ninja scroll bolt
org $d86482 : db $16,$08,$10	;Ninja scroll smoke

;Set value number
org $d86428+20 : db $00		;Ninja scroll water
org $d8640a+20 : db $00		;Ninja scroll fire
org $d86446+20 : db $00		;Ninja scroll bolt
org $d86482+20 : db $00		;Ninja scroll smoke

;------------------------------------------------------------------
;Cinematic&Title Program&GFX
;------------------------------------------------------------------
check bankcross off
org $C2686C
	incbin "../asm/C2686C_Cinematic_Progam.bin"		;Cinematic Program
	
org $D8f000
	incbin "../asm/D8F000_Cinematich_Title_Isle_GFX.bin"	;Cinematic, Title, Isle GFX & Tilemap Properties
check bankcross on

; BNW Versioning

org $C338C9 : LDA #$28 ; yellow font
org $C33BB8 : dw $78D1 : db "Brave New World 2.1.1 b2",$00
org $C33BD7 : db $81,$9A ; correct first letter of "Battle Msg Speed" label
