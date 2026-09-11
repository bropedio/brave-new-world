hirom

; Bank $DB

; ###########################################################################
; Map Formations Data

; -------------------------------------------------------------------------
; Update map formation data and pointers to add chest tile in the caboose.
; Replace compressed BG Layers for caboose (map formation ID: #67)
; Note that these offsets are different in BNW than FF3, due to prior
; map edits. Those edits could potentially be simplified at some point.
; The pointer to BG2 data is updated in bank $D9.
; Part of `phantom-train-chests.asm`

org $DB247C : incbin bin/caboose-bg1.bin : warnpc $DB251A
org $DB251A : incbin bin/caboose-bg2.bin : warnpc $DB2562
