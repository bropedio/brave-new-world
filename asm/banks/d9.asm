hirom

; Bank $D9

; ###########################################################################
; Map Tile Properties (compressed) [?]
; TODO: Maybe move this data into asm/compressed

; ---------------------------------------------------------------------------
; Modified by `more-walkable-beach.asm`

org $D9CA1A : db $be
org $D9CA27 : db $e9,$27,$14,$e7,$0f,$04,$00,$02,$f9,$07,$02,$fd
org $D9CA39 : db $12,$00,$fc,$2f,$1d,$08,$1a,$30,$32,$28,$2c,$60,$3a,$10,$3c
org $D9CA4E : db $6d,$30,$11,$08,$7a,$10,$29
org $D9CA5B : db $2A
org $D9CA64 : db $a5,$00,$93,$08,$b7,$10,$40,$21,$20,$8d,$10,$81,$20,$7e,$08,$93,$10,$d4,$00
org $D9CA7E : db $7b,$18,$f0,$08,$e2,$30,$04,$01,$8f,$f9,$00,$31,$8f,$fd
org $D9CA93 : incbin bin/more-walkable-beach.bin : warnpc $D9CC4E

; This pointer code is maybe not compressed
org $D9CD5E : dw $22D8,$233C,$23BA ; update map tile property pointers 

; ###########################################################################
; Map Formations Pointers

; -------------------------------------------------------------------------
; Update map formation pointer to allow adding chest tile in the caboose
; Adjust pointer for map data *after* the modified map, to accommodate the
; slightly larger compressed data for the caboose BG1 (+1 larger)
; Note that this pointer in BNW is 3 bytes smaller than in FF3
; Part of `phantom-train-chests.asm`

org $D9CE5C : dw $536A ; $D9D1B0 + $01536A -> $DB251A [see $DB bank]
