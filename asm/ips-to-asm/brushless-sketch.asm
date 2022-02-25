hirom

; Brushless Sketch
; author: Assassin
; edited: Bropedio

incsrc swordless-runic.asm

!freespace = $C2FBFD
!warnspace = $C2FC10+1

; Uncontrollable Check =============================

org $C20487 : LDX #$0B        ; increase commands to check
org $C204D7 : db $0D          ; add "Sketch" to commands
org $C204F0 : dw MuddleSketch ; point to "Sketch" handler

; Disable Commands =================================

org $C2527D
DisableCommands:
  PHX                ; store X (character index)
  PHP                ; store flags
  REP #$30           ; 16-bit A,X/Y
  TXY                ; Y: character index
  LDA MenuOffsets,X  ; character menu data offset
  TAX                ; index it
  SEP #$20           ; 8-bit A
  LDA $3018,Y        ; character unique bit
  TSB $3A58          ; flag menu to be redrawn
  LDA $3BA4,Y        ; right hand weapon properties
  ORA $3BA5,Y        ; left hand weapon properties
  EOR #$FF           ; invert ^
  AND #$82           ; "Runic","Bushido" invalid
  STA $EF            ; set flags for later ^
  JSR SketchChk      ; set bit 0 if "Sketch" invalid

  LDA #$04           ; menu slot iterator
  STA $EE            ; save ^
.big_loop
  PHX                ; save menu offset
  TDC                ; zero A/B
  LDA $0000,X        ; command ID in slot
  BMI .disable       ; branch if null
  ASL                ; x2
  TAX                ; index to command data
  LDA $3EE4,Y        ; character status-1
  BIT #$20           ; "Imp"
  BEQ .skip_imp      ; branch if not ^
  LDA $CFFE00,X      ; command data
  BIT #$04           ; "Allowed while Imp"
  BEQ .disable       ; branch if not ^
.skip_imp
  TXA                ; command ID *2
  ROR                ; restore command ID (LSR would be fine)
  LDX #$0008         ; initialize command loop
  CMP ModifyCmds,X   ; current command matches special case
  BNE .next          ; branch if not ^
  TXA                ; matched command index
.loop
  ASL                ; matched command index *2
  TAX                ; index it
  JSR (CmdModify,X)  ; call special function for command
  BRA .finish        ; break out of loop
.next
  DEX                ; decrement command to check
  BPL .loop          ; loop till all checked
  CLC                ; default to enable command
  BRA .finish        ; skip disabling
.disable
  SEC                ; mark disabled command
.finish
  PLX                ; restore menu offset
  ROR $0001,X        ; set "Disabled" bit according to carry
  INX #3             ; next menu slot offset
  DEC $EE            ; decrement slot counter
  BNE .big_loop      ; loop for 4 menu slots
  PLP                ; restore flags
  PLX                ; restore X
  RTS 

ModifyCmds:
  db $03    ; Morph
  db $0D    ; Sketch
  db $0B    ; Runic
  db $07    ; SwdTech
  db $0C    ; Lore
  db $17    ; X-Magic
  db $02    ; Magic
  db $06    ; Capture
  db $00    ; Fight

CmdModify:
  dw $5326  ; Morph
  dw $52FD  ; Sketch
  dw $5322  ; Runic
  dw $531D  ; SwdTech
  dw $5314  ; Lore
  dw $5314  ; X-Magic
  dw $5314  ; Magic
  dw $5301  ; Capture
  dw $5301  ; Fight

SketchHelp:      ; C252FD
  LDA $EF        ; disabled commands
  LSR            ; C: Sketch Invalid
  RTS

; Command Conversions ==================================

org $C2532C
CommandConversions:
  PHX               ; store X
  PHP               ; store flags
  REP #$30          ; 16-bit A, X/Y
  LDY $3010,X       ; offset to character info data
  LDA MenuOffsets,X ; offset to character menu data
  STA $002181       ; set WRAM destination address
  LDA $1616,Y       ; commands 1 and 2
  STA $FC           ; save ^
  LDA $1618,Y       ; commands 3 and 4
  STA $FE           ; save ^
  LDA $1614,Y       ; status-1 and status-4
  SEP #$30          ; 8-bit A, X/Y
  BIT #$08          ; "Magitek"
  BNE .magitek      ; branch if ^
  LDA $3EBB         ; event byte
  LSR               ; C: "Fanatics Tower"
  BCC .clear        ; branch if not ^ (or Magitek)
.magitek
  LDA $3ED8,X       ; character ID
  XBA               ; store in B
  LDX #$03          ; initialize menu slot loop
.slot_loop
  LDA $FC,X         ; command in slot
  BEQ .fight        ; branch if "Fight"
  CMP #$02          ; "Magic"
  BEQ .tower        ; branch if ^
  BCC .next_slot    ; branch if "Item"
  CMP #$12          ; "Mimic"
  BEQ .next_slot    ; branch if ^
  REP #$20          ; 16-bit A
  CMP #$0B10        ; "Gau"+"Rage"
  SEP #$20          ; 8-bit A
  BNE .blank        ; branch if not ^ (or Fight/Magic/Item/Mimic)
.fight
  LDA #$1D          ; "Magitek" command ID
  STA $FC,X         ; replace this slot with "Magitek"
.tower
  LDA $3EBB         ; event byte
  LSR               ; C: "Fanatics Tower"
  BCC .next_slot    ; branch if not ^
  LDY $FC,X         ; menu slot command
  LDA #$02          ; "Magic" command ID
  CPY #$1D          ; is slot "Magitek" (formerly "Fight/Rage")
  BEQ .set_cmd      ; branch if ^
  CPY #$02          ; is slot "Magic"
  BNE .next_slot    ; branch if not ^
.blank
  LDA #$FF          ; null command
.set_cmd
  STA $FC,X         ; update menu slot command ID
.next_slot
  DEX               ; decrement slot index
  BPL .slot_loop    ; loop through all 4 slots
.clear
  TDC               ; zero A/B
  STA $F8           ; zero scratch RAM
  STA $002183       ; set WRAM bank ($7E)
  TAY               ; zero Y
.menu_loop
  LDA $00FC,Y       ; menu slot command
  LDX $E0           ; misc. scratch RAM
  PHX               ; store/backup
  REP #$10          ; 16-bit X/Y
  JSL $C36128       ; convert menu slot based on relics, A: Cmd ID
  SEP #$10          ; 8-bit X/Y
  PLX               ; get backup scratch RAM
  STX $E0           ; restore scratch RAM
  PHA               ; store (new) command ID on stack

  LDX #$05          ; prep special command loop
.cmd_loop
  CMP CmdBlanks,X   ; matches blankable command
  BNE .next         ; branch if not ^
  TXA               ; index to blankable command
  ASL               ; x2 for jump table
  TAX               ; index it
  JSR ($BlankCmd,X) ; run special function
  BRA .done         ; break out of loop
.next
  DEX               ; next blankable command index
  BPL .cmd_loop     ; loop through all special commands
.done
  PLA               ; restore command ID (or null, or upgraded)
  STA $002180       ; save command ID in menu byte
  STA $002180       ; save in "disabled" byte (MSB determined)
  ASL               ; x2
  TAX               ; index it
  TDC               ; zero A/B
  BCS .slip         ; if command MSB was set, use 0x00 for aiming byte
  LDA $CFFE01,X     ; else, get default command aiming byte
.slip
  STA $002180       ; store command aiming byte
  INY               ; next menu slot to check
  CPY #$04          ; have we done four slots
  BNE .menu_loop    ; loop if not ^
  LSR $F8           ; C: at least one command uses MP
  BCS .exit         ; exit if ^ (BRA)
  LDA $02,S         ; retrieve character slot index
  TAX               ; index it
  REP #$20          ; 16-bit A
  STZ $3C08,X       ; zero current MP
  STZ $3C30,X       ; zero max MP
.exit
  PLP               ; restore flags
  PLX               ; restore X (character slot)
  RTS 

SketchChk:
  JSR Brushless     ; C: No brush equipped
  TDC               ; zero A/B
  ROL               ; bit0: No brush
  TSB $EF           ; set ^
  RTS

BrushHand:
  PHX               ; store X
  PHP               ; store flags (x)
  REP #$10          ; 16-bit X/Y
  XBA               ; store item ID
  PHA               ; store previous B value
  LDA #$0D          ; length of item names
  JSR $4781         ; offset to this item's name
  TAX               ; index it
  PLA               ; restore previous B value
  XBA               ; put back in B
  LDA $D2B300,X     ; first character [icon] of item name
  PLP               ; restore flags (x)
  CMP #$DD          ; brush icon
  BNE .nope         ; branch if not ^
  CLC               ; clear carry
  BRA .exit         ; and exit
.nope
  SEC               ; set carry
.exit
  PLX               ; restore X
  RTS               ; C: "No Brush Equipped"

ChkMenu:
.Morph
  LDA #$04          ; "Morph Learned"
  BIT $3EBC         ; check event bit ^
  BEQ .null         ; if not, branch to null
  BIT $3EBB         ; "Phunbaba Event"
  BEQ .exit         ; exit enabled if not ^
  LDA $05,S         ; character slot index
  TAX               ; index it
  LDA $3DE9,X       ; status-to-set-4
  ORA #$08          ; add "Morph"
  STA $3DE9,X       ; set ^ shortly
  LDA #$FF          ; 255
  STA $1CF6         ; set max morph duration
  BRA .null         ; branch to null command
.Magic
  LDA $F6           ; number of spells known
  BNE .needs_mp     ; branch if some ^
  LDA $F7           ; equipped esper
  INC               ; check for null
.try_mp
  BNE .needs_mp     ; branch if needs mp
.may_null
  BNE .exit         ; Dance/Leap jump here
.null
  JMP $0551         ; replace command on stack with $FF
.Dance
  LDA $1D4C         ; known dances
  BRA .may_null     ; null if none ^
.Leap
  LDA $11E4         ; battle flags
  BIT #$02          ; "Leap Available"
  BRA .may_null     ; null if not ^
.Lore
.needs_mp
  LDA #$01          ; "Needs MP" flag
  TSB $F8           ; set ^ in scratch RAM
.exit
  RTS

; Menu Offsets (referenced elsewhere) ========================

org $C2544A
MenuOffsets:
  dw $202E
  dw $203A
  dw $2046
  dw $2052

; Muddled Command Code Helper ================================

org $C25452
MuddleSketch:
  JSR Brushless     ; C: No Brush
  TDC               ; zero A/B (subattack)
  BCC .exit         ; exit if has brush
  JMP $054F         ; fail command
.exit
  RTS

BlankCmd:
  dw ChkMenu_Morph
  dw ChkMenu_Leap
  dw ChkMenu_Dance
  dw ChkMenu_Magic
  dw ChkMenu_Magic
  dw ChkMenu_Lore

CmdBlanks:
  db $03 ; Morph
  db $11 ; Leap
  db $13 ; Dance
  db $02 ; Magic
  db $17 ; X-Magic
  db $0C ; Lore

; Helpers in Freespace ======================================

org !freespace

C2_BrushHand:
  JSR BrushHand
  RTL

Brushless:
  LDA $3CA8,Y     ; right hand equipment ID
  JSR BrushHand   ; C: Not a brush
  BCC .exit       ; branch if is brush
  LDA $3CA9,Y     ; left hand equipment ID
  JSR BrushHand   ; C: Not a brush
.exit
  RTS

warnpc !warnspace

