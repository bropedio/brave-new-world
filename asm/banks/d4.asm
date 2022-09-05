hirom

; D4 Bank (misc)

; Track $25 Song Data (FFIV - Four Fiends) 
;
; NOTE: The ROM Map describes this location as being at the end of the battle animation frame data pointer table.
; I don't know if this potentially creates limitations on the creation of new battle animations – or if anyone cares.

org $D4F646
FourFiends:
  incbin bin/four-fiends.bin ; include binary song data  
