hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Changes the internal header name to something to keep BNW from opening in the FF3usME editor, as it is
; overwriting custom event scripting.

org $C0FFC0
DB $46,$46,$36,$3A,$20,$42,$52,$41,$56,$45,$20,$4E,$45,$57,$20,$57,$4F,$52,$4C,$44,$20
