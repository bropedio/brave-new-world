hirom

; Compressed (F0 Bank)
;
; Since BNW does not require ROM expansion, we use the "expansion"
; ROM space to write uncompressed routines during the build phase.
; This allows us to have cross-label references with other banks.
;
; Note that some specific set-up is necessary to get this compressed
; ASM working properly. Use the macro below, and set up variables
; for offset manipulation when necessary.

macro Compressable(offset, binary)
org <offset>
  dw ?EndBin-?StartBin ; Write the length
?StartBin:
  incbin <binary> ; Write the full, unmodified, decompressed ASM
?EndBin:
endmacro

; #########################################################################
; Title, Intro, Floating Island, World Cinematics

%Compressable($F00000, bin/title-decompressed.bin)
!c_title = $F00002-$7E5000
!d_title = $7E5000-$F00002

; -------------------------------------------------------------------------
; Update several RNG calls to use new routine

org $7E5639+!c_title
  JSL Random
org $7E6F89+!c_title
  JSL Random
org $7E6F90+!c_title
  JSL Random

