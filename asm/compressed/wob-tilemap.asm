incsrc macros.asm ; Handles norom and symbol map

; #########################################################################
; WoB Tilemap
; (compressed at $EED434)
; (decompressed at $000000)

; -------------------------------------------------------------------------
; Use "New Narshe" tiles for Narshe entrance
; Part of `new-narshe.asm`

org $002054 : db $6F ; set upper Narshe tile
org $002154 : db $7F ; set lower Narshe tile

