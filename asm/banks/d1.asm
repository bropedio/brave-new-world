hirom
table vwf.tbl,rtl

; D1 Bank (data)

; #########################################################################
; Battle Animation Frame Data

org $D1C649 : db $35,$07 ; Fixes Tritoch animation

; #########################################################################
; Misc. Animation Script Data

; -------------------------------------------------------------------------
; Update Sr. Behemoth entry script to change battle music

org $D1EF90 : dw anim_script_025c

; #########################################################################
; Battle Messages

; -------------------------------------------------------------------------
; Remove double exclamation marks
org $D1F007 : db $FF
org $D1F02F : db $FF
org $D1F04E : db $FF

; -------------------------------------------------------------------------

org $D1F114 : db "dark  ",$00 ; replace "poison" element type name

; -------------------------------------------------------------------------
; From dn's "Wrexsoul Fix" patch, which appears to have been added to
; fix up an issue with the "Scan Status" battle message changes.
org $D1F4F5
  db " ",$D3,"Mmmm",$C7,"munch, munch!",$C2,$00
  db $00
  db $00
  db $00
  db $00
  db " Wrexsoul: ",$C7,"your soul is MINE!",$00
  db $00
warnpc $D1F52F+1

; #########################################################################
; Battle Message Pointers
;
; From dn's "Wrexsoul Fix" patch, which appears to have been added to
; fix up an issue with the "Scan Status" battle message changes.

org $D1F94C : dw $F50B
org $D1F94E : dw $F50C
org $D1F956 : dw $F52E
org $D1F958 : dw $F52F
