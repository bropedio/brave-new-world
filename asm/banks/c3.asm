hirom
table vwf.tbl,rtl

; C3 Bank

; #########################################################################
; Variable definitions for reuse

!_ellipsis = #$C7

; #########################################################################
; Initialize Magic Menu

org $C32125 : NOP #3 ; skip drawing MP Cost in Magic Menu

; #########################################################################
; Initialize Rage Menu
;
; Modified by dn's patch to handle BNW's reduced rage set (64)

org $C321AD : LDA #$03f0 ; fix arrow (scrollbar speed)
org $C321C3 : LDA #$18   ; set scroll limit (8 onscreen + 24 scroll * 2 = 64)

; #########################################################################
; Sustain Config Menu
;
; Modified by dn's "Battle Speed Remove" patch, to adjust "Controller"
; option index.

org $C322D0 : CMP #$07     ; "Controller" option ID (was 8 in vanilla)

; #########################################################################
; Game Options Pressing A Handlers
;
; Modified by dn's "Remove Battle Speed" patch.

org $C3234A
OptionPressA:
  dw .rts     ; Bat.Mode
  dw .rts     ; Msg.Speed
  dw $2368    ; Cmd.Set
  dw .rts     ; Gauge
  dw .rts     ; Sound
  dw .rts     ; Cursor
  dw .rts     ; Reequip
  dw $2379    ; Controller
  dw .rts     ; [unused]
org $C3235C
  dw .rts     ; Mag.Order
  dw .rts     ; Window
  dw $2388    ; Color
  dw $2388    ; R
  dw $2388    ; G
  dw $2388    ; B
org $C32341
.rts

; #########################################################################
; Sustain Magic Menu

org $c32806 : NOP #3 ; skip drawing MP cost

; #########################################################################
; Return to Magic Menu

org $C32D56 : NOP #3 ; skip drawing MP cost

; #########################################################################
; Config Menu Initialize

org $C33867
ConfigMenuNav:
  db $81      ; never wraps
  db $00      ; initial column
  db $00      ; initial row
  db $01      ; 1 column
  db $08      ; 8 rows (from 9)

org $C3386C
ConfigCursorPositions:
  dw $3560    ; Exp Mode
  dw $4960    ; Msg.Speed
  dw $5960    ; Cmd.Set
  dw $6960    ; Gauge
  dw $7960    ; Sound
  dw $8960    ; Cursor
  dw $9960    ; Reequip
  dw $A960    ; Controller

org $C338C9
DrawConfigMenu:
  LDA #$2C      ; "Blue" palette
  STA $29       ; set ^
  LDY #BNWText  ; "BNW" title text data offset

org $C339E6
ConfigMenuWindowLayout:
  dw $588D     ; title window position on screen
  db $1A       ; title window width+1(left)+1(right)
  db $02       ; title window height+1(top)+1(bottom)

org $C33A40 : LDA #$07     ; "Controller" config option ID (was 8 in vanilla)

; Old "Battle Speed" drawing routine [now freespace]
org $C33BB7
  RTS           ; automatically return from battle speed jump
BNWText:   dw $78CF : db "   ",$81,"rave New World 2.1b18 ",$00 ; Issue w/ "B" char
BattleTxt: dw $3A4F : db $81,"attle","$00
warnpc $C33BF2+1
padbyte $FF
pad $C33BF2

; #########################################################################
; Game Options Update Handlers
;
; Modified by dn's "Remove Battle Speed" patch.

org $C33D43
OptionJumpPage1:
  dw $3D61     ; Bat.Mode
  dw $3DAB     ; Msg.Speed
  dw $3DE8     ; Cmd.Set
  dw $3E01     ; Gauge
  dw $3E1A     ; Sound
  dw $3E4E     ; Cursor
  dw $3E6D     ; Reequip
  dw $3E86     ; Controller
  dw $FFFF     ; [unused]

org $C33D55
OptionJumpPage2:
  dw $3E9F     ; Mag.Order
  dw $3ECD     ; Window
  dw $3F01     ; Viewed color
  dw $3F3C     ; R
  dw $3F5B     ; G
  dw $3F7A     ; B

;org $C33D7A
;padbyte $FF    ; remove "Battle Speed" handler code
;pad $C33DAB

; #########################################################################
; Positioned Text for Config Menu (page 1)
;
; Much of this code is unchanged from vanilla, but included here for context.
; Modified by dn's "Remove Battle Speed" patch. The following was commented
; out:
;   org $c349f2
;   dw $39e5
;   db "Off",$00
;    The above is handled by necessity in dash.asm

org $C34903
ConfigTxt1: dw ControllerTxt
ConfigTxt2: dw CursorTxt
ConfigTxt3: dw FastTxt
ConfigTxt4: dw SlowTxt

ControllerTxt: dw $3D8F : db "Controller",$00
OnTxt2:        dw $39F5 : db "On",$00
                          db $AD,$00          ; fill empty space from "Wait"
FastTxt:       dw $3A65 : db "Fast",$00
SlowTxt:       dw $3A75 : db "Slow",$00
ShortTxt:      dw $3B35 : db "Short",$00
OnTxt:         dw $3BA5 : db "On",$00
OffTxt:        dw $3BB5 : db "Off",$00
StereoTxt:     dw $3C25 : db "Stereo",$00
MonoTxt:       dw $3C35 : db "Mono",$00
MemoryTxt:     dw $3CB5 : db "Memory",$00
OptimumTxt:    dw $3D25 : db "Optimum",$00
MultipleTxt:   dw $3DB5 : db "Multiple",$00
Scale1Txt:     dw $3A25 : db "1 2 3 4 5 6",$00
Scale2Txt:     dw $3AA5 : db "1 2 3 4 5 6",$00
CursorTxt:     dw $3C8F : db "Cursor",$00
warnpc $C34993+1

org $C34993
ConfigTxt5: dw ExpGainTxt
ConfigTxt6: dw BattleTxt
ConfigTxt7: dw MsgSpeedTxt
ConfigTxt8: dw CmdSetTxt
ConfigTxt9: dw GaugeTxt
ConfigTxtA: dw SoundTxt
ConfigTxtB: dw DashTxt

ConfigTitleTxt: dw $78F9 : db "Config",$00 ; TODO: No longer used
ExpGainTxt:     dw $39CF : db "Exp.Gain",$00
BatSpeedTxt:    dw $3A0F : db "Bat.Speed",$00
MsgSpeedTxt:    dw $3A8F : db "Msg.Speed",$00
CmdSetTxt:      dw $3B0F : db "Cmd.Set",$00
GaugeTxt:       dw $3B8F : db "Gauge",$00
SoundTxt:       dw $3C0F : db "Sound",$00
DashTxt:        dw $3D0F : db "Reequip",$00
ActiveTxt:      dw $39A5 : db "Active",$00
WindowTxt:      dw $3B25 : db "Window",$00
ResetTxt:       dw $3CA5 : db "Reset",$00
EmptyTxt:       dw $3D35 : db "Empty",$00
SingleTxt:      dw $3DA5 : db "Single",$00

; #########################################################################
; Magic Menu Cursor Positions

org $C34BAE
MagicMenuCursorPositions:
  dw $7408    ; Spell 1
  dw $7478    ; Spell 2
  dw $8008    ; Spell 3
  dw $8078    ; Spell 4
  dw $8C08    ; Spell 5
  dw $8C78    ; Spell 6
  dw $9808    ; Spell 7
  dw $9878    ; Spell 8
  dw $A408    ; Spell 9
  dw $A478    ; Spell 10
  dw $B008    ; Spell 11
  dw $B078    ; Spell 12
  dw $BC08    ; Spell 13
  dw $BC78    ; Spell 14
  dw $C808    ; Spell 15
  dw $C878    ; Spell 16

; #########################################################################
; Draw Skills Menu

org $C34C80 : JSR FlipMPDisplay : NOP #2 ; default MP display to "on"
org $C34CC0 : NOP #6 ; skip drawing "title box" window

; #########################################################################
; Draw Magic Menu

org $C34D8C : NOP #6 ; skip drawing "MP" label
org $C34FAC : LDX #$0011 ; increase space between spell list columns (was $10)

; #########################################################################
; Draw Magic Menu Spell

org $c35005
DrawSpellAndCost:
  LDA !_ellipsis     ; ellipsis character
  STA $2180          ; add to string
  LDA #$FF           ; space character
  STA $2180          ; add to string
  LDA $F8            ; tens digit
  STA $2180          ; add to string
  JMP EndDrawMP      ; finish old [moved] code
  db $FF,$FF,$FF     ; [fill unused]
warnpc $C3501A+1

org $C35027 : LDY #$000C ; allow for spell name length 12 (was 11)

org $c35082
  LDA #$FF           ; space character
  JMP EndDrawPercent ; finish drawing percentage learned
  db $FF             ; [fill unused]

; #########################################################################
; Draw MP Cost in Magic Menu
; No longer in use, can be used as freespace

org $C351C6
warnpc $C351F9+1

; #########################################################################
; Draw Lore Menu

org $C35203 : NOP #6 ; skip drawing "Lore" title

; #########################################################################
; Draw Bushido Menu

org $C352E8 : NOP #6 ; skip drawing "Bushido" title

; #########################################################################
; Draw Rage Menu

org $C3539B : NOP #6 ; skip drawing "Rage" title

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
; Draw Esper Menu

org $C35460 : NOP #6 ; skip drawing "Esper" title

; #########################################################################
; Draw Blitz Menu

org $C355DE : NOP #6 ; skip drawing "Blitz" title

; #########################################################################
; Draw Blitz Inputs
;
; Jump added by dn's "Blitz Menu" patch, to draw Blitz names as well

org $C3565D : JSR BlitzNames

; #########################################################################
; Draw Dance Menu

org $C3577E : NOP #6 ; skip drawing "Dance" title

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
; Equip Menu Tabs Navigation
;
; Modified by dn's "Equip Fix" hack to reduce columns from 4 to 3 and
; remove "Optimum" cursor position

org $C38E5F
EquipMenuTabsNavigation:
  db $01          ; wraps horizontally
  db $00          ; initial column
  db $00          ; initial row
  db $03          ; 3 columns
  db $01          ; 1 row

org $C38E64
  dw $1018        ; "EQUIP" cursor position
  dw $1058        ; "REMOVE" cursor position
  dw $10A0        ; "RMOVE" cursor position
  dw $FFFF        ; [now unused]

; #########################################################################
; Relic Menu Navigation Data

org $C38ED1
  dw $1028  ; "EQUIP" cursor position
  dw $1088  ; "REMOVE" cursor position

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
; Draw Equip Menu
;
; Reduce options loop from 4 to 3, now that "Optimize" is removed. (dn)

org $C39055 : LDY #$0006 ; 3 loops 

; #########################################################################
; Sustain Relic and Sustain Equip Menus
;
; Modifictions to button press handlers to handle Y button presses to
; swap between relic and equip menus. Part of dn's "Y Screen Swap" patch
; Modify jump table pointers for Equip menu option

org $C39648 : JMP EquipSwap : NOP #4

org $C3966C
EquipOptionJumpTable:
  dw $9674     ; "Equip" option
  dw $968E     ; "Remove" option
  dw $969F     ; "Empty" option
  dw $969F     ; [NOTE: Unused]

org $C398C8 : JMP EquipSubSwap : NOP #4
org $C39908 : JMP EquipSubSwap : NOP #4

org $C39EDC : JSR RelicSwap
org $C3A047 : JSR RelicSwap
org $C3A146 : JSR RelicSwap

; #########################################################################
; Equip and Relic Menu Text Data

org $C3A2A6
  dw EquipTxt
  dw RemoveTxt
  dw EmptyTxt2
  dw $A334     ; [NOTE: Unused, Unchanged]
warnpc $C3A2AE+1

org $C3A31A
EquipTxt:
  dw $7913 : db "EQUIP",$00
RemoveTxt:
  dw $7923 : db "REMOVE",$00
EmptyTxt2:
  dw $7935 : db "EMPTY",$00
org $C3A33C
EquipTxt2:
  dw $7917 : db "EQUIP",$00
RemoveTxt2:
  dw $792F : db "REMOVE",$00
warnpc $C3A34D+1

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

org $C3F700
FlipMPDisplay:
  LDA #$FF       ; MP display = on
  STA $9E        ; store it
  JSR $0F89      ; stop VRAM DMA B
  RTS

EndDrawMP:
  LDA $F9        ; ones digit
  STA $2180      ; add to string
  LDA #$FF       ; space character
  STA $2180      ; add to string
  STZ $2180      ; end string
  JMP $7FD9      ; draw string

EndDrawPercent:
  STA $2180      ; add to string
  STZ $2180      ; end string
  JMP $7FD9      ; draw string
warnpc $C3F721+1

; TODO: Dunno why we've left 2 unused bytes in between here

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

