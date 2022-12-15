arch 65816
hirom

table "menu.tbl", ltr ; Tabella per le stringhe di testo

; Window layout for Sell menu and main shop menu
org $C3BC1B
	dw $588B,$0107  ; 09x04 at $588B (Title)
	dw $589D,$0113  ; 21x04 at $589D (Dialogue)
	dw $594B,$0210  ; 18x04 at $598B (Options)
	dw $596F,$020A  ; 12x04 at $59AF (GP)
	dw $5A4B,$111C  ; 30x18 at $5A8B (Items)

; Window layout for Buy menu
	dw $608B,$0107  ; 09x04 at $608B (Title)
	dw $609D,$0113  ; 21x04 at $609D (Dialogue)
	dw $614B,$0d1c  ; 30x14 at $618B (Items)
	dw $650B,$061c  ; 30x08 at $650B (Actors)

; Window layout for shop order menus
	dw $688B,$0107  ; 09x04 at $688B (Title)
	dw $689D,$0113  ; 21x04 at $689D (Dialogue)
	dw $694B,$0711  ; 19x09 at $698B (Item)
	dw $6B8B,$041C  ; 30x05 at $6BCB (Description)
	dw $6D0B,$061C  ; 30x08 at $6D0B (Actors)
	dw $6971,$0709  ; 11x09 at $69B1 (Amounts)

; Window layout for shop "Hold Y" menu
org $C3fbb4
	dw $714b,$071c	; Title
	dw $750b,$061c	; Values
	dw $708b,$011c	; Description
	dw $738b,$041c	; Actors

; BG3 text shifting table for shop
Org $C3C037
	db $1F,$08,$00  ; Title
	db $08,$08,$00  ; Item 1
	db $0C,$0C,$00  ; Item 2
	db $0C,$10,$00  ; Item 3
	db $0C,$14,$00  ; Item 4
	db $0C,$18,$00  ; Item 5
	db $0C,$1C,$00  ; Item 6
	db $0C,$20,$00  ; Item 7
	db $0C,$24,$00  ; Item 8
	db $0C,$28,$00  ; Nothing
	db $0C,$2C,$00  ; Nothing
	db $0C,$30,$00  ; Nothing
	db $0C,$34,$00  ; Nothing
	db $0C,$38,$00  ; Nothing
	db $0C,$3C,$00  ; Nothing
	db $0C,$40,$00  ; Nothing
	db $00          ; End
	
;Buy_Sell_Exit Cursor value	
org $C3B89a
	dw $2a08	;Buy
	dw $2a30	;Sell
	dw $2a60	;Exit	

;Weapon cursor value
org $C3b8b4
	dw $2a00
	dw $3600
	dw $4200
	dw $4e00
	dw $5a00
	dw $6600
	dw $7200
	dw $7e00

;Rows in sell menu
org $C3BBe9
	LDA #$0B	;11 rows
	

org $C3b858
	LDX #$0029	; Cursor in selling item sub menu
org $c3b65a
	LDX #$0029	; Cursor in selling item sub menu

;shop fixes to tools and scrolls value

;rearrange new shop data and gain enough space for fix ninja scroll data and
;add HDMA scroll item menu data

;Pointers

org $C3B98A
	dw #holdy
	
org $c3f885
	dw #shopynamebox
org	$C3F88B
	dw #shopystatbox
org	$C3F891
	dw #shopydescritionbox
org	$C3F897
	dw #shopycharabox	
	
org $C3f905

	LDY #shopvigor				;pointer
	JSR $02f9					;Subroutine that print letter
	LDY #shopspeed			
	JSR $02f9
	LDY #shopstamina		
	JSR $02f9
	LDY #shopmagic
	JSR $02f9
	LDY #shopstatdefense
	JSR $02f9
	LDY #shopmdef
	JSR $02f9
	LDY #shopevade			
	JSR $02f9
	LDY #shopmevade			
	JSR $02f9
	LDY #shopattack
	JSR $02f9


org $C3F9E4
	dw #shopatthyphens
org	$C3FA0F
	LDY #shopdefhyphens
	JSR $02F9
	LDY #shopmdefhyphens
	JSR $02F9
	DW  $0680
	dw #shopquestionmarks

;Text data
org $C3FB0A

holdy:
	db $1F,$79,"Y",$fe,"for",$fe,"details",$c5,$00
shopvigor:
	db $0d,$82,"Vigor",$00
shopspeed:
	db $0d,$83,"Speed",$00
shopstamina:
	db $8d,$83,"Stamina",$00
shopmagic:
	db $8d,$82,"Magic",$00
shopstatdefense:
	db $2b,$82,"Defense",$00
shopmdef:
	db $2b,$83,"M.Def.",$00
shopevade:
	db $ab,$82,"Evade",$00
shopmevade:
	db $ab,$83,"M.Evade",$00
shopattack:
	db $2b,$81,"Attack",$00
shopquestionmarks:
	db $3f,$81,$bf,$bf,$bf,$00	 		;Question marks 
shopatthyphens:
	db $3f,$81,"---",$00				;Attack hyphens
shopdefhyphens:
	db $3f,$82,"---",$00				;Defense hyphens
shopmdefhyphens:
	db $3f,$83,"---",$00				;M.Defense hyphens
shopynamebox: 
	db $4b,$71,$1c,$07				;BCG
shopystatbox:
	db $0b,$75,$1c,$06				;BCG
shopydescritionbox:
	db $8b,$70,$1c,$01				;BCG
shopycharabox:
	db $8b,$73,$1c,$04				;BCG	
	
padbyte $ff
pad $C3fbbe
warnpc $c3fbbf

org $c3fbbf
shop0attack:
	db $3f,$81,"  0",$00		;0 set instead of - in the item shop
shop0defense:
	db $3f,$82,"  0",$00		;0 set instead of - in the item shop
shop0mdefense:
	db $3f,$83,"  0",$00		;0 set instead of - in the item shop
shop100attack:
	db $3f,$81,"100",$00		;100 set in the item shop

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
	
; BG3 V-Shift table for Item and Colosseum menus
; original data on c37f57 adress

Item_Description:
	db $2F,$00,$00  ; Title
	db $0C,$04,$00  ; Desc row 1
	db $0C,$08,$00  ; Desc row 2
	db $0C,$0C,$00  ; 2-hand
	db $0C,$10,$00  ; 50% Dmg
	db $0C,$14,$00  ; Vigor
	db $0C,$18,$00  ; Speed
	db $0C,$1C,$00  ; Stamina
	db $0C,$20,$00  ; Mag.Pwr
	db $0C,$24,$00  ; Bat.Pwr
	db $0C,$28,$00  ; Defense
	db $0C,$2C,$00  ; Evade
	db $0C,$30,$00  ; Mag.Def
	db $0C,$34,$00  ; MBlock
	db $0C,$38,$00  ; Nothing
	db $0C,$3C,$00  ; Nothing
	db $00          ; End

warnpc $c3fc20


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
	jsr $02f9
	LDY #shopdefhyphens
	jsr $02f9
	LDY #shopmdefhyphens
	
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
