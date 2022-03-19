; Currently checks event bits, and chooses #$FC or #$FD
; depending on whether or not Shadow is dead.
;
; Now, will check if target actor is Shadow instead.

org $C23C22 ; 14 bytes to play with, here we goooo
  JSL ShadowCheck
  NOP

org !IndividulReprisal_freespace
ShadowCheck:
  PHX
  TXA             ; X = 2x slot index
  ASL             ; 4x
  ASL             ; 8x
  ASL             ; 16x
  ASL             ; 32x = character graphics data block size
  TAX
  LDA $2EC6,X     ; Actor index
  PLX
  CMP #$03        ; Shadow actor index
  RTL             ; Z flag set if target actor is Shadow

IndividualReprisal_EOF:
