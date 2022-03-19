org $C2FB5C           ; currently jumps to 50% routine
  JMP StamDogBlock

org !StamDogBlock_freeC2
StamDogBlock:
  JSL StamDogBlock_Long
  RTS

org !StamDogBlock_freeXX
  StamDogBlock_Long:
  PHA
  LDA #$C0
  JSL RNGlong         ; {0..191}
  PHA
  LDA $3B40,Y         ; Stamina
  CMP $01,S           ; Compare with RNG result
  PLA                 ; Discard stashed RNG result
  PLA
  RTL

StamDogBlock_EOF:
