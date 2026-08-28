hirom

table c3.tbl,rtl

; Wrexsoul Fix
; author: dn
; editor: Bropedio

; Battle Message
org $D1F4F5
  db " ",$D3,"Mmmm",$C7,"munch, munch!",$C2,$00
  db $00
  db $00
  db $00
  db $00
  db " Wrexsoul: ",$C7,"your soul is MINE!",$00,$00

; Battle Message Pointers
org $D1F94C : dw $F50B
org $D1F94E : dw $F50C
org $D1F956 : dw $F52E
org $D1F958 : dw $F52F
