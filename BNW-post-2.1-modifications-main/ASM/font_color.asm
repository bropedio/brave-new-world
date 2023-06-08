arch 65816
hirom

org $c3031c
	jsl change_palette
	
org $C4B6C0
change_palette:
    cmp #$ED        ; Cmp if icon
    BCS no_change   ; greater or equal?
    cmp #$CF
    BEQ change
    cmp #$D7
    BCC no_change
change:    
    LDA #$38
    BRA color_change
no_change:    
    lda $29
color_change:    
    sta [$EB],y
    rtl

;change font's shadow

org $C0814E
    jsr changeshadow
    nop
    nop
    nop
    
warnpc $C08154

org $C0DE00
changeshadow:
	lda #$1084		; set dark gray color
	sta $7E7204
	rts

; Output all save files
org $C31632
    JSR $6C60       ; Load grayscale
    LDA #$20        ; Channel: 5
    TRB $43         ; Halt HDMA-5
    LDY #$0002      ; Y: 2
    STY $37         ; Set BG1 Y-Pos
    LDY $1D55       ; User font color
    STY $E7         ; Memorize it
    LDY #$7FFF      ; Color: white
    STY $1D55       ; Set user's font
         
; Fork: Reset font color
org $C3239B
    LDY #$7FFF      ; Color: white
    STY $1D55       ; Put in options

; Reset game data for Load menu
org $C3709E
    LDY #$7FFF      ; Color: white
	
org $D8E7d0 ; Extending palette
MenuPaletteE:
;   BCG  Shadow --- Colour
; 1st row
dw $0000,$1084,$39CE,$7FFF		;user editable color 
dw $0000,$0000,$2108,$3DEF		;gray font for unavailable choiches
dw $0000,$0000,$39CE,$03FF		;yellow font
dw $0000,$0000,$39CE,$6F60		;light blue font 

; 2nd row
dw $0000,$0000,$39CE,$6F60		;light blue font
dw $0000,$7FFF,$1084,$7FFF		;7FFF is replaced by user font in game. 3rd code is the VWF description shadow
dw $0000,$0000,$39CE,$7FFF		;white font
dw $0000,$0000,$39CE,$6F60		;ligth blue font

; 3rd row
dw $0000,$0000,$2108,$3DEF		;gray font
dw $0000,$0000,$2108,$3DEF		;gray font
dw $0000,$0000,$2108,$3DEF		;gray font
dw $0000,$0000,$2108,$3DEF		;gray font

; 4th row

dw $0000,$3C00,$2108,$3DEF		;gray font with blue shadow (Esper equipped from other actor)
dw $0000,$3868,$39CE,$7FFF		;gray font with purple shadow
dw $0000,$3868,$39CE,$7FFF		;gray font with purple shadow
dw $0000,$3868,$39CE,$7FFF		;gray font with purple shadow

; 5th row

dw $0000,$1084,$5294,$7FFF		;white font with gray shadow
dw $0000,$1084,$5294,$7FFF		;white font with gray shadow
dw $0000,$0000,$39CE,$7FFF		;white font with black shadow
dw $0000,$1084,$5294,$7FFF		;white font with gray shadow

; 6th row
YellowEL:
dw $0000,$0000,$39CE,$03FF		;yellow font (esper bonus points)
dw $FFFF,$FFFF,$FFFF,$FFFF		;null
dw $FFFF,$FFFF,$FFFF,$FFFF		;null
dw $FFFF,$FFFF,$FFFF,$FFFF		;null

;7th row
dw $0000,$0000,$39CE,$7FFF		;white font

org $C36BEE
	rep #$20			; 16 bit A
	lda MenuPaletteE,x	; Load Palette Data
	sta $7E3049,x		; Store in RAM
	sep #$20			; 8 bit A
	sta $2122			; Put LB in CGRAM
	xba					; Switch to HB
	sta $2122			; Put HB in CGRAM
	inx					; Index +1
	inx					; Index +1
	cpx #$00C8			; Set 88 colors

org $C4B500
C4B500y:
	phx
	ldx $00
pick_colory:
	LDA YellowEL,x
	sta $7E30E9,x
	inx
	cpx #$0008
	bne pick_colory
	plx
	rtl
	