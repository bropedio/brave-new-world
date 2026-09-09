hirom

; Patch: Tube Job
; Author: Gi Nattak
; From: tube-job.ips
;
; The large glass tubes inside the Magitek Factory Laboratory have
; an issue with two of the background layer 3 tiles, an incorrect
; palette of $00 being assigned instead of $0C like the rest of the
; tube's tiles. Palette $00 is reserved for the font color, so whatever
; color the font is set to, two tiles at the top-right and top-left of
; the tube would show this same color.
;
; Modifies: $E6C300:$E6C603 - Compressed Graphics

org $E6C300 : incbin tube-job.bin : warnpc $E6C603
