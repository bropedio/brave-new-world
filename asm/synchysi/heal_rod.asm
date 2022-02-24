hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Corrects the heal rod's default targeting

org $C25301
PHP
LDA $3CA8,Y		; Load ID of weapon in right hand
JSR Get_Tgt_Byte

Chk_LH:
LDA $3CA9,Y		; Load ID of weapon in left hand
JSR Get_Tgt_Byte
PLP
RTS

org $C25105
Get_Tgt_Byte:
JSR $2B63		; Multiply A by 30
REP #$10		; Set 16-bit X and Y
TAX
LDA $D8500E,X	; Targeting byte
CMP #$01
BNE End
REP #$21		; Set 16-bit Accumulator
LDA $06,S
TAX
SEP #$20		; Set 8-bit Accumulator
LDA #$01
STA $0002,X		; Update aiming byte with cursor moveable

End:
RTS

; EOF