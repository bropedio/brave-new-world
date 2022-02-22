hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Prevents enemies from countering both casts of an X-Magic turn
; Original hack by Think
; Modified by Synchysi to change what free space is used

org $C20847
PHY
JSR Jump_1
PLY
NOP

org $C2140C
JSR Jump_2

org $C26744
Jump_2:
LDA $04,S
TAX
LDA $32CC,X
INC
BNE Exit
JMP Counter
RTS

Jump_1:
LDA $04,S
TAY
LDA $32CC,Y
INC
BNE Exit
ASL $32E0,X
LSR $32E0,X

Exit:
RTS

org $C24C5B
Counter:

; EOF