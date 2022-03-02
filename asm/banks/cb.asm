hirom

; CB Bank

; ########################################################################
; Ebot's Rock Coral Event(s)
;
; Allow collected coral to accumulate when feeding chest. Note, jumps to
; subroutines in E6 Bank. This is part of Gi Nattak's "No Coral for You"
; patch

org $CB7107
  db $B2 : dl $1CCD44 ; JSR CoralHelper2
  db $FE              ; RTS
  padbyte $FF
  pad $CB711B

; Branch to Coral Helper 1
org $CB712A
  db $B2 : dl $1CCD3D ; JSR CoralHelper1
