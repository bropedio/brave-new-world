org $C217AF           ; start of stumble routine
  JSL HalfATBStumble
  NOP

org !HalfTurnStumble_freespace
HalfATBStumble:
  JSR HalfATBY
  LDA $3EF8,Y         ; displaced from calling location
  AND #$FE            ; status byte without dance status
  RTL


; A wrapper for $C1/8A0E for when you have character index
; loaded in Y instead of X. This is used in a few other
; patches as well.

HalfATBY:
  PHX
  TYX
  JSL $C18A0E         ; set ATB to 50%
  PLX
  RTS

HalfATBStumble_EOF:
