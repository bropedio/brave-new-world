arch 65816
hirom

table "menu.tbl", ltr


;#########################################################################;
;                                                                         ;
;	Esper menu redefined                                                  ;
;                                                                         ;
;                                                                         ;
;                                                                         ;

; which number option finger cursor allow EL bonus
org $C33BE2
	cmp #$04		; row index description msg bouns print
	
org $c3f7b6
	cmp #$04		; on which row bonus must be given to actor

org $c35a24
	CMP #$0017      ; How many spell must be print

org $C35a3e
	jsr $7fd9		; Draw spend q.ty string
	ldy #$4693		; Bonus string Pos
	jsr $3519		; Set pos, Wram
	LDX $4216       ; Index product
	LDY #$0009      ; Letters: 9
loop:
	LDA $CFFEAE,X   ; Bonus char
	STA $2180       ; Add to string
	INX             ; Point to next
	DEY             ; One less left
	BNE loop		; Loop till last
	STZ $2180       ; End string
	JMP $7FD9       ; Draw string
padbyte $ff
pad $c35a66
warnpc $c35a67



org $c3f430		
	ldy #$460F			; El bonus position
	JSR $3519			; Set pos, WRAM
	bra .new_print
.back
	rts

warnpc $c3f43b

org $c3f46b
.new_print
	jsl print_new		; go to load string
	jsr $7fd9			; Draw EL bonus string
	jsl print_new2
	jsr $7fd9			; Draw Spend string
	jsl print_new3
	bra .back

org $c0ff20
print_new:
	lda #$24		; blue color
	sta $29			; store
	LDX $00			; Char index: 0
.loop
	LDA.L $C35CBC,X	; "At..." char
	STA $2180		; Add to string
	INX				; Point to next
	CPX #$000b		; Done all 14?
	BNE .loop		; Loop if not
	STZ $2180
	rtl
	
print_new2:	
	ldy #$4637		; "spend" position
	JSR PosWRAM		; Set pos, WRAM
	LDX $00			; Char index: 0
.loop2
	LDA.L spend,X	; "At..." char
	STA $2180		; Add to string
	INX				; Point to next
	CPX #$0006		; Done all 14?
	BNE .loop2		; Loop if not
	STZ $2180
	rtl

print_new3:
	lda #$20		; white colour
	sta $29			; store
	ldy #$46B9		; "spend" position
	JSR PosWRAM		; Set pos, WRAM
	LDX $00			; Char index: 0
.loop3
	LDA.L spendq,X	; "At..." char
	STA $2180		; Add to string
	INX				; Point to next
	CPX #$0004		; Done all 14?
	BNE .loop3		; Loop if not
	STZ $2180
	rtl

PosWRAM:
	LDX #$9E89      ; 7E/9E89
	STX $2181       ; Set WRAM LBs
	REP #$20        ; 16-bit A
	TYA             ; Tilemap ptr
	SEP #$20        ; 8-bit A
	STA $2180       ; Set position LB
	XBA             ; Switch to HB
	STA $2180       ; Set position HB
	TDC             ; Clear A
	LDY $67         ; Actor address
	RTS
spend: db "      "
spendq: db "    "
warnpc $c3f480

org $C3f30F
	db "Unspent: EL",$00
	
; Navigation data for esper data menu
org $C3598C
	db $80          ; Wraps vertically
	db $00          ; Initial column
	db $00          ; Initial row
	db $01          ; 1 column
	db $05          ; 7 rows
	
; Cursor positions for esper data menu
org $C35991
	dw $7010        ; Esper
	dw $7C18        ; Spell A
	dw $8818        ; Spell B
	dw $9418        ; Spell C
	dw $AC18        ; Bonus
	dw $AC18        ; 
	dw $B818        ; 

; rearrange esper code to avoid redoundant text on screen
org $d86e00
	db $01,$02,$0f,$07,$0a,$16,$0c,$0c,$ff,$ff,$0c
	db $01,$00,$0f,$05,$0a,$18,$0d,$0d,$ff,$ff,$0d
	db $01,$01,$0f,$06,$0a,$26,$0f,$0f,$ff,$ff,$0f
	db $0a,$1a,$0a,$20,$0f,$33,$06,$06,$ff,$ff,$06
	db $0a,$18,$14,$0c,$19,$1e,$00,$00,$ff,$ff,$00
	db $05,$03,$0f,$04,$0f,$0d,$0f,$0f,$ff,$ff,$0f
	db $05,$1c,$0a,$1b,$0f,$08,$08,$08,$ff,$ff,$08
	db $0a,$11,$0a,$34,$0a,$30,$0c,$0c,$ff,$ff,$0c
	db $0a,$1f,$0a,$1d,$0a,$29,$0e,$0e,$ff,$ff,$0e
	db $0a,$29,$0f,$24,$19,$27,$05,$05,$ff,$ff,$05
	db $14,$09,$14,$0a,$19,$0b,$0e,$0e,$ff,$ff,$0e
	db $14,$10,$19,$12,$00,$ff,$0e,$0e,$ff,$ff,$0e
	db $00,$ff,$00,$ff,$00,$ff,$0e,$0e,$ff,$ff,$0e
	db $14,$13,$19,$0f,$00,$ff,$01,$01,$ff,$ff,$01
	db $0a,$16,$14,$17,$19,$15,$00,$00,$ff,$ff,$00
	db $1e,$14,$00,$ff,$00,$ff,$01,$01,$ff,$ff,$01
	db $19,$0e,$00,$ff,$00,$ff,$09,$09,$ff,$ff,$09
	db $01,$2d,$0f,$2e,$0a,$30,$0a,$0a,$ff,$ff,$0a
	db $0f,$2a,$14,$19,$00,$ff,$04,$04,$ff,$ff,$04
	db $0a,$21,$0a,$28,$0f,$23,$0b,$0b,$ff,$ff,$0b
	db $05,$2c,$0a,$29,$0f,$24,$07,$07,$ff,$ff,$07
	db $0a,$34,$0f,$2e,$19,$32,$02,$02,$ff,$ff,$02
	db $0a,$26,$0f,$22,$00,$ff,$03,$03,$ff,$ff,$03
	db $05,$2b,$0f,$2e,$0f,$33,$0a,$0a,$ff,$ff,$0a
	db $0a,$34,$0f,$2a,$19,$25,$0d,$0d,$ff,$ff,$0d
	db $0f,$33,$14,$2f,$19,$35,$0e,$0e,$ff,$ff,$0e
	db $14,$09,$14,$2f,$19,$31,$02,$02,$ff,$ff,$02
	db $ff,$ff,$ff,$ff,$ff,$ff,$9e,$9e,$ff,$e0,$9e
	db $07,$f0,$0d,$e0,$da,$07,$50,$50,$ff,$01,$50
	db $d8,$5c,$97,$9b,$c3,$5c,$00,$00,$ff,$a9,$00
	db $00,$e0,$9e,$07,$f0,$1d,$18,$18,$ff,$f0,$18
	db $e0,$28,$14,$f0,$13,$e0,$e0,$e0,$ff,$0e,$e0
	db $46,$14,$f0,$09,$e0,$82,$01,$01,$ff,$bf,$01
	db $50,$d8,$5c,$30,$55,$c2
