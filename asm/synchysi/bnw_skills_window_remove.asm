hirom
header

; Written by dn

;Remove window
org $C34CC0
nop #6

;Remove MP cost display from menu corner
org $C32125
nop #3

org $c32806
nop #3

org $c32d56
nop #3

;Text removal
org $c34d8c
nop #6

org $c35203
nop #6

org $c3539b
nop #6

org $c352e8
nop #6

org $c3577e
nop #6

org $c35460
nop #6

org $c355de
nop #6

org $c34bae
C3/4BAE:	db $08,$74    	; Spell 1
C3/4BB0:	db $78,$74    	; Spell 2
C3/4BB2:	db $08,$80    	; Spell 3
C3/4BB4:	db $78,$80    	; Spell 4
C3/4BB6:	db $08,$8C    	; Spell 5
C3/4BB8:	db $78,$8C    	; Spell 6
C3/4BBA:	db $08,$98    	; Spell 7
C3/4BBC:	db $78,$98    	; Spell 8
C3/4BBE:	db $08,$A4    	; Spell 9
C3/4BC0:	db $78,$A4    	; Spell 10
C3/4BC2:	db $08,$B0    	; Spell 11
C3/4BC4:	db $78,$B0    	; Spell 12
C3/4BC6:	db $08,$BC    	; Spell 13
C3/4BC8:	db $78,$BC    	; Spell 14
C3/4BCA:	db $08,$C8    	; Spell 15
C3/4BCC:	db $78,$C8    	; Spell 16

org $c34c80
jsr flip_MP_display				; default MP display to on
nop #2							; padding

org $c34fac
ldx #$0011						; X: 17

org $c35005
lda #$c7						; ellipsis
sta $2180						; add to string
lda #$ff						; space character
sta $2180						; add to string
lda $f8							; tens digit
sta $2180						; add to string
jmp end_draw_MP
padbyte $FF : pad $c3501a

org $c35027
ldy #$000c						; letters: 12

org $c35082
lda #$ff						; space character
jmp end_draw_percent
db $FF

org $c3f700
flip_MP_display:
lda #$ff						; MP display = on
sta $9e							; store it
jsr $0f89						; stop VRAM DMA B
rts

end_draw_MP:
lda $f9							; ones digit
sta $2180						; add to string
lda #$ff						; space character
sta $2180						; add to string
stz $2180						; end string
jmp $7fd9						; draw string

end_draw_percent:
sta $2180						; add to string
stz $2180						; end string
jmp $7fd9						; draw string
