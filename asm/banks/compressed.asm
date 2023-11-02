hirom

; Compressed (F0 Bank)
;
; Since BNW does not require ROM expansion, we use the "expansion"
; ROM space to write uncompressed routines during the build phase.
; This allows us to have cross-label references with other banks.
;
; Note
; When adding new compressed sections, the `scripts/lzss.sh` script
; must be updated with the correct offsets and file names. You also
; must `incbin` the compressed binary at the correct code offset.
;
; eg: incbin ../../temp/intro.compressed
;
; For all internal JSR and JMP ops, set up variables using the macro below

macro Compressable(offset, actual, binary)
  org <offset>
  incbin <binary> ; Write the full, unmodified, decompressed ASM
  !c_offset = <offset>+2-<actual>
  !c_invert = <actual>-<offset>-2
endmacro

macro OrgOffset(offset)
  org <offset>+!c_offset
endmacro

macro OrgInvert(offset)
  org <offset>+!c_invert
endmacro

; #########################################################################
; Title, Intro, Floating Island, World Cinematics

%Compressable($F00000, $7E5000, ../../temp/intro.decompressed)

; -------------------------------------------------------------------------
; Update several RNG calls to use new routine

%OrgOffset($7E5639)
  JSL Random
%OrgOffset($7E6F89)
  JSL Random
%OrgOffset($7E6F90)
  JSL Random

