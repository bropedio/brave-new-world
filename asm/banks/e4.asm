hirom

; ########################################################################
; =============================== Bank E4 ================================
; ########################################################################

; ########################################################################
; Map Graphics

; --------------------------------------------------------------------------
; Modify eight 8x8 tiles (32 bytes each) used in the door metatiles
; in Kefka's Tower Magitek-inspired rooms (BG1, map layer index #315)
; Part of `visible-magitek-doors.asm`

org $E42CE0
  db $FF,$FF,$FF,$8F,$FF,$AE,$FF,$FF,$FF,$F5,$AF,$AF,$FF,$FF,$AB,$AE
  db $FF,$FF,$8F,$FF,$80,$FF,$FF,$AF,$F5,$AA,$AE,$FF,$D9,$AF,$8C,$FB
  db $FF,$FF,$FF,$F1,$FF,$95,$FF,$FF,$FF,$6F,$F5,$F5,$FF,$FF,$D5,$A5
  db $FF,$FF,$F1,$FF,$01,$FF,$FF,$F5,$6E,$95,$80,$FF,$0E,$F5,$24,$DB
warnpc $E42D20

org $E42EE0
  db $3F,$FD,$EF,$FB,$2F,$FC,$FB,$CE,$EF,$DC,$BF,$EA,$FF,$85,$EB,$A7
  db $90,$2F,$D1,$AE,$90,$2F,$D6,$A9,$D0,$AF,$D2,$AD,$D5,$AA,$F7,$88
  db $F5,$6F,$FE,$0D,$F7,$5F,$F5,$BB,$C7,$7D,$D7,$E8,$E9,$97,$EA,$D1
  db $2A,$D5,$0B,$F4,$5E,$A1,$BA,$45,$42,$85,$93,$44,$B8,$41,$F8,$06
warnpc $E42F20

org $E430C0
  db $EB,$A7,$AE,$C0,$FF,$A3,$EF,$05,$AD,$E1,$7F,$F7,$AF,$EB,$EF,$E7
  db $F7,$88,$90,$AF,$F3,$8C,$D5,$2A,$B5,$8A,$E7,$08,$BB,$84,$F7,$88
  db $EA,$D1,$E5,$D3,$FF,$E4,$47,$49,$85,$AF,$05,$0E,$83,$87,$C5,$CF
  db $F8,$06,$B8,$45,$E7,$78,$4A,$B5,$8E,$51,$0D,$F0,$8E,$71,$CE,$31
warnpc $E43100

org $E43100
  db $BB,$F7,$8F,$87,$92,$9F,$90,$9F,$8F,$9F,$F6,$D9,$AF,$8F,$FF,$FF
  db $E3,$88,$D7,$A8,$CF,$A0,$C0,$A0,$DF,$A0,$80,$80,$FB,$87,$FF,$FF
  db $45,$E5,$69,$FB,$15,$FD,$23,$FB,$F3,$FB,$9F,$7B,$F5,$F1,$FF,$FF
  db $CE,$11,$F2,$05,$F6,$01,$00,$05,$F8,$05,$00,$01,$DE,$E1,$FF,$FF
warnpc $E43140
