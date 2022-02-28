hirom

; Equip Overview Espers
; author: dn
; editor: Bropedio

org $C38F2B : JSR DrawEsperName
org $C38F45 : JSR DrawEsperName
org $C38F61 : JSR DrawEsperName
org $C38F7D : JSR DrawEsperName

org $C3F480
DrawEsperName:
  PHY           ; store actor name position
  LDA #$24      ; gray color
  STA $29       ; set palette
  JSR $34CF     ; draw actor name
  PLY           ; restore actor name position
  INY #32       ; add 0x20 (TODO: wtf)
  JSR $34E6     ; draw equipped esper
  LDA #$20      ; user color
  STA $29       ; set palette
  RTS
