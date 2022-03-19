org $C215A5
  JSL BlitzSlice
  NOP

org !HalfTurnBlitz_freespace
BlitzSlice:
  LDA #$43
  STA $3401         ; Set to display text "Incorrect Blitz input!"
  JSR HalfATBY      ; set ATB to 50%
  RTL

HalfATBBlitzFailure_EOF:
