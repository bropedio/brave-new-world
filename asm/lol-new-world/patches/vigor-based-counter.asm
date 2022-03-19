; Change counterattack rate from (STA + 32) / 129 to
; (VIG + 32) / 128

org $C267F2
  LDA $3B2C,X         ; Vigor*2
  LSR                 ; Vigor*1
  CLC
  ADC #$20            ; + 32
  STA $10
  JSR $4B5A           ; RNG {0..255}
  LSR                 ; {0..127}
  RTS
