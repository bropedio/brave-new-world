org $C23584
  LDA #$8048      ; Unset unused $08 bit in addition to $40 Runic animation bit
                  ; This will be used to inform the counter check below.

org $C24CB5
  JSL CounterableAttack

org $C24CFC
  JSL BlackBeltCheck
  NOP

org !RunicCounter_freespace
CounterableAttack:
  LDA $11A2
  LSR
  BCS +         ; set carry and return if physical attack
  LDA $B2
  BIT #$08      ; Runic (not) triggered?
  BNE +
  SEC           ; set carry and return if Runic triggered
+ RTL

BlackBeltCheck:
  LDA $3C58,X   ; Relic effects 3
  BIT #$02      ; Black Belt flag
  BNE +         ; clear zero and return if BB equipped
  LDA $B2
  AND #$08      ; test if Runic triggered
  CMP #$08      ; Z = 0 if Runic did not trigger
+ RTL

RunicCounter_EOF:
