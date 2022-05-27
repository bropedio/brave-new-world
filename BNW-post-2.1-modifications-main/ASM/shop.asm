arch 65816
hirom

table "menu.tbl", ltr ; Tabella per le stringhe di testo

;shop fixes to tools and scrolls value

;new data in new bank

org $C3FE30
shop0attack:
	db $3f,$81,"  0",$00		;0 set instead of - in the item shop
shop0defense:
	db $3f,$82,"  0",$00		;0 set instead of - in the item shop
shop0mdefense:
	db $3f,$83,"  0",$00		;0 set instead of - in the item shop
shop100attack:
	db $3f,$81,"100",$00		;100 set in the item shop
	
;Stats value

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

;;-------------------------------------------------------
;;-------------------------------------------------------
;;
;;Setting animated sprite on tool and throwing item
;;
;;-------------------------------------------------------
;;-------------------------------------------------------

;Setting new routine that can avoid equip unequippable item
org $c2552c							;Start btl routine and set equippable item 
	jml avoid_btl_equip_routine		;Jump to routine that unequip throwing item
	
org $c39b91							;Start equip menu routine 
	jml avoid_menu_equip_routine	;Jump to routine that unequip throwing item
	nop								;Erasing old data
	nop								;Erasing old data
	
org $d86f30							;New routines
avoid_menu_equip_routine:
	rep #$20						;16-bit A
	cpx #$079e						;Is Shuriken in stock?	
	beq 13							;Skip to $C39ba3 if is it
	cpx #$07da						;Is Ninja Star in stock?	
	beq 08                          ;Skip to $C39ba3 if is it
	lda $d85001,x					;Load Compatibility item
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
	lda $d85001,x 					;Set Item's equippable characters
	jml $c25530						;Go on check if onscreen character can equip item

org $c3fa9a	
	jmp set_100_scroll				;Jump to new code instead of Shop 0 Attack value

org $c3fe50
set_100_scroll:
	ldy #shop100attack				;Load "100" attack value in Shop Menu
	cpx #$1428						;Are you on Ninja scroll water?
	beq	13							;Branch to 100 if is it
	cpx #$140a              		;Are you on Ninja scroll fire?
	beq	8                   		;Branch to 100 if is it       
	cpx #$1446						;Are you on Ninja scroll bolt?
	beq	3							;Branch to 100 if is it
	ldy	#shop0attack				;Load "0" attack value in Shop Menu
	jmp $fa9d						;Go back to original routine and start print


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