hirom

; C3 Bank

; #########################################################################
; Initialize Rage Menu
;
; Modified by dn's patch to handle BNW's reduced rage set (64)

org $C321AD : LDA #$03f0 ; fix arrow (scrollbar speed)
org $C321C3 : LDA #$18   ; set scroll limit (8 onscreen + 24 scroll * 2 = 64)

; #########################################################################
; Build Rage List
;
; Rewritten by Assassin for "Alphabetical Rage" patch. Included notes:
;   Generates alphabetical Rage list under the Skills menu.  Loops for all 256 enemies.
;   Function C3/5418 still needs to process this list to display the names.  I tweaked that
;   routine to make sure it preserves the ordering established here.

org $C353C1
BuildRageList:
  LDX #$9D89       ; WRAM buffer address
  STX $2181        ; set ^
  SEP #$10         ; 8-bit X/Y
  LDX $00          ; zero iterator
.loop
  LDA RageList,X   ; next sorted rage ID
  TAY              ; index it
  PHX              ; store iterator
  CLC              ; $C25217 treats carry as bit 9 of A
  JSL LongByteMod  ; X: byte index, A: bitmask for this rage bit
  BIT $1D2C,X      ; compare to known rages
  BEQ .null        ; branch if not learned yet
  TYA              ; else, get rage ID
  BRA .save        ; and branch to save it
.null
  LDA #$FF         ; "null" entry
.save
  STA $2180        ; store rage in menu
  PLX              ; restore iterator
  INX              ; next sorted rage index
  BNE .loop        ; loop until 256 rollover TODO: Update this for BNW
  REP #$10         ; 16-bit X/Y
  RTS
  NOP #3           ; [fill empty space]
  RTS              ; [fill empty space]
warnpc $C353EE+1

; #########################################################################
; Draw Rage Name
;
; Largely rewritten as part of Assassin's "Alphabetical Rage" patch. See notes:
;   - If a given menu slot holds FFh, display a blank string in place of the enemy's name.
;   - If the slot holds 0-FEh, display the name of the enemy whose number matches the current
;     menu slot's *contents*.  This is a change from the original code, which used the
;     enemy number equal to the slot's position.  The home of that rowdy second "LDA $E5" is
;     now inhabited by peaceful NOPs.

org $C35418
DrawRageName:
  LDA $E6         ; current row
  INC             ; one row below
  JSR $809F       ; X: tile position
  REP #$20        ; 16-bit A
  TXA             ; tile position in A
  STA $7E9E89     ; save to buffer
  SEP #$20        ; 8-bit A
  TDC             ; zero A/B
  LDA $E5         ; rage slot index
  TAX             ; index it
  LDA $7E9D89,X   ; rage ID in this slot
  CMP #$FF        ; "null" (unlearned rage)
  BEQ .null       ; branch if ^
  NOP #2          ; [unused space]
  JSR $8467       ; load enemy name
  JMP $7FD9       ; draw enemy name
.null
  LDY #$000A      ; length of enemy names
  LDX #$9E8B      ; WRAM address
  STX $2181       ; set ^
  LDA #$FF        ; " " (space)
.space_loop
  STA $2180       ; write space
  DEY             ; next character
  BNE .space_loop ; loop for full length
  STZ $2180       ; EOL
  JMP $7FD9       ; draw empty name
warnpc $C35452+1

; #########################################################################
; Draw Blitz Inputs
;
; Jump added by dn's "Blitz Menu" patch, to draw Blitz names as well

org $C3565D : JSR BlitzNames

; #########################################################################
; Draw command names based on availability
;
; Rewritten as part of Assassin's "Brushless Sketch" patch to save space
; and add support for "Sketch" disabling based on whether a brush is equipped.

org $C35ED7
CmdListA:
  PHA                ; store command ID
  JSR $3519          ; prepare name drawing
  PLA                ; restore command ID
  BMI CmdListB_blank ; branch if null
  BRA CmdListB_skip  ; else, continue
  NOP
org $C35EE1
CmdListB:
  JSR $612C          ; check blanked commands (Magic/Morph/Leap/etc)
  BMI .blank         ; branch if ^
.skip
  JSR CmdPalette     ; pick a palette
  STA $E2            ; save command number
  ASL                ; x2
  CLC : ADC $E2      ; x3
  ASL                ; x6
  CLC : ADC $E2      ; x7
  TAX                ; index it
  CLC                ; clear carry (indicates non-null cmd)
.init_loop
  LDY #$0007         ; prep loop through command name
.loop     
  BCS .set           ; skip loading letter if null cmd
  LDA $D8CEA0,X      ; else, load next letter
.set
  STA $2180          ; write to WRAM
  INX                ; increment source
  DEY                ; decrement remaining
  BNE .loop          ; loop till done
  STZ $2180          ; write EOL byte
  CLC                ; clear carry
  JMP $7FD9          ; draw string
.blank
  LDA #$FF           ; space character
  SEC                ; set carry (indicates null-cmd)
  BRA .init_loop     ; write 7 spaces
CmdPalette:
  PHA                ; store command ID
  CMP #$0B           ; "Runic"
  BNE .bushido       ; branch if not ^
  LDA $11DA          ; right hand properties
  ORA $11DB          ; left hand properties
  BPL .gray          ; branch if no Runic support
  BRA .white         ; display the command lit up
.bushido
  CMP #$07           ; "Bushido"
  BNE .sketch        ; branch if not ^
  LDA $11DA          ; right hand properties
  ORA $11DB          ; left hand properties
  BIT #$02           ; "Bushido Allowed"
  BEQ .gray          ; branch to disable if no ^
  BRA .white         ; else branch to show
.sketch
  CMP #$0D           ; "Sketch"
  BNE .white         ; enable if not ^ (or other previous)
  LDA $11C6          ; right hand equipment slot
  JSL $C2FBFD        ; C: Not a brush
  BCC .white         ; branch if is brush
  LDA $11C7          ; left hand equipment slot
  JSL $C2FBFD        ; C: Not a brush
  BCS .gray          ; branch if ^
.white
  LDA #$20           ; user color palette (white)
  BRA .palette       ; branch to finish
.gray
  LDA #$24           ; gray color
.palette
  STA $29            ; update palette
  PLA                ; restore command ID
  RTS
warnpc $C35F50+1

; #########################################################################
; Yellow Streak Fix (Gogo's Menu)

org $C35f50 : LDX #$620A ; nudge mask around Gogo portrait

; #########################################################################
; Status Screen Commands
; 
; Rewritten as part of Assassin's "Brushless Sketch" patch to make room
; for a helper function. This new helper exposes $C36172 (command upgrades)
; to the C2 menu command routine(s).

org $C36102
StatusCmdOpt:
  LDY #$7BF1
  JSR $4598
  LDY #$7C71
  JSR $459E
  LDY #$7CF1
  JSR $45A5
  LDY #$7D71
  JSR $45AD
  RTS

padbyte $EA : pad $C36128

Long6172:
  JSR $6172      ; Access to existing relic cmd changes (from C2)
  RTL
warnpc $C3612C+1

; #########################################################################
; Menu Label Changes (part 1)
;
; Percent symbols (%) overwritten with spaces by dn's "No Percents" patch

org $C36482 : db $FF ; replace '%' with ' '
org $C36486 : db $FF ; replace '%' with ' '
org $C364BB : db $FF ; replace '%' with ' '
org $C364C5 : db $FF ; replace '%' with ' '
org $C38D9B : db $FF ; replace '%' with ' '
org $C38DA5 : db $FF ; replace '%' with ' '

; #########################################################################
; Review Screen Draw Routines
;
; Modified by dn's "Equip Overview Espers" patch to include equipped esper
; names immediately to the right of the character's name.

org $C38F2B : JSR DrawEsperName
org $C38F45 : JSR DrawEsperName
org $C38F61 : JSR DrawEsperName
org $C38F7D : JSR DrawEsperName

; #########################################################################
; Sustain Relic and Sustain Equip Menus
;
; Modifictions to button press handlers to handle Y button presses to
; swap between relic and equip menus. Part of dn's "Y Screen Swap" patch

org $C39648 : JMP EquipSwap : NOP #4
org $C398C8 : JMP EquipSubSwap : NOP #4
org $C39908 : JMP EquipSubSwap : NOP #4

org $C39EDC : JSR RelicSwap
org $C3A047 : JSR RelicSwap
org $C3A146 : JSR RelicSwap

; #########################################################################
; Menu Label Changes (part 2)
;
; Percent symbols (%) overwritten with spaces by dn's "No Percents" patch

org $C3A395 : db $FF ; replace '%' with ' '
org $C3A39F : db $FF ; replace '%' with ' '

; #########################################################################
; Shop Menu equippability UI

org $C3C29C : BRA $3F ; Never show equipped/up/down/equal icons

; #########################################################################
; Freespace Helpers

org $C3F480
DrawEsperName:
  PHY           ; store actor name position
  LDA #$24      ; gray color
  STA $29       ; set palette
  JSR $34CF     ; draw actor name
  PLY           ; restore actor name position
  INY #32       ; add 0x20 (leaves space for character name)
  JSR $34E6     ; draw equipped esper
  LDA #$20      ; user color
  STA $29       ; set palette
  RTS
warnpc $C3F4B1+1

; Duplicate Unused ==========================================
; TODO: This "dup" namespace code is unused, and duplicative
; of the routine at C3F530. It has been preserved for now to
; avoid changing any code/patch behavior during initial code
; migration, but it can be removed ASAP.

namespace "dup"
org $C3F4B1
EquipSwap:
  BIT #$40
  BNE ToRelics
  LDA #$35
HandleLR:
  STA $E0
  JMP $2022
ToRelics:
  JSR $0EB2
  LDA #$58
  STA $26
  ;INC $25
  RTS
RelicSwap:
  LDA $09
  BIT #$40
  BEQ .skip
  JSR $0EB2
  JSR $1E5F
  BCS .skip
  JSR $9EEB
  LDA $99
  BNE .skip
  LDA #$35
  STA $26
  STZ $27
  ;DEC $25
.skip
  JMP $9EE6
EquipSubSwap:
  BIT #$40
  BNE ToRelics
  LDA $26
  CLC : ADC #$29
  BRA HandleLR
warnpc $C3F4ED+1
namespace off

org $C3F4F0
BlitzNames:
  PHA               ; store blitz ID
  PHY               ; store Y [TODO: unnecessary]
  ASL               ; x2
  PHA               ; store blitz ID x2
  ASL #2            ; x4 (now x8)
  ADC $01,s         ; add x2 (now x10)
  TAX               ; index to Blitz name
  LDY #$9E8B        ; WRAM buffer address
  STY $2181         ; set ^
  LDA #$20          ; user color (white)
  STA $29           ; set palette
  LDY #$000A        ; 10 (length of blitz name)
.loop
  LDA $E6F831,X     ; blitz name byte
  STA $2180         ; write letter to buffer
  INX               ; increment name index
  DEY               ; decrement buffer size
  CPY #$0000        ; at zero [TODO: unnecessary CPY]
  BNE .loop         ; loop through all 10 tiles
  STZ $2180         ; EOL
  PLY               ; clean up stack some [TODO: unnecessary, and broken]
  JSR $7FD9         ; draw name from buffer
  REP #$21          ; 16-bit A, set carry
  LDA $7E9E89       ; tilemap address
  ADC #$0084        ; increment to next Blitz name location
  STA $7E9E89       ; update tilemap address
  TDC               ; zero A/B
  SEP #$20          ; 8-bit A
  PLA               ; clean up stack (hi byte of PHY earlier)
  PLA               ; get Blitz ID back
  JMP $5683         ; [moved] build tilemap
warnpc $C3F530+1

org $C3F530
EquipSwap:
  BIT #$40          ; pressing Y
  BNE ToRelics      ; branch if ^
  LDA #$35          ; [moved] "Initialize Equip Menu"

HandleLR:
  STA $E0           ; [moved] set ^
  JMP $2022         ; handle L/R

ToRelics:
  JSR $0EB2         ; play click sound
  LDA #$58          ; "Initialize Relic Menu"
  STA $26           ; set next menu action
  INC $25           ; selected menu: "Relics"
  RTS

RelicSwap:
  LDA $09           ; buttons pressed
  BIT #$40          ; pressing Y
  BEQ .skip         ; branch if not ^
  JSR $0EB2         ; play click sound
  JSR $1E5F         ; check for equip permissions
  BCS .skip         ; branch if cannot equip
  JSR $9EEB         ; try auto-switch to equip menu
  LDA $99           ; was it triggered
  BNE .skip         ; branch if ^
  LDA #$35          ; "Initialize Equip Menu"
  STA $26           ; set ^
  STZ $27           ; zero queued command
  DEC $25           ; selected menu: "Equip"
.skip
  JMP $9EE6         ; memorize menu mode

EquipSubSwap:
  BIT #$40          ; pressing Y
  BNE ToRelics      ; branch if ^
  LDA $26           ; menu mode
  CLC : ADC #$29    ; "Swap Actor in Equip Menu" (retain Equip or Remove mode)
  BRA HandleLR      ; branch
warnpc $C3F570+1

org $C3F723
C3_BlindJump:
  STZ $11A9         ; omit special effect (if any)
  LDA $3EE4,x       ; status byte 1
  LSR               ; C: "Blind"
  LDA #$20          ; "Cannot Miss"
  BCS .blind        ; branch if "Blind"
  STA $11A4         ; set "Cannot Miss"
  BRA .exit         ; branch to exit
.blind
  STZ $11A4         ; clear "Cannot Miss" [TODO: Why?]
.exit
  RTL
warnpc $C3F737+1

