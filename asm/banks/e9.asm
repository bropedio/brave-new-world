hirom

; Bank $E9

; ###########################################################################
; Battle Background Graphics [?]

; ---------------------------------------------------------------------------
; Modified as part of `eddie-bg.asm` patch

org $E935D6 : dw $1048 ; battle bg gfx (compressed)
org $E935E4 : db $E8 ; battle bg gfx (compressed)
org $E93651 : db $FB ; battle bg gfx (compressed)
org $E93678 : incbin bin/eddie-bg-gfx-1.bin : warnpc $E9454B
org $E9461E : dw $0FCC ; battle bg gfx (compressed)
org $E94752 : db $79 ; battle bg gfx (compressed)
org $E94776 : incbin bin/eddie-bg-gfx-2.bin : warnpc $E955E9
