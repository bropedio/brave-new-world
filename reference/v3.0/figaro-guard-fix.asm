hirom

; Patch: Figaro Guard Fix
; Author: DrakeyC
;
; [n]figaro_guard_fix (DrakeyC).ips
; This patch corrects an oversight with four guards in Figaro Castle
; The two guards by the doors to the wings of the castle, and the two
; guards by the doors to the throne room.
;
; In the event for Sabin’s flashback to when he left the castle, an event
; bit is cleared to remove these guards for the scene where he and Edgar
; are outside the castle, but this bit is never re-set. So, if Sabin’s
; flashback is viewed at any time, all four of these guards vanish and
; never reappear.
;
; This patch adds a small jump to the end of the flashback to reset the
; event bit and cause the guards to reappear.

org $CA7584 : db $FC,$42,$01 ; JMP $CB42FC

org $CB42FC
  db $D6,$0E,          ; set event bit to show guards again
  db $B2,$96,$CF,$00   ; JSL $CACF96 (NOTE: Why not JML?)
  db $FE               ; RTL

%free($CB4314) ; Not totally confident these Shadow dialogues never run...
