hirom

; C5 Bank (music)

; -------------------------------------------------------------------------
; Expands the total number of songs the game can use and adds a pointer
; to the new song
;
; TODO: I don't think this is used anymore?

org $C53C5E : db $56
org $C53F95 : dl $D4F806

; -------------------------------------------------------------------------
; Pointer and instrument definitions for track $25 (FFIV - Four Fiends)

org $C53F05 : dl $D4F646
org $C54437 : db $1C,$00,$0D,$00,$16,$00,$12,$00,$2F
