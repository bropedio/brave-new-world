hirom

; Patch: Cafe to Pub
; Author: Gens
; From: cafe-to-pub.ips
;
; $E064E0:$E06520 - Map Graphics
; $E0A0A0:$E0A0DA - Map Graphics
; $E34F80:$E34FBA - Map Graphics
; $E38040:$E38079 - Map Graphics
; $EDD480:$EDD482 - Map Palettes
;
; Uncensor patch that changes all the "Cafe" signs restoring the
; "Pub" signs used in the japanese version. There are 4 total "CAFE"
; signs in the map graphics, so four blocks below to replace each
; one with "PUB". I have not tested which block is for which map.

org $EDD480 : dw $0000 ; Modify tile palette (unsure why)

org $E064E0
  db $5d,$ff,$55,$f5,$1d,$dd,$51,$ff,$00,$e0,$40,$ff,$50,$af,$00,$ff
  db $bf,$62,$bf,$4a,$bf,$62,$bf,$6e,$bf,$5f,$af,$78,$80,$7f,$ef,$38
  db $58,$ff,$5c,$5f,$54,$57,$dc,$ff,$00,$03,$00,$ff,$0a,$f5,$00,$ff
  db $fd,$a6,$fd,$a2,$fd,$aa,$fd,$22,$fd,$fe,$f5,$0e,$01,$fe,$f7,$0d

org $E0A0A0
  db $62,$80,$6a,$80,$62,$80,$6e,$80,$26,$c0,$7f,$c0,$2f,$70,$04,$3f
  db $9d,$3f,$95,$15,$9d,$1d,$91,$19,$91,$39,$80,$00,$40,$00,$3b,$00
  db $a6,$00,$aa,$00,$a6,$00,$aa,$00,$20,$02,$fe,$02,$f4,$0e,$20,$fc
  db $58,$fc,$54,$54,$58,$5c,$54,$d4,$dc,$fc,$00,$00,$02,$00,$dc,$00

org $E34F80
  db $44,$99,$6a,$95,$66,$99,$6e,$91,$46,$91,$3d,$82,$00,$a3,$3c,$ff
  db $bf,$7f,$95,$7f,$9d,$7f,$91,$7f,$b9,$7f,$c0,$7f,$ff,$9c,$80,$8b
  db $02,$dd,$aa,$55,$a2,$5d,$2a,$d5,$02,$bd,$7c,$81,$02,$c5,$6f,$ef
  db $79,$fe,$55,$fe,$59,$fe,$55,$fe,$d9,$fe,$03,$ff,$ff,$39,$11,$90

org $E38040
  db $62,$80,$6a,$80,$62,$80,$6e,$80,$26,$c0,$7f,$c0,$2f,$70,$04,$3f
  db $9d,$3f,$95,$15,$9d,$1d,$91,$19,$91,$39,$80,$00,$40,$00,$3b,$00
  db $a6,$00,$aa,$00,$a6,$00,$aa,$00,$20,$02,$fe,$02,$f4,$0e,$20,$fc
  db $58,$fc,$54,$54,$58,$5c,$54,$d4,$dc,$fc,$00,$00,$02,$00,$dc,$00

