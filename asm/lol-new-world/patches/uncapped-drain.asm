; This modifies the formula for drain effects to skip the drainer HP/MP check,
;   effectively making the result equal to either the base damage of the attack
;   or the target's current HP/MP, whichever is less.

org $C20E1B
  NOP
  NOP