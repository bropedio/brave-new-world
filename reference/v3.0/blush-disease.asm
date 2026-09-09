hirom

; Patch: Blush Disease
; Author: Novalia Spirit
; From: blush-disease.ips
;
; Originally, the game skipped the blushing animation if Sabin is
; present in party, since he shares a palette with Celes. But it does
; not check for Edgar, so if Edgar is present, the blush still occurs and
; affects Celes, Sabin, and Edgar.
;
; This patch replaces the checks for Sabin by temporarily swapping
; Celes's palette with the background palette, and applying the blush
; effect to *that* palette instead.

org $CB2069                  ; Blushing
                             ; [-] (skip if Sabin present)
  db $60,$0E,$00             ; [+] Background layer $0E -> Palette $00
  db $43,$06,$06             ; [+] Celes:06 <- Palette $06
  db $B0,$0D                 ; [=] Repeat 13 times:
  db $53,$8F,$66,$66         ; [x] - Modify object colors (06,06->66,66)
  db $B1                     ; [=] - END LOOP
warnpc $CB2076
org $CB2089                  ; Unblushing
                             ; [-] (skip if Sabin present)
  db $B0,$0D                 ; [>] Repeat 13 times: 
  db $53,$2F,$66,$66         ; [x] - Modify object colors (06,06->66,66)
  db $B1                     ; [>] - End LOOP
  db $43,$06,$00             ; [+] Celes:06 <- Palette $00
  db $60,$0E,$06             ; [+] Background layer $0E -> Palette $06
warnpc $CB2096
