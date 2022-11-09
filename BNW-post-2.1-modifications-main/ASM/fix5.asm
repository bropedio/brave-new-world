arch 65816
hirom

table "menu.tbl", ltr
;######################################################
; Initialize esper data menu
; Most of this code it's a kind of placholder
;

org $C35897
	LDY $4F         ; Cursor position
	STY $8E         ; Set return loc
	LDA $4A         ; Scroll position
	STA $90         ; Set return loc
	JSR $5B54       ; Load esper info
	JSR $599F       ; Draw esper info
	JSR $0F11       ; Queue its upload
	JSR $1368       ; Upload it now
	JSR $0EFD       ; Requeue esper list
	REP #$20        ; 16-bit A
	LDA #$0100      ; BG1 H-Shift: 256
	STA $7E9A10     ; Hide esper list
	SEP #$20        ; 8-bit A
	LDA $49         ; Top BG1 write row
	STA $5F         ; Save for return
	LDA #$07        ; BG1 VRAM row: 7
	STA $49         ; Save for V-Shift
; the only changes: JSL to $C0EC10 instead of JSR to $C34E2D
	JSL C34E2D      ; Load V-shift data
	nop
	TRB $46         ; Set anim index
	JSR $597D       ; Load navig data
	JMP $5986       ; Relocate cursor


; Load vertical shift values for BG1 text in skill menus
org $c0ec10
C34E2D:	LDX $00         ; Index: 0
C34E2F:	LDA.L C34E7F,X  ; Stats V-Data
		STA $7E9849,X   ; Save in RAM
		INX             ; Index +1
		CPX #$0012      ; At skills?
		BNE C34E2F      ; Loop if not
C34E3D:	LDA.L C34E7F,X  ; Skill V-Data
		STA $7E9849,X   ; Save in RAM
		INX             ; Index +1
		TDC             ; Clear A
		LDA $49         ; Top BG1 row
		ASL A           ; x2
		ASL A           ; x4
		ASL A           ; x8
		ASL A           ; x16
		AND #$FF        ; ...
		REP #$20        ; 16-bit A
		CLC             ; Prepare ADC
		ADC.L C34E7F,X  ; Add V-Data
		STA $7E9849,X   ; Save in RAM
		SEP #$20        ; 8-bit A
		INX             ; Index +1
		INX             ; Index +1
		CPX #$005A      ; Past list?
		BNE C34E3D      ; Loop if not
C34E63:	LDA.L C34E7F,X  ; Bottom V-Data
		STA $7E9849,X   ; Save in RAM
		INX             ; Index +1
		CPX #$005E      ; End of table?
		BNE C34E63      ; Loop if not
		LDA #$C0        ; Scrollbar: Off
		RTL
; BG1 V-Shift table for skill menus (condenses text)
C34E7F:	db $3F,$00,$00  ; LV
		db $0C,$04,$00  ; HP
		db $0C,$08,$00  ; MP
		db $0A,$0C,$00  ; Nothing
		db $01,$0C,$00  ; Nothing
		db $0D,$08,$00  ; Nothing
		
		db $04,$94,$FF  ; Ability row A
		db $04,$94,$FF  ; Ability row B
		db $04,$94,$FF  ; Ability row C
		db $04,$98,$FF  ; Ability row D
		db $04,$98,$FF  ; Ability row E
		db $04,$98,$FF  ; Ability row F
		db $04,$9C,$FF  ; Ability row G
		db $04,$9C,$FF  ; Ability row H
		db $04,$9C,$FF  ; Ability row I
		db $08,$A0,$FF  ; Ability row J
		db $08,$A0,$FF  ; Ability row K
		db $0C,$A0,$FF  ; Ability row L
		db $08,$A4,$FF  ; Ability row M
		db $08,$A4,$FF  ; Ability row N
		db $08,$A4,$FF  ; Ability row O
		db $08,$B0,$FF  ; Ability row P
		db $08,$B0,$FF  ; Ability row Q
		db $08,$B0,$FF  ; Ability row R
		db $04,$AC,$FF  ; Ability row S
		db $04,$AC,$FF  ; Ability row T
		db $04,$AC,$FF  ; Ability row U
		db $04,$B0,$FF  ; Ability row V
		db $04,$B0,$FF  ; Ability row W
		db $04,$B0,$FF  ; Ability row X
		db $1E,$20,$FF  ; Ability row Y
		db $00          ; End 
		
warnpc $c0ecd0

org $c3f41a 
	LDY #$47A9

