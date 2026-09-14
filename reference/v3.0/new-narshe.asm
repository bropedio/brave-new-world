hirom

; New Narshe
; Author: Gi Nattak & Gens
; Editor: Bropedio

; Note that the original version of this patch shifted the minecart
; sequence palette data into $C4 to make room for the new Narshe tiles.
; But with the optimized LZSS compression algorithm we use, this was
; not necessary. Instead, we shift the WoB tile gfx earlier, as the
; preceding WoB tilemap data is reduced by 500+ bytes.
;
; Also note that the original ips needlessly replaced 0060 "unused" tile
; graphics with 0000. This asm changes ONLY what is essential.

; -----------------------------------------------------------------------
; Change tile properties for new Narshe

org $EE9BF2 : dw $001B ; Top tile of New Narshe (was $0004)
                       ; Battle background: 1 (TODO: Why?)
                       ; Airship shadow: large (was small)
                       ; No chocobo travel
                       ; No airship landing
org $EE9C12 : dw $0007 ; Bottom tile of New Narshe (was $0004)
                       ; Airship shadow: small (unchanged)
                       ; No chocobo travel
                       ; No airship landing

; -----------------------------------------------------------------------
; Update graphics pointers to account for new Narshe Tile data

org $EEB212 : dw $1000 : db $EF ; Shift WoB tile graphics offset

; -----------------------------------------------------------------------
; Update (compressed) WoB tilemap
; We will leverage asm/compressed for these changes
; NOTE: Compressed size with optimized LZSS drops by 509 bytes
compressed $EED434

org $002054 : db $6F ; set upper Narshe tile
org $002154 : db $7F ; set lower Narshe tile

warncompressed $EF1000

; -----------------------------------------------------------------------
; Add New Narshe Tile GFX to compressed WoB tile GFX
; We will leverage asm/compressed for these changes
; With these changes, compressed size is 165 larger
compressed $EF114F -> Shifting location to $EF1000

org $0001BC : db $6D,$6E,$7D,$7E ; Top Narshe tile IDs (NW,NE,SW,SE)
org $0001FC : db $8D,$8E,$9D,$9E ; Btm Narshe tile IDs (NW,NE,SW,SE)

org $0011A0 ; North Top Narshe
  db $FA,$CE,$9A,$AB,$EF,$CD,$BB,$CB,$DE,$BA,$CC,$DC,$AE,$DD,$EC,$EC
  db $EE,$FE,$FE,$EE,$FF,$FF,$FE,$AF,$FA,$BF,$AA,$AF,$B9,$EE,$AF,$BF
  db $CA,$BC,$9B,$BB,$EC,$DD,$AC,$A9,$EE,$ED,$DC,$CD,$EE,$EE,$EC,$DC
  db $AB,$EE,$AE,$AD,$FF,$EA,$9D,$FD,$FF,$FB,$DF,$BF,$AA,$BA,$FF,$BD
warnpc $0011E0

org $0013A0 ; South Top Narshe
  db $65,$68,$66,$65,$95,$98,$56,$66,$89,$98,$69,$54,$89,$99,$69,$64
  db $89,$99,$69,$66,$79,$99,$89,$78,$99,$96,$89,$89,$69,$64,$99,$99
  db $66,$56,$86,$54,$56,$66,$89,$69,$56,$96,$88,$99,$56,$96,$98,$99
  db $66,$96,$98,$99,$78,$98,$98,$99,$89,$99,$67,$99,$99,$99,$46,$96
warnpc $0013E0

org $0015A0 ; North Bottom Narshe
  db $46,$55,$96,$56,$98,$86,$69,$53,$64,$B6,$66,$15,$64,$A6,$66,$61
  db $44,$44,$64,$15,$21,$43,$64,$55,$A6,$B6,$96,$69,$43,$66,$66,$46
  db $56,$69,$55,$64,$55,$96,$68,$89,$53,$66,$6B,$46,$61,$66,$6A,$46
  db $56,$46,$44,$44,$55,$46,$34,$12,$96,$69,$6B,$6A,$64,$66,$66,$43
warnpc $0015E0

org $0017A0 ; South Bottom Narshe
  db $66,$54,$66,$44,$65,$66,$64,$44,$64,$55,$66,$44,$64,$66,$66,$44
  db $65,$46,$44,$44,$65,$36,$34,$34,$65,$23,$23,$EF,$26,$F2,$EF,$FE
  db $44,$66,$54,$66,$44,$46,$66,$55,$44,$66,$54,$56,$44,$66,$66,$45
  db $44,$44,$64,$65,$34,$34,$63,$66,$E3,$32,$32,$46,$3E,$EE,$23,$66
warnpc $0017E0

org $00243E : db $53,$35 ; Change narshe palettes (6d/6e nibbles)
org $002446 : db $53,$35 ; Change narshe palettes (7d/7e nibbles)
org $00244E : db $55,$55 ; Change narshe palettes (8d/8e nibbles)

warncompressed $EF3250
