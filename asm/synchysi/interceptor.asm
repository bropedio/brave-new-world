hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Alters dog block so Shadow uses one spell and Relm uses the other
; Shadow = spell ID 252
; Relm = spell ID 253

org $C24CE5
JSR Shadow_Chk
NOP

org $C23C22
Shadow_Chk:
LDA $1E94			; Load event bit
AND #$08			; Did the player leave Shadow behind on the FC?
BNE Clyde_Died		; Branch if so
LDA #$FC			; Else, load spell ID 252
RTS

Clyde_Died:
LDA #$FD			; Load spell ID 253
RTS

; EOF