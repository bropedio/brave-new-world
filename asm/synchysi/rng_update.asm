hirom   ; Don't change this
header  ; Comment out if your ROM has no header

; Updates the RNG to improve the actual randomness of it
; Patch by Think
; Stuff moved around by Synchysi

org $C0062E
JSL $C0FD00
RTS

;org $C0BDE4		; Old initialization routine. Now handled in esper_changes.asm
;LDA #$01
;STA $01F1
;STZ $01F2
;NOP
;NOP
;NOP

org $C0FD00
PHP
SEP #$20
XBA
PHA
REP #$20
LDA $01F1
ASL
ASL
EOR $01F1
STA $01F1
LSR
LSR
LSR
LSR
LSR
LSR
LSR
EOR $01F1
STA $01F1
ASL
ASL
ASL
ASL
ASL
ASL
ASL
ASL
ASL
ASL
ASL
ASL
ASL
ASL
ASL
EOR $01F1
STA $01F1
SEP #$20
PLA
XBA
LDA $01F1
EOR $01F0
PLP
RTL

; The rest of RNG table is cleared out, to illustrate the copious free space available. 192 bytes free!

org $C3140D
JSR $F570

org $C3F570
INC $021E
INC $01F0
RTS

; Below changes all calls to the RNG

org $C00636
JSL $C0FD00

org $C04012
JSL $C0FD00

;org $C0C48C		; Now handled in Seibaby's compilation patch
;JSL $C0FD00

;org $C0C4A9		; Functionality changed in sei_encounter_rate.asm
;JSL $C0FD00

org $C11861
JSL $C0FD00

org $C1CD53
JSL $C0FD00

org $C1CECF
JSL $C0FD00

org $C24B5F
JSL $C0FD00

org $C24B6F
JSL $C0FD00

org $C2BBEC
JSL $C0FD00

org $C2BC9B
JSL $C0FD00
