hirom   ; Don't change this
;header  ; Comment out if your ROM has no header

; Changes the delay on some combat abilities to put them more in line with their comparitive strengths
; All data is found in a table at $C2067B
; All locations have only been tested in FF3US ROM version 1.0

org $C2067B
DB $10   ; Fight
DB $10   ; Item
DB $20   ; Magic
DB $40   ; Morph
DB $00   ; Revert
DB $00   ; Steal
DB $00   ; Capture
DB $20   ; Bushido
DB $10   ; Throw
DB $20   ; Tools
DB $20   ; Blitz
DB $00   ; Runic
DB $20   ; Lore
DB $10   ; Sketch
DB $20   ; Control
DB $20   ; Slot
DB $10   ; Rage
DB $00   ; Leap
DB $00   ; Mimic
DB $10   ; Dance
DB $00   ; Row
DB $00   ; Defend
DB $70   ; Jump
DB $20   ; X-Magic
DB $20   ; GP Rain
DB $40   ; Summon
DB $10   ; Health
DB $10   ; Shock
DB $00   ; Possess
DB $00   ; MagiTek

; EOF
