hirom

; ED Bank

; #########################################################################
; Esper level experience chart
org $ED8BCA
EP_Chart:
  db $20,$00  ; Level 1 = 32
  db $40,$00  ; Level 2 = 64
  db $C0,$00  ; Level 3 = 192
  db $80,$01  ; Level 4 = 384
  db $80,$02  ; Level 5 = 640
  db $00,$04  ; Level 6 = 1024
  db $00,$06  ; Level 7 = 1536
  db $80,$08  ; Level 8 = 2176
  db $80,$0B  ; Level 9 = 2944
  db $00,$0F  ; Level 10 = 3840
  db $00,$17  ; Level 11 = 5888
  db $00,$1B  ; Level 12 = 6912
  db $00,$20  ; Level 13 = 8192
  db $00,$26  ; Level 14 = 9728
  db $00,$2D  ; Level 15 = 11520
  db $00,$35  ; Level 16 = 13568
  db $00,$3E  ; Level 17 = 15872
  db $00,$48  ; Level 18 = 18432
  db $00,$53  ; Level 19 = 21248
  db $00,$5F  ; Level 20 = 24320
  db $00,$77  ; Level 21 = 30464
  db $00,$85  ; Level 22 = 34048
  db $00,$95  ; Level 23 = 38144
  db $00,$A7  ; Level 24 = 42752
  db $00,$BB  ; Level 25 = 47872