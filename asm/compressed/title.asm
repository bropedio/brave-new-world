incsrc macros.asm ; Handles norom and symbol map

; #########################################################################
; Upper C2 Condensed Graphics
; (compressed at $C2A686C)
; (decompressed at $7E5000)

%baseSet($7E5000) ; Set RAM offset of decompressed code at runtime

; -------------------------------------------------------------------------
; Update some RNG uses of the C0FD00 routine
; Offsets modified to align with replaced title graphics.
; See: `ips/04-cinematic-program.ips`

%baseOrg($7E55ED)
  JSL Random

%baseOrg($7E6F15)
  JSL Random

%baseOrg($7E6F1C)
  JSL Random
