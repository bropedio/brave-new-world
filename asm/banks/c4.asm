hirom

; C4 Bank

; #########################################################################
; Freespace Helpers
;
; Includes helpers for dn's "Scan Status" hack. Note that the battle
; messages added for status effects are applied separately, via the ips
; patch `[d]bnw_scan_status.ips`

org $C4F1D0
ScanWeakness:
  LDA #$15         ; "Weak to Fire"
  STA $2D6F        ; set ^ message ID
  LDA $3BE0,X      ; weaknesses byte
  BEQ .no_weakness ; branch if empty
  STA $EE          ; else, save in scratch
  LDA $3BE1,X      ; resisted elements
  ORA $3BCC,X      ; absorbed elements
  ORA $3BCD,X      ; immune elements
  TRB $EE          ; remove all from weaknesses
  LDA #$01         ; "Fire"
.elem_loop
  BIT $EE          ; check weaknesses
  BEQ .next_elem   ; branch if not weak
  PHA              ; store element bit
  LDA #$04         ; "message" animation type
  PHK              ; push $C4 onto stack
  PER .per_a-1     ; ensure JML below returns
  PEA $00CA        ; use RTL at $C200CB
  JML $C26411      ; queue message animation
.per_a
  PLA              ; restore element bit
.next_elem
  INC $2D6F        ; point to next message
  ASL              ; advance bit to next element
  BCC .elem_loop   ; loop till done
  RTL
.no_weakness
  LDA #$2C         ; "No Weakness"
  STA $2D6F        ; set ^ message ID
  LDA #$04         ; "message" animation type
  PHK              ; push $C4 onto stack
  PER .per_b-1     ; ensure JML below returns
  PEA $00CA        ; use RTL at $C200CB
  JML $C26411      ; queue message animation
.per_b
  RTL

ScanStatus:
  REP #$20         ; 16-bit A
  LDA $3EE4,x      ; status-1/2
  BIT #$F825       ; statuses to scan
  BNE .scan_away   ; branch if at least one
  LDA $3EF8,x      ; status-3/4
  BIT #$84FE       ; statuses to scan
  BNE .scan_away   ; branch if at least one
  SEP #$20         ; 8-bit A
  LDA #$58         ; "No Status"
  STA $2D6F        ; set message ID ^
  LDA #$04         ; "message" animation type
  PHK              ; push $C4 onto stack
  PER .per_c-1     ; ensure JML below returns
  PEA $00CA        ; use RTL at $C200CB
  JML $C26411      ; queue message animation
.per_c
  RTL
.scan_away
  SEP #$20         ; 8-bit A
  LDA #$47         ; first status message ID
  STA $2D6F        ; set message ID ^

  LDA $3EE4,x      ; status-1
  BIT #$01         ; "Dark"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$04         ; "Poison"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$20         ; "Imp"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte

  LDA $3EE5,x      ; status-2
  BIT #$08         ; "Mute"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$10         ; "Bserk"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$20         ; "Muddle"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$40         ; "Sap"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$80         ; "Sleep"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte

  LDA $3EF8,x      ; status-3
  BIT #$02         ; "Regen"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$04         ; "Slow"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$08         ; "Haste"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$10         ; "Stop"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$20         ; "Shell"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$40         ; "Safe"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$80         ; "Reflect"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  LDA $3EF9,x      ; status-4
  BIT #$04         ; "Death Protection"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$80         ; "Float"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  RTL

TryScan:
  BEQ .next
  LDA #$04         ; "message" animation type
  PHK              ; push $C4 onto stack
  PER .next-1      ; ensure JML below returns
  PEA $00CA        ; use RTL at $C200CB
  JML $C26411      ; queue message animation
.next
  INC $2D6F        ; point to next message ID
  RTS
warnpc $C4F2DB+1
