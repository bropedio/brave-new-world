hirom

; ########################################################################
; =============================== Bank EF ================================
; ########################################################################

; ------------------------------------------------------------------------
; Write updated minimap graphics (compressed)
; Note that the footprint is smaller, so Falcon graphics can stay
; Note we *could* shift and recompress them to free up more space
; From `minimap.asm`
org $EFE49B : incbin bin/minimap-wob.bin ; 1141 length
org $EFE910 : incbin bin/minimap-wor.bin ; 865 length

; ------------------------------------------------------------------------

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
