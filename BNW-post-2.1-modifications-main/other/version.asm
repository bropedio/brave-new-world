arch 65816
hirom

table "menu.tbl",ltr

; BNW Versioning

org $C338C9 : LDA #$28 ; yellow font
org $C33BB8 : dw $78D1 : db "BNW - Nowea Hardtype 3x",$00
org $C33BD7 : db $81,$9A ; correct first letter of "Battle Msg Speed" label