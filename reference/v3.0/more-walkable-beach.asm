hirom

; Patch: More Walkable Beach
; Author: Fëanor
; From: more-walkable-beach.ips
;
; $D9CA1A:$D9CC4E - Map Tile Properties (compressed)
; $D9CD5E:$D9CD63 - Pointers to Map Tile Properties
;
; This patch makes walkable more beach tiles in solitary island so
; that grabbing fishes for Cid is now much easier and fast

org $D9CD5E : dw $22D8,$233C,$23BA ; update map tile property pointers

; update map tile properties
org $D9CA1A : incbin more-walkable-beach.bin : warnpc $D9CD63
