incsrc macros.asm ; Handles norom and symbol map

; #########################################################################
; Upper C2 Condensed Graphics
; (compressed at $C2A686C)
; (decompressed at $7E5000)

%baseSet($7E5000) ; Set RAM offset of decompressed code at runtime

; -------------------------------------------------------------------------
; Update some RNG uses of the C0FD00 routine

%baseOrg($7E5639)
  JSL Random

%baseOrg($7E6F89)
  JSL Random

%baseOrg($7E6F90)
  JSL Random
