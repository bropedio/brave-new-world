hirom

; ########################################################################
; =============================== Bank EF ================================
; ########################################################################

org $EFFBC8
Quickfill:
  XBA             ; save frame count in B
  LDX #$03        ; loop through all 4 characters
.loop
  LDA $4001,X     ; character's battle menu order
  INC             ; inactive menus are #$FF
  BNE .slower     ; if active, skip every other frame
  DEX             ; get next character index
  BPL .loop       ; loop until negative
  RTL             ; if none active, return without Z set
.slower
  XBA             ; get frame count again
  INC             ; advance one
  CMP $0E         ; compare to current frame
  RTL             ; if last loop was last frame, return Z set
