arch 65816
hirom

table "menu.tbl", ltr

;###################################################################
;
;	Insert number before Lore
;
;###################################################################

org $C35349
	LDA $7e9d89,x	; Load Tech
	CMP #$FF		; Tech in slot?
	JML C4F300		; Jump to new tech load routine
	JMP $7FD9		; Draw name
warnpc $C35356	

org $C4F300
C4F300:	BEQ C35357		; Go to blank if not
		LDA $7e9d89,x	; Load Tech
		CMP #$FF		; Tech in slot?
		BEQ C35357		; Go to blank if not
		PHA				; Save A
		CMP #$00		; Is first tech?
		BEQ first		; Branch if so
		ASL				; Double value it
first:	LDY #$0002		; Spaces: 2
		LDX #$9E8B		; $7E9E8B
		STX $2181		; Set WRAM LBs
		TAX				; Index A value
second:	LDA.l Number,X	; Load number
		STA $2180		; Add to string
		INX				; Point to next
		DEY				; One less left
		BNE second		; Loop till last
C3846E:	LDA $4212       ; PPU status
		AND #$40        ; H-Blank?
		BEQ C3846E      ; Loop if not
		PLA             ; Name number
		STA $211B       ; Set matrix A LB
		STZ $211B       ; Clear HB
		TDC             ; Clear A
		LDA $EB         ; String size
		STA $211C       ; Set matrix B
		STA $211C       ; ...
		LDY $2134       ; Index product
		LDX $EB         ; String size
C3848A:	LDA [$EF],Y     ; Letter
		STA $2180       ; Add to string
		INY             ; Point to next
		DEX             ; One less left
		BNE C3848A      ; Loop till last
		STZ $2180       ; End string
		JML $C35353
Number:	db "1."
		db "2."
		db "3."
		db "4."
		db "5."
		db "6."
		db "7."
		db "8."

C35357: JML $C35357		; Blank if not
		
warnpc $C4F460	
		
		
		
		
