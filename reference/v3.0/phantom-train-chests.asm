hirom

; Patch: Phantom Train Chests
; Author: Leet Sketcher
; Editors: Gens & Bropedio
; From: train-chests.ips
;
; This patch makes three chests in the Phantom Train visible.
;
; Two chests from the later interior rooms were being manually cleared
; by the event code in vanilla. I"m unsure of the reason, but skipping
; that event code allows them to render correctly. A better solution
; would be to check for the actual ROOM we want the chests in, since the
; room is reused in two train cars, leading the chests to be duplicated
; as well. This might be what they were initially meaning to do with this
; event code.
;
; One chest in the caboose was inaccessible to the map formation missing
; the chest tile. This is corrected by modifying the actual map data.
;
; Gens altered the original patch to edit the content of one previously
; unreachable chest. It includes 1000 GP per BTB decision.
;
; Bropedio removed the enormous, unecessary rewrite of *all* map formation
; data in the original patch, and used Leet Sketcher's modified BG2 for
; the caboose to make extra room for the new $13 "treasure" tile in the
; compressed block. This space savings is achieved by changing all the
; unused (covered by BG1) BG2 tiles from $90 -> $00. Since runs of $00 are
; available at the start of LZSS decompression (when the dictionary is all
; zeroes), using zeroes saves several bytes.
;
; -------------------------------------------------------------------------
; Modify the contents of the Soul Train chest to 1000 GP
; This change is different from the original ips.

org $ED885C : dw $8039 : db $0A

; -------------------------------------------------------------------------
; Removes explicit overwriting of the later small room chest tiles in WoB
; TODO: Investigate ways to still hide the chests in the repeated room.

org $CBA5C2
  db $B2,$D6,$A5,$01     ; [>] JSL $CBA5D6 (NOTE: Could NOP instead)
  db $FE                 ; [+] RTL
  db $FF,$FF,$FF,$FF,$FF ; [+] Freespace
  db $FF,$FF,$FF,$FF,$FF ; [+] Freespace
  db $FF,$FF,$FF,$FF,$FF ; [+] Freespace
warnpc $CBA5D6

; -------------------------------------------------------------------------
; Update map formation data and pointers to add chest tile in the caboose
; Adjust pointer for map data *after* the modified map, to accommodate the
; slightly larger compressed data for the caboose BG1 (+1 larger)
; Note that this pointer in BNW is 3 bytes smaller than in FF3

org $D9CE5C : dw $536A ; + $D9D1B0 + $010000 -> DB251A

; -------------------------------------------------------------------------
; Replace compressed BG Layers for caboose (map formation ID: #67)
; Note that these offsets are different in BNW than FF3, due to prior
; map edits. Those edits could potentially be simplified at some point.

org $DB247C : incbin bin/caboose-bg1.bin : warnpc $DB251A
org $DB251A : incbin bin/caboose-bg2.bin : warnpc $DB2562
