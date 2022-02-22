hirom
header

; Written by dn

table ff6_snes_battle2.tbl,rtl

;c3/3ba7 ldy #$49f2 ; bnw no exp mode setting
;c3/3ba7 ldy #$4918 ; same

org $c322d0
cmp #$07					; on controller (updated)

org $c3234a
C3234A:	dw $2341    	; Bat.Mode   (NOP)
;C3234C:	dw $2341    	; Bat.Speed  (NOP)
C3234E:	dw $2341		; Msg.Speed  (NOP)
C32350:	dw $2368    	; Cmd.Set
C32352:	dw $2341    	; Gauge      (NOP)
C32354:	dw $2341    	; Sound      (NOP)
C32356:	dw $2341    	; Cursor     (NOP)
C32358:	dw $2341    	; Reequip    (NOP)
C3235A:	dw $2379     	; Controller
C3235C:	dw $2341    	; Mag.Order  (NOP)
C3235E:	dw $2341    	; Window     (NOP)
C32360:	dw $2341    	; Color
C32362:	dw $2388    	; R
C32364:	dw $2388    	; G
C32366:	dw $2388    	; B
dw $2388

org $c33a40
lda #$07					; row: controller (updated)

org $c33867
db $81						; never wraps
db $00						; initial column
db $00						; initial row
db $01						; 1 column
db $08						; 8 rows (from 9)

ORG $C3386C
C3/386C:	dw $3560    	; Exp Mode
;C3/386E:	dw $3960    	; Bat.Speed
C3/3870:	dw $4960    	; Msg.Speed
C3/3872:	dw $5960    	; Cmd.Set
C3/3874:	dw $6960    	; Gauge
C3/3876:	dw $7960    	; Sound
C3/3878:	dw $8960    	; Cursor
C3/387A:	dw $9960    	; Reequip
C3/387C:	dw $A960    	; Controller

org $c338c9
lda #$2c						; palette 3
sta $29							; store it
ldy #bnw_text

org $c339e6
dw $588d						; position on screen
db $1a							; width+1(left)+1(right)
db $02							; height+1(top)+1(bottom)

org $c33bb7
rts
bnw_text:
dw $78cf
db "   ",$81,"rave New World 2.1b18 ",$00	; What the fuck is going on with the assembler not writing the B character properly
battle_text:
dw $3a4f
db $81,"attle","$00
padbyte $FF : pad $c33bf2
; org $c33d7a
; padbyte $FF : pad $c33dab

org $c33d43
C3/3D43: dw $3d61    	; Bat.Mode
;C3/3D45: dw $3d7a     	; Bat.Speed
C3/3D47: dw $3DAB    	; Msg.Speed
C3/3D49: dw $3DE8    	; Cmd.Set
C3/3D4B: dw $3E01    	; Gauge
C3/3D4D: dw $3E1A    	; Sound
C3/3D4F: dw $3E4E    	; Cursor
C3/3D51: dw $3E6D    	; Reequip
C3/3D53: dw $3E86    	; Controller
dw $FFFF				; ???
C3/3D55: dw $3E9F    	; Mag.Order
C3/3D57: dw $3ECD    	; Window
C3/3D59: dw $3F01    	; Viewed color
C3/3D5B: dw $3F3C    	; R
C3/3D5D: dw $3F5B    	; G
C3/3D5F: dw $3F7A    	; B

org $c34918
dw $39f5
db "On",$00

;org $c349f2
;dw $39e5
;db "Off",$00
; The above is handled by necessity in dash.asm

org $c34993
dw $49aa							; exp mode
dw battle_text					 	; "battle"
dw $49c1							; msg speed
dw $49cd							; cmd set
dw $49d7							; gauge
dw $49df							; sound
dw $49e7							; dash

org $C349AA
dw $39cf	; position for exp mode text
db "Exp.Gain", $00