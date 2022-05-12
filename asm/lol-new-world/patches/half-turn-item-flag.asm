org $C25741           ; MP modification routine
  XBA                 ; flip back to MP cost
  RTS                 ; return without doing Economizer check

padbyte $FF
pad $C2574B           ; Erase Economizer code

org $C21897           ; Item command
  JSL ItemSlice
  NOP

org !HalfTurnItemFlag_freespace
ItemSlice:
  LDA $3C45,Y         ; Relic Effects 2
  BIT #$40            ; Economizer - now Half-ATB Item
  BEQ +               ; Skip if absent
  JSR HalfATBY
+ STZ $3414           ; Set ignore damage modification (displaced)
  LDA #$80            ; Ignore clear flag (displaced)
  RTL

HalfTurnItemFlag_EOF:
