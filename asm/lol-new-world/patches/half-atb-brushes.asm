org $C229C5
  JSL HalfATBWeapon
  NOP

org !HalfTurnBrushes_freespace
HalfATBWeapon:
  LDA $3BA4,X       ; weapon properties
  PHA
  BIT #$10          ; half-atb flag
  BEQ +
  JSL $C18A0E       ; set ATB to 50%
+ PLA
  AND #$60          ; isolate "Same damage from back row" and "2-hand" properties (displaced from calling location)
  RTL               ; continue

HalfTurnBrushes_EOF:
