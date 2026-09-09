hirom

; Patch: Phantom Train Chests
; Author: Dark Mage [?]
; Editor: Gens
; From: train-chests.ips
;
; $CBA5C2:$CBA5D6 - Events: Phantom Train Chests
; $ED885D:$ED885F - Treasure Data: train-chests.ips (Dark Mage)
; $D9CE5C:$D9D1AB - Pointers to Map Formations
; $DB247C:$DB24A3 - Map Formations (compressed)
; $DB24C5:$DDFF20 - Map Formations (compressed)
;
; This patch makes the 2 invisible chest in the soul train visible.
; Gens altered the original patch to edit the content of the previously
; unreachable chest. It includes 1000 GP per BTB decision.

; -------------------------------------------------------------------------
; Modify the contents of the Soul Train chest to 1000 GP
org $ED885C : dw $8039 : db $0A

; -------------------------------------------------------------------------
; Check for WoR immediately prior to this code branches to color range change
; Removes Map Layer 1 chunk change and an "if WoR" colorizing shift
org $CBA5C2
  db $B2,$D6,$A5,$01     ; [>] JSL $CBA5D6 (NOTE: Could NOP instead)
  db $FE                 ; [+] RTL
  db $FF,$FF,$FF,$FF,$FF ; [+] Freespace
  db $FF,$FF,$FF,$FF,$FF ; [+] Freespace
  db $FF,$FF,$FF,$FF,$FF ; [+] Freespace
warnpc $CBA5D6

; -------------------------------------------------------------------------
; Update map formations to adjust chest visibility [?]
org $D9CE5C : incbin phantom-train-chests-1.bin : warnpc $D9D1AB ; pointers
org $DB247C : incbin phantom-train-chests-2.bin : warnpc $DB24A3
; TODO: Can this be reduced!? Look into Leet Sketcher's much smaller version
org $DB24C5 : incbin phantom-train-chests-3.bin : warnpc $DDFF20

