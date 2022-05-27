; Two important notes about this location:
;  - it is where BNW does the check for Shadow's death and gives Relm Interceptor if he is dead
;  - it is not normally part of the event script, so it probably can't be inspected in an editor
;
; Before the auction house got gutted, freeing up ample event space for whatever, Synchysi used
; the end of the dialogue pointer bank as event space. Normally this space would house dialogue
; pointers. This stuff really should be moved to regular event bank freespace sometime; and if
; it does, this patch will need to be adjusted to modify the routine in its new home.

org $CCFE76
  db $89,$08,$00,$40    ; set status "Dog Block" on character $08 (Relm)
  db $B2,$95,$CB,$00    ; call event subroutine $CACB95 (something something party object)
  db $FE                ; return from subroutine