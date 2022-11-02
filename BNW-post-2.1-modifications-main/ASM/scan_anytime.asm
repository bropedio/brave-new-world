hirom
; header

; Flag for pending scan (tentative RAM)
!scan_buff = $32B8 ; controlled/controllee

; Hooks into main battle engine (clears Quick handling)
org $C2001B
CheckScanCursor:
  LDA $06             ; get X pressed
  ORA $07             ; get Y pressed
  NOP
  JSR AutoScan        ; continue scan check

org $C23C5B
  TYX           ; put target index in X
  LDA #$27      ; scan command id
  JMP $4E91     ; queue scan command in global action queue
warnpc $C23C6F

; Point to new scan command location
org $C21A15 : dw FullScan

; Move and rewrite full scan command
org $C25120
FullScan:
  LDX $B6             ; get target of original casting
  JSL ScanWeakAI
  RTS
AutoScan:
  AND #$40            ; check for X or Y pressed
  BEQ .set_buff       ; set scan buffer to zero if not pressed
  LDA $7B7E           ; current cursor enemy bitmask
  CMP !scan_buff      ; does it match last scanned
  BEQ .done           ; exit if same as last scanned
.set_buff
  STA !scan_buff      ; save bitmask of last enemy scanned (or zero)
  CMP #$00            ; is there no target selected
  BEQ .done           ; exit if no enemy targeted
  JSL ScanFork        ; else, continue scan fork
.done
  RTS
warnpc $C25142

; Helpers for scan command parts
org $C250DD
LongMsgArg:
  STA $2F35           ; save param for message
LongMsg:
  PHA                 ; store A
  PHP                 ; store flags
  SEP #$20            ; 8-bit A
  LDA #$04            ; "Message" animation type
  JSR $6411           ; process message animation
  PLP                 ; restore flags
  PLA                 ; restore A
  RTL
warnpc $C250F5

; Scan command parts
org $C4F1D0
ScanFork:
  LDX #$06            ; first monster index minus 2
.loop
  INX #2              ; next monster index
  LSR                 ; shift bitmask
  BCC .loop           ; loop till index is found
  BNE .done           ; skip if multiple enemies selected
  JSR ScanInit        ; clear params, set "battle message" op
.check_x
  BIT $06             ; pressing X check
  BVC .check_y        ; branch if not ^
  JML ScanHPMP        ; show HP/MP
.check_y
  BIT $07             ; pressing Y check 
  BVC .done           ; branch if not ^
  JML ScanStatuses
.done
  RTL

ScanInit:
  LDA #$FF            ; null (end of script marker)
  STA $2D72           ; set end-of-script flag
  LDA #$02            ; "Display Battle Msg" command ID
  STA $2D6E           ; set battle command ID
  STZ $2F37           ; clear message parameter
  STZ $2F3A           ; clear message parameter
  RTS

ScanHPMP:
  PHP                 ; store flags
  LDA #$30            ; "HP .../..." message ID
  STA $2D6F           ; set message ID
  LDA $3C95,X         ; enemy flags
  ASL                 ; isolate "boss" bit in N
  BMI .exit           ; branch if ^
  REP #$20            ; 16-bit A
  LDA $3C1C,X         ; max HP
  STA $2F38           ; save in msg data
  LDA $3BF4,X         ; current HP 
  JSL LongMsgArg      ; set arg, execute msg
  INC $2D6F           ; "MP .../..." message ID
  LDA $3C30,X         ; max MP
  BEQ .exit           ; skip MP display if zero max mp
  STA $2F38           ; save in msg data
  LDA $3C08,X         ; current MP
  JSL LongMsgArg      ; set arg, execute msg
.exit
  PLP                 ; restore flags
  RTL

ScanWeakAI:
  JSR ScanInit        ; initialize scan args
  ;LDA $3019,X         ; monster target's unique bit
  ;TRB !weakied        ; indicate weakness not exploited yet (copied to !scanned at end of turn)
  LDA #$15            ; first weakness message ID
  STA $2D6F           ; set message ID
  TDC                 ; zero A/B
  TAY                 ; zero Y
  DEC                 ; #$FF (elements to scan)
  STA $EE             ; store ^
  LDA $3BE0,X         ; weaknesses to check
  STA $EC             ; store ^
  LDA $3BE1,X         ; resisted elements
  ORA $3BCC,X         ; absorbed elements
  ORA $3BCD,X         ; immune elements
  TRB $EC             ; remove resisted, absorbed, immune elements
  JSR CheckEach       ; process these elements
  DEY                 ; check if count not zero
  BPL .ai             ; exit if at least one weakness
  LDA #$2C            ; "No Weakness" message
  STA $2D6F           ; set message ID
  JSL LongMsg         ; process "No Weakness" message animation
.ai
  ;LDA $3C94,X         ; AI hint message ID
  ;CMP #$FF            ; check null
  ;BEQ .exit           ; exit if ^
  ;STA $2D6F           ; set message ID
  ;JSL LongMsg         ; process message box animation
.exit
  RTL

ScanStatuses:
  PHP                 ; store flags
  LDA #$47            ; first status message ID
  STA $2D6F           ; set message ID
  REP #$20            ; 16-bit A
  LDY #$00            ; initialize message counter
  LDA #$F825          ; statuses (1-2) to scan
  STA $EE             ; store ^
  LDA $3EE4,X         ; current status (1-2)
  STA $EC             ; store ^
  JSR CheckEach       ; process these statuses
  LDA #$84FE          ; statuses (3-4) to scan
  STA $EE             ; store ^
  LDA $3EF8,X         ; current status (3-4)
  STA $EC             ; store ^
  JSR CheckEach       ; process these statuses
  DEY                 ; check if count not zero
  BPL .done           ; exit if at least one status msg
  JSL LongMsg         ; process "No statuses" message (#$58)
.done
  PLP                 ; restore flags
  RTL

CheckEach:
  TDC                 ; zero A/B
  INC                 ; first bit to check
.loop  
  BIT $EE             ; check if in list of "to check"
  BEQ .next           ; skip if not checking
  BIT $EC             ; check if in current status
  BEQ .skip           ; skip if not ^
  INY                 ; increment status message counter
  JSL LongMsg         ; process message box animation
.skip
  INC $2D6F           ; set message ID for next status
.next
  ASL                 ; shift bit to check
  BNE .loop           ; loop if still bits left
  RTS
warnpc $C4F2B9

