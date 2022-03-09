hirom

; Overcast Fix
; author: Assassin
; editor: Bropedio

org $C24517
OvercastFix:
  LDA $3EF8,Y        ; status-3/4 [moved earlier]
  STA $FA            ; backup
  LDA $331C,Y        ; blocked-1/2
  PHA                ; store ^
  AND $3DD4,Y        ; non-blocked statuses-to-set-1/2
  STA $FC            ; save ^
  XBA : ROL          ; C: "Death" about to set
  TDC                ; zero A/B
  ROL #2             ; bit1: "Death"
  AND $3E4D,Y        ; combine "Overcast" status
  AND $01,S          ; "Zombie" not blocked
  TSB $FC            ; "Zombie" to-set if not blocked
  XBA                ; 0x0200 if ^
  LSR #2             ; 0x0080 if ^
  TRB $FC            ; remove "Death" to-set
  ASL                ; 0x0100 if ^
  TSB $F4            ; set "Doom" to-clear
  LDA $3EE4,Y        ; status-1/2
  STA $F8            ; save ^
  AND #$0040         ; isolate "Petrify"
  TSB $FC            ; reset "Petrify" if possessed
  LDA $3C1C,Y        ; MaxHP
  LSR #3             ; MaxHP / 8
  CMP $3BF4,Y        ; compare to CurrHP
  LDA #$0200         ; "Near Fatal"
  BIT $F8            ; check in current status ^
  BNE .may_remove    ; branch if ^
  BCC .done          ; branch if CurrHP > MaxHP/8
  TSB $FC            ; else to-set "Near Fatal"
.may_remove
  BCS .done          ; branch if CurrHP < MaxHP/8
  TSB $F4            ; else to-clear "Near Fatal"
.done
  PLA                ; restore blocked statuses-1/2
  AND $FC            ; remove from to-set-statuses-1/2
  STA $FC            ; update status-to-set-1/2
  PHA                ; store ^
  LDA $3DE8,Y        ; status-to-set-3/4
  AND $3330,Y        ; exclude blocked-3/4
  STA $FE            ; save ^
  PHA                ; store ^
  LDA $32DF,Y        ; hit by attack
  BPL .finish        ; branch if not ^
  JSR $447F          ; get new status
  LDA $FC            ; new status-1/2
  STA $3E60,Y        ; save quasi-status-1/2
  LDA $FE            ; new status-3/4
  STA $3E74,Y        ; save quasi-status-3/4
.finish
  PLA                ; restore status-to-set-3/4
  STA $FE            ; save ^
  PLA                ; restore status-to-set-1/2
  STA $FC            ; save ^
  RTS
  NOP
  RTS

