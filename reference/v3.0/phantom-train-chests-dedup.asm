hirom

; Patch: Phantom Train Chests Dedup
; Author: Bropedio
;
; This patch is a follow-up to `phantom-train-chests.asm`
;
; With the later car chests now visible, they show up in two separate
; cars which both link to the same small room. This means opening the
; chests in one room will be reflected in the other room, which is odd.
;
; My solution is to reinstitute the developers' intent of masking the
; chests in one of the rooms. This is done using a scratch event bit
; which is already in place, which tracks which of the two passenger
; lounge cars we are in.
;
; To ensure the treasure is still not accessible by examining the ground
; in the second instance of the room, I also add an open chest that blocks
; the player from facing the treasure tiles, so they cannot examine them.
; I use the open chest tile ($12) because it has automatic "unpassable"
; tile properties, wheres other tiles (like a chair) would require more
; adjustments to tile properties, etc.
;
; This patch also inline's the Seigfried subroutine, which as far as I
; can tell, is only called from this routine.

org $CBA5C2
  db $C0                 ; if one bit, then branch
  dw $017E               ; ^ "In second train car" is CLEAR
  db $B3,$5E,$00         ; ^ Branch to RTL
  db $73,$14,$07,$02,$01 ; Replace BG1 at (20,7) with 2x1 chunk
  db $18,$19             ; ^ 2x1 chunk of carpet to replace 2 chests
  db $73,$14,$09,$01,$01 ; Replace BG1 at (20,9) with 1x1 chunk
  db $12                 ; ^ 1x1 chunk (empty chest tile)
  db $C9                 ; if two bits, then branch
  dw $0188               ; ^ "No Siegfried" is CLEAR
  dw $0187               ; ^ "Fought seigfried" is CLEAR
  db $B3,$5E,$00         ; ^ branch to $CA5EB3 (jumps to FE)
  db $73,$05,$18,$01,$01 ; replace BG1 at (5,24) with 1x1 chunk
  db $12                 ; 1x1 chunk "opened chest" to replace closed chest
  db $FE                 ; RTL
warnpc $CBA5E5
