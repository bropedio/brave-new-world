hirom
;header

; Lore menu length
org $C18336
		CMP #$0C		; Total lores - 4
						; Do not divide by two! That's for two-column menus.

; Lore scrollbar
org $C1838F
		LDA #$0C		; # of scrollbar rows (see above)
		STA $36

; Rage menu length
org $C184F9
		CMP #$1C		; Total rages /2 - 4


; Rage scrollbar
org $C1854A
		LDA #$1C		; # of scrollbar rows (see above)
		STA $36
		LDX #$0140		; (pixels?) per scrollbar row
		STX $2E			; Adjust as necessary so scrollbar end-point is where you want it. This should be appropriate-ish, but can definitely be fine-tuned.
		
		
		
