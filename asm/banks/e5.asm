hirom

; ########################################################################
; =============================== Bank E5 ================================
; ########################################################################

; ------------------------------------------------------------------------
; Update RNG calls to use updated C0FD00 routine

org $E5F992 : JSL Random   ; confirmed code by novalia's E5 disasm
org $E5F9AB : JSL Random   ; confirmed code by novalia's E5 disasm
org $E5F9C9 : JSL Random   ; confirmed code by novalia's E5 disasm
