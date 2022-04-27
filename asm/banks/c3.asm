hirom
table vwf.tbl,rtl

; C3 Bank

; #########################################################################
; Variable definitions for reuse

!_ellipsis = #$C7

; #########################################################################
; Draw Character HP/MP/LV Values

org $C30C81 : JSR Esp_Lvl ; Also draw EL value

; #########################################################################
; Animation Queue

; Remove infinite loop that existed for some reason (TODO: Test this)
; Change included in "Esper Changes" hack for EP/EL/Spell Bank features
org $C311AD : NOP #2

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
; Character Display

; Change position of LV to make room for EL
; If espers have been acquired, write EL label after LV label
org $C33303 : JSR EL_Main_1 ; Main menu, character 1
org $C3332D : dw $39A5
org $C3334F : JSR EL_Main_2 ; Main menu, character 2
org $C33379 : dw $3B25
org $C3339B : JSR EL_Main_3 ; Main menu, character 3
org $C333C5 : dw $3CA5
org $C333E7 : JSR EL_Main_4 ; Main menu, character 4
org $C33411 : dw $3E25


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

org $C33BA7 : LDY #OffTxt2

; Old "Battle Speed" drawing routine [now freespace]
org $C33BB7
  RTS           ; automatically return from battle speed jump
BNWText:   dw $78CF : db "   ",$81,"rave New World 2.1b18 ",$00 ; Issue w/ "B" char
BattleTxt: dw $3A4F : db $81,"attle","$00
warnpc $C33BF2+1
padbyte $FF
pad $C33BF2

org $C33C55 : LDY #WindowTxt
org $C33CCB : LDY #ResetTxt
org $C33CFF : LDY #WalkTxt

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
DashTxt2:      dw $3D25 : db "Dash",$00,$00,$00,$00
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
DashTxt:        dw $3D0F : db "B Button",$00
OffTxt2:        dw $39E5 : db "Off",$00,$00,$00,$00
WindowTxt:      dw $3B25 : db "Window",$00
ResetTxt:       dw $3CA5 : db "Reset",$00
WalkTxt:        dw $3D35 : db "Walk",$00
SingleTxt:      dw $3DA5 : db "Single",$00
warnpc $C34A1C+1

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
; Draw Skills Menu(s)

org $C34C80 : JSR FlipMPDisplay : NOP #2 ; default MP display to "on"
org $C34CC0 : NOP #6 ; skip drawing "title box" window
org $C34D8C : NOP #6 ; skip drawing "MP" label
org $C34EEA : JSR EL_Skill  ; draw EL in skills display
org $C34F12 : db $35,$42 ; make room for EL display
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
; Sustain Esper Data Menu

org $C358DB : JMP Pressed_A : NOP ; support Spell Bank and EL Bonus selection

; #########################################################################
; Draw Selected Esper Data Info

org $C3599D : dw $B810  ; Reposition EL bonus cursor
org $C359AC : JSR Blue_Bank_Txt
org $C359CF : JSR DrawEsperMP ; end of drawing esper name
org $C35A3B : JSR Unspent_EL ; add unspent EL draw to esper bonus draw
org $C35A4C : db $0B    ; Remove 2 spaces between label and bonus
org $C35A84 : JMP $7FD9 ; skip drawing spell progress

; Re-formats the esper screen to properly display SP cost
org $C35AFF
  LDA #$FF          ; " "
  STA $2180         ; write ^
  STA $2180         ; write ^
  JSR Learn_Chk
SPCost:
  JSR $04E0         ; turn SP cost (A) into displayable digits
  LDA $F8           ; tens digit
  STA $2180         ; write ^
  LDA $F9           ; ones digit
  STA $2180         ; write ^
  LDA #$FF          ; " "
  STA $2180         ; write ^
  LDA #$92          ; "S"
  STA $2180         ; write ^
  JMP FinishSP      ; jump to second part of routine

org $C35B26 : JSR No_Spell_In_Slot

; #########################################################################
; Positioned Text for Skills Menu (and Submenus)

org $C35C59 : dw $7A8D : db "Bushido",$00 ; rename "Swdtech"
org $C35CB8 : dw $81B7 : db "Bushido",$00 ; rename "Swdtech"
org $C35CE2
  SPLabel:    dw $47B1 : db "SP ",$00
  LearnLabel: dw $4437 : db "Learn",$00
  SPMax:      dw $47BB : db "/30",$00

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
; Draw Status Screen

; Modify the status screen to display EP and esper level to the player
; Change total exp display to exp to next level
org $C36068
  JSR $60A0         ; get experience needed to level
  JSR $0582         ; convert to digit tiles
  LDX #$7CD7        ; tilemap position
  JSR $04A3         ; write experience needed to status screen
  JSR EL_Status     ; draw "Total EP" label
  JSR Calc_EP_Status ; $F1: needed ep, Carry: show ep
  BCC .done         ; branch if hiding EP numbers
  JSR $0582         ; convert $F1 into text digits
  LDX #$7DD7        ; tilemap position for EP number
  JSR $04A3         ; draw EP needed
.done
  STZ $47           ; [displaced] turn ailments off
  JSR $11B0         ; [displaced] hide ailment icons
  JMP $625B         ; [displaced] display status

; #########################################################################
; Status Screen Commands
; 
; Rewritten as part of Assassin's "Brushless Sketch" patch to make room
; for a helper function. This new helper exposes $C36172 (command upgrades)
; to the C2 menu command routine(s).

org $C36096 : db $25,$3A ; make room for EL in Character display

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
org $C36511 : dw $7C4D : db "Exp to lv. up:",$00 ; status menu exp text

; #########################################################################
; Character Lineup
org $C3797D : JSR EL_Party  ; draw EL after LV in party select screen
org $C379E6 : dw $3A75      ; shift LV label to make room for EL display

; #########################################################################
; [fork] Draw Offensive Properties
; Rewritten to always draw "Runic", "2-Hand", "Bushido" but grayed out

org $C38743 : RTS ; skip drawing "Spell Taught" in gear details

org $C38746
OffensiveProps:
  JSR $879C           ; draw Bat.Pwr
  JSR OffensiveHelp   ; draw evasions, attack label, elements
  JSR ItemProperties  ; get item properties
  AND #$80            ; "Allows Runic"
  JSR UpdateTxtColor  ; set palette to grey or white, depending on ^
  LDY #$8E30          ; "Runic" text data address
  JSR DrawTextData    ; draw ^
  JSR ItemProperties  ; get item properties
  AND #$40            ; "Allows 2-Hand"
  JSR UpdateTxtColor  ; set palette to grey or white, depending on ^
  LDY #$8E38          ; "2-Hand" text data address
  JSR DrawTextData    ; draw ^
  JSR ItemProperties  ; get item properties
  AND #$02            ; "Allows Bushido"
  JSR UpdateTxtColor  ; set palette to grey or white, depending on ^
  LDY #$8E26          ; "Bushido" text data address
  JSR DrawTextData    ; draw ^
  RTS
padbyte $FF : pad $C38795

; dn's "Shop Hack" patch changes where to write elemental effects
org $C388CE : LDX #$7B65 ; where to write resisted elements
org $C388DA : LDX #$7BE5 ; where to write absorbed elements
org $C388E6 : LDX #$7C65 ; where to write immune elements
org $C388F2 : LDX #$7CE5 ; where to write weak elements

; dn's "Shop Hack" patch: Text pointers for gear data menu (point to new text)
org $C38D69
  dw EleResist
  dw EleAbsorb
  dw EleImmune
  dw EleWeak

; #########################################################################
; Menu Label Changes (part 1.5)
;
; Percent symbols (%) overwritten with spaces by dn's "No Percents" patch

org $C38D9B : db $FF ; replace '%' with ' '
org $C38DA5 : db $FF ; replace '%' with ' '
org $C38E26 : dw $822F : db "Bushido",$00 ; rename "SwdTech" gear attribute

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
; Sustain Main Shop Menu

; Modifies "buy item" list handling to update full details ("Shop Hack")
org $C3B4BD
  JSR BuyItemDetails
  RTS
DrawItemNameNMI:
  JSR $1368        ; refresh screen (NMI)
  JSR $7FD9        ; draw item name
  RTS
padbyte $FF : pad $C3B4E6

; #########################################################################
; Initialize Main Shop Menu
;
; "Shop Hack" - Insert hooks to draw gear details windows and labels and
; handle hiding the details until required.

org $C3B8C4
  JSR ShopClearBG  ; clear BG maps and draw detail windows
  NOP #6

org $C3B95A
; TODO Don't know why this is rewritten to free up 6 (unused) bytes
  JSR ClearBG3     ; clear background 3 maps
  JSR $BFD3        ; Draw title
  LDY #$C338       ; Text pointer
  JSR $02F9        ; Draw "GP"
  JSR $C2F2        ; Color: User's
  LDY $1860        ; Gold LBs
  STY $F1          ; Memorize it
  LDA $1862        ; Gold HB
  STA $F3          ; Memorize it
  JSR $0582        ; Turn into text
  LDX #$7A33       ; Text position
  JSR $04AC        ; Draw GP total
  RTS
warnpc $C3B986+1

org $C3B989 : LDY #HelpText
org $C3C037 : db $2F,$06,$00      ; change text shifting for shop "Shop Hack"
org $C3BABA : NOP #3 ; skip drawing "Power" info on buy order menu
org $C3BAC9 : JSR DrawItemNameNMI ; refresh screen before name draw

; #########################################################################
; Shop Menu equippability UI

org $C3C29C : BRA $3F ; Never show equipped/up/down/equal icons

; #########################################################################
; Draw "Owned" and "Equippped" window
;
; dn's "Shop Hack" interrupts drawing "Owned and "Equipped" window

org $C3C2E1 : JSR DrawDetailsLabels

; #########################################################################
; Freespace Helpers

; Label only for ease of use for "Esper Changes" hack. Can be removed once
; "restrict_espers.asm" is integrated.
org $C3F097 : ChkEsp:

; EL/EP/Spell bank text data and helpers
; Many new label and text positions and tiles
org $C3F277
EPUpTxt:
  dw $7D4D : db "EP to lv. up:",$00
EPUpClr:
  dw $7D4D : db "             ",$00 ; 13 blanks for Gogo+
EPClear:
  dw $7DDD : db "     ",$00         ;  5 blanks for Gogo+ EP

; TODO: Lots of duplicated code here
; Many "EL" text positions, plus extra $FF buffer for indexing purposes
  dw $39AB : db "EL",$00,$FF,$FF,$FF
  dw $3B2B : db "EL",$00,$FF,$FF,$FF
  dw $3CAB : db "EL",$00,$FF,$FF,$FF
  dw $3E2B : db "EL",$00,$FF,$FF,$FF
  dw $423B : db "EL",$00,$FF,$FF,$FF
  dw $3A2B : db "EL",$00,$FF,$FF,$FF
  dw $3A7B : db "EL",$00,$FF,$FF,$FF

; TODO: Lots of duplicated code here
; Many "EL" text positions, but with spaces instead, to overwrite
  dw $39AB : db "     ",$00
  dw $3B2B : db "     ",$00
  dw $3CAB : db "     ",$00
  dw $3E2B : db "     ",$00
  dw $423B : db "     ",$00
  dw $3A2B : db "     ",$00
  dw $3A7B : db "     ",$00
UnspentTxt:
  db "Unspent EL:",$00

Calc_EP_Status:
  LDA $1E8A         ; event byte
  AND #$08          ; "met Ramuh"
  BEQ .no_ep        ; branch if not ^
  LDX $67           ; character data offset
  LDA $0000,X       ; character ID
  CMP #$0C          ; Gogo or above
  BCC .yes_ep       ; branch if not ^
.no_ep
  LDY #EPClear      ; pointer for spaces to blank out EP value
  JSR $02F9         ; draw ^
  LDY #EPUpClr      ; pointer for spaces to blank out "EP to lv. up"
  JSR $02F9         ; draw ^
  CLC               ; clear carry (hide EP needed)
  RTS
.yes_ep
  PHA               ; store character ID
  LDA #$2C          ; color: gray-blue
  STA $29           ; set text palette
  LDY #EPUpTxt      ; pointer for "EP to lv. up" text display
  JSR $02F9         ; draw ^
  TDC               ; zero A/B
  LDA #$20          ; color: white
  STA $29           ; set text palette
  PLA               ; restore character ID
  TAY               ; index it
  LDA !EL,Y         ; character's esper level
  CMP #$19          ; at max (25)
  BNE .needed_ep    ; branch if not ^
  SEC               ; set carry (show EP needed)
  JMP $60C3         ; display zero and exit
.needed_ep
  ASL               ; EL x2
  TAX               ; index to EP lookup
  TYA               ; character ID
  ASL               ; x2
  TAY               ; index it
  REP #$30          ; 16-bit A, X/Y
  LDA !EP,Y         ; character's total EP
  STA $F1           ; store ^
  LDA EP_Chart,X    ; EP needed for next level
  SEC               ; set carry
  SBC $F1           ; EP needed - total EP
  STA $F1           ; store ^
  SEP #$20          ; 8-bit A
  SEC               ; set carry (show EP needed)
  RTS

Esp_Lvl:
  JSR $04B6         ; [displaced] draw two digits
  JSR Ramuh_Chk     ; check if optained espers yet
  BEQ .exit         ; exit if not ^
  JSR Char_Chk      ; check if Gogo or above
  BCS .exit         ; exit if ^
  TAY               ; index character ID
  LDA !EL,Y         ; character's esper level
  JSR $04E0         ; turn into digit tiles
  REP #$20          ; 16-bit A
  LDA [$EF]         ; tilemap position for level display
  CLC               ; clear carry
  ADC #$000C        ; move X position for esper level display
  TAX               ; index it
  SEP #$20          ; 8-bit A
  JMP $04B6         ; write esper level to screen
.exit
  RTS

Ramuh_Chk:
  TDC               ; zero A/B
  LDA $1E8A         ; event byte
  AND #$08          ; "met Ramuh"
  RTS

Char_Chk:
  LDX $67           ; character data offset
  TDC               ; zero A/B
  LDA $0000,X       ; character ID
  CMP #$0C          ; carry: Gogo or higher
  RTS

EL_Main_1:
  LDA #$00          ; slot 1 offset for "EL" label in main menu
  PHA               ; store ^
  BRA Write_Text    ; draw "EL" label

EL_Main_2:
  LDA #$08          ; slot 2 offset for "EL" label in main menu
  PHA               ; store ^
  BRA Write_Text    ; draw "EL" label

EL_Main_3:
  LDA #$10          ; slot 3 offset for "EL" label in main menu
  PHA               ; store ^
  BRA Write_Text    ; draw "EL" label

EL_Main_4:
  LDA #$18          ; slot 4 offset for "EL" label in main menu
  PHA               ; store ^
  BRA Write_Text    ; draw "EL" label

EL_Skill:
  LDA #$24          ; color: blue
  STA $29           ; set text palette
  LDA #$20          ; offset for "EL" label in skills menu
  PHA               ; store ^
  BRA Stat_Skill_Ent ; draw "EL" label

EL_Status:
  LDA #$24          ; color: blue
  STA $29           ; set text palette
  LDA #$28          ; offset for "EL" label in status menu
  PHA               ; store ^
  BRA Stat_Skill_Ent ; draw "EL" label

EL_Party:
  LDA #$30          ; offset for EL label in party lineup menu
  PHA               ; store ^
Write_Text:
  JSR $69BA         ; [displaced] draw multiple strings

Stat_Skill_Ent:
  JSR Ramuh_Chk     ; obtained espers
  BEQ No_Ramuh      ; branch if not ^
  JSR Char_Chk      ; Gogo check
  PLA               ; restore text offset
  PHP               ; store flags
  REP #$20          ; 16-bit A
  BCS Gogo          ; branch if Gogo or higher
  ADC #$F29F        ; else, add "EL" text location
  BRA Write_EL      ; branch to write ^

No_Ramuh:
  PLA               ; restore text offset
  PHP               ; store flags
  REP #$20          ; 16-bit A

Gogo:
  CLC               ; clear carry
  ADC #$F2D7        ; add black spaces text location

Write_EL:
  TAY               ; index text source
  PLP               ; restore flags
  JMP $02F9         ; draw source text

; Adds "Unspent EL" display under the esper bonuses
Unspent_EL:
  LDA #$24          ; color: blue
  STA $29           ; set text palette
  LDY #$4791        ; tilemap position to write to
  JSR $3519         ; initialize WRAM buffer with ^
  LDX $00           ; zero X
.write_uel
  LDA UnspentTxt,X  ; get "Unspent EL:" tile
  BEQ .finish       ; break if EOL
  STA $2180         ; else, write to WRAM
  INX               ; next tile index
  BRA .write_uel    ; loop till EOL ($00)
.finish
  STZ $2180         ; write EOL
  JSR $7FD9         ; draw string from WRAM buffer
  LDA #$20          ; color: white
  STA $29           ; set palette
  JSR Char_Chk      ; current character's ID
  TAY               ; index it
  LDA !EL_bank,Y    ; available ELs for character to spend
  JSR $04E0         ; turn into digit tiles
  LDY #$47A9        ; tilemap position to write to
  JSR $3519         ; initialize WRAM buffer with ^
  LDA $F8           ; tens digit of ELs
  STA $2180         ; write ^
  LDA $F9           ; ones digit of ELs
  STA $2180         ; write ^
  STZ $2180         ; write EOL
  JSR $7FD9         ; draw string from WRAM buffer
  LDY #$470F        ; next tilemap position (shifted left 2 spaces)
  RTS

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

; TODO: Another two unused bytes here

; EL, EP, Spell Bank Helpers (Synchysi)
org $C3F739
Blue_Bank_Txt:
  LDA #$24          ; color: blue
  STA $29           ; set text palette ^
  JSR $02F9         ; display "SP" in blue text
  LDA #$20          ; color: white
  STA $29           ; set text palette ^
  LDX $67           ; character data offset
  TDC               ; zero A/B
  LDA $0000,X       ; character ID
  TAY               ; index it
  LDA !spell_bank,Y ; character's banked SP
  JSR $04E0         ; convert to displayable digits
  LDX #$47B7        ; where to display
  JMP NewLabels     ; Output banked SP and other new static labels

Finish_Esper_Txt:   ; TODO: Label unused
  LDA #$8F          ; "P"
  STA $2180         ; add ^ to WRAM
  LDA #$FF          ; " "
  STA $2180         ; add ^ to WRAM
  STA $2180         ; add ^ to WRAM
  STA $2180         ; add ^ to WRAM
  LDA $AA           ; spell learned
  LSR               ; C: learned
  BCC .unknown      ; branch if not ^
  LDA #$CF          ; "checkmark"
  BRA .finish       ; draw ^ and finish
.unknown
  LDA #$FF          ; " "
.finish
  STA $2180         ; add ^ to WRAM
  STZ $2180         ; add EOL to WRAM
  JMP $7FD9         ; finish drawing spell row

Learn_Chk:
  STZ $AA           ; zero "learned" flag
  LDA $E0           ; SP cost of the spell
  PHA               ; preserve it, because C3/50A2 mutilates $E0
  JSR Chk_Esper_Eq  ; check if the current esper can be equipped
  LDA $29           ; text color palette
  CMP #$28          ; grey (disabled)
  BEQ .set_color    ; branch if ^
  LDA $E1           ; spell ID
  JSR $50A2         ; get mastery percent
  BEQ .unknown      ; branch if zero ^
  INC $AA           ; else, set flag for later
.unknown
  LDA #$20          ; color: white
.set_color
  STA $29           ; update text palette
  PLA               ; restore SP cost of the spell
  RTS

Pressed_A:
  LDA $4B           ; pointer index
  BNE .spell        ; branch if pointing at a spell
  JMP $C358DF       ; vanilla "can equip esper" fork
.spell
  LDA $99           ; load esper ID
  STA $4202         ; set multiplier
  JSR ChkEsp        ; check esper restriction
  TDC               ; zero A/B
  LDA $29           ; text palette
  CMP #$28          ; color: gray (disabled)
  BEQ .nope         ; branch if ^
  LDA #$0B          ; size of esper data block (11)
  STA $4203         ; set multiplicand
  LDA $4B           ; pointer index
  CMP #$06          ; "esper bonus" index
  BEQ Apply_Bonus   ; branch if ^
  DEC               ; else, decrement index
  ASL               ; and *2
  CLC               ; clear carry
  REP #$20          ; 16-bit A
  ADC $4216         ; add spell offset to esper data offset
  STA $A5           ; store ^
  TAX               ; index it
  SEP #$20          ; 8-bit A
  LDA $D86E01,X     ; spell ID the pointer is currently on
  STA $E0           ; store ^
  CMP #$FF          ; null?
  BEQ Exiter        ; branch if ^
  JSR $50A2         ; check spell mastery
  BNE .nope         ; exit if already learned
  LDX $A5           ; restore spell offset
  TDC               ; zero A/B
  LDA $D86E00,X     ; SP cost of the spell
  STA $A4           ; store ^
  LDX $67           ; character data offset
  LDA $0000,X       ; character ID
  TAX               ; index it
  STA $4202         ; set multiplier
  LDA !spell_bank,X ; character's banked SP
  SEC               ; set carry
  SBC $A4           ; subtract spell SP cost
  BCC .nope         ; exit if not enough SP
  STA !spell_bank,X ; else, reduce banked SP
  LDA #$36          ; size of character spell lists (54)
  STA $4203         ; set multiplicand
  JSR $0ECE         ; sound: "cha-ching"
  TDC               ; zero A/B
  LDA $E0           ; spell ID
  REP #$20          ; 16-bit A
  CLC               ; clear carry
  ADC $4216         ; add spell index to character spell list offset
  TAX               ; index it
  SEP #$20          ; 8-bit A
  LDA #$FF          ; "learned"
  STA $1A6E,X       ; set spell learned
  JMP $5913         ; jump to vanilla "press B" esper menu fork
.nope
BzztPlayer:
  JMP $0EC0         ; sound: Bzzt

Chk_Esper_Eq:
  STA $4203         ; save SP cost of spell [TODO: Why?]
  LDA $99           ; esper ID
  JSR ChkEsp        ; check esper restriction
  LDA $29           ; text color palette
  CMP #$2C          ; color: gray-blue (equipped)
  BNE .exit         ; exit if not ^
  LDA #$20          ; color: white (equippable)
.exit
Exiter:
  RTS

No_Spell_In_Slot:
  LDX #$B492        ; tilemap position [?]
  STX $2181         ; set WRAM destination
  LDA #$FF          ; " " space
  STA $2180         ; write ^
  STZ $2180         ; write EOL
  JMP $7FD9         ; draw esper name

Apply_Bonus:        ; F834
  LDX $67           ; character data offset
  LDA $0000,X       ; character ID
  TAX               ; index it
  LDA !EL_bank,X    ; unspent esper levels
  BEQ BzztPlayer    ; branch if none ^
  DEC !EL_bank,X    ; else, decrement unspent ELs
  JSL Do_Esper_Lvl  ; and apply esper boost
  JSR $0ECE         ; sound: "cha-ching"
  JSR $4EED         ; redraw HP/MP on the status screen
  JMP $5913         ; jump to vanilla "Press B" esper menu fork

org $C3F850
OffensiveHelp:
  JSR $87EB      ; [displaced] draw evasions
  JSR $C2F7      ; [optimized] set blue palette
  LDY #$8E1D     ; [displaced] text pointer
  JSR $02F9      ; [displaced] draw "Attack"
  JMP $88A0      ; [displaced] draw elements

UpdateTxtColor:
  BEQ .gray      ; branch to gray if property missing
  LDA #$20       ; "user's color" palette (white)
  BRA .done      ; set ^
.gray
  LDA #$24       ; grey text
.done
  STA $29        ; set palette ID
  RTS

ItemProperties:
  LDX $2134        ; item index
  LDA $D85013,x    ; byte to look at
  RTS

DrawTextData:
  STY $E7
  JSR $8795
  RTS

ShopClearBG:
  JSR $6A28        ; clear bg2 map a
  JSR $6A2D        ; clear bg2 map b
  JSR $6A32        ; clear bg2 map c
  JSR $6A37        ; clear bg2 map d
  LDY #GearWindow  ; offset to main gear window specs
  JSR $0341        ; draw window ^
  LDY #GearActors  ; offset to actor window specs
  JSR $0341        ; draw window ^
  LDY #GearNameBox ; offset to name window specs
  JSR $0341        ; draw window ^
  LDY #GearDesc    ; offset to desc window specs
  JSR $0341        ; draw window ^
ClearBG3:
  JSR $6A3C        ; clear bg3 map a
  JSR $6A41        ; clear bg3 map b
  JSR $6A46        ; clear bg3 map c
  JSR $6A4B        ; clear bg3 map d
  RTS

draw_title_dupe:
  JSR $02FF        ; draw title

BuyItemDetails:
  LDA #$10         ; reset/stop desc
  TSB $45          ; set menu flags
  JSR $0F39        ; queue text upload
  JSR $1368
  JSR $0F4D        ; queue text upload 2
  JSR $B8A6        ; handle d-pad
  JSR check_stats
  JSR $BC84        ; draw quantity owned
  JSR $BCA8        ; draw quantity worn
;Handle hold Y
shop_handle_y:
  LDA $0D
  BIT #$40         ; holding Y?
  BEQ .handle_b    ; branch if not
  REP #$20         ; 16-bit A
  LDA #$0100       ; BG2 scroll position
  STA $3B          ; BG2 Y position
  STA $3D          ; BG3 X position
  SEP #$20         ; 8-bit A
  LDA #$04         ; bit 2
  TRB $45          ; set bit in menu flags A
  JSR gear_desc
  RTS
;Fork: Handle B
.handle_b
  STZ $3C
  STZ $3E
  LDA #$04
  TSB $45
  LDA $09          ; No-autofire keys
  BIT #$80         ; Pushing B?
  BEQ .handle_a    ; Branch if not
  JSR $0EA9        ; Sound: Cursor
  JMP $B760        ; Exit submenu
;Fork: Handle A
.handle_a
  LDA $08          ; no-autofire keys
  BIT #$80         ; pushing (A)
  BEQ .exit        ; exit if not ^
  JSR $B82F        ; set buy limit
  JSR $B7E6        ; test GP, stock
.exit
  RTS

DrawDetailsLabels:
  JSR $1368        ; trigger NMI
  JSR $C2F7        ; [displaced] color: blue
  LDY #VigorText   ; text: vigor
  JSR $02F9        ; draw text
  LDY #MagicText   ; text: magic
  JSR $02F9        ; draw text
  LDY #StaminaText ; text: stamina
  JSR $02F9        ; draw text
  LDY #SpeedText   ; text: speed
  JSR $02F9        ; draw text
  LDY #DefText     ; text: defense
  JSR $02F9        ; draw text
  LDY #MDefText    ; text: magic defense
  JSR $02F9        ; draw text
  LDY #EvadeText   ; text: evasion
  JSR $02F9        ; draw text
  LDY #MEvadeText  ; text: magic evasion
  JSR $02F9        ; draw text
  LDY #PowerText   ; text: bat.pow.
  JSR $02F9        ; draw text
  JSR $BFC2        ; get item ID in A [TODO why]
  RTS

check_stats:
  PHA               ; store A
  PHX               ; store X
  PHY               ; store Y
  PHP               ; store flags
  JSR $C2F2         ; set palette to white
  JSR $BFC2         ; get item
  JSR $8321         ; Compute index
  LDX $2134         ; Load it
  TDC               ; Terminator
  STA $7E9E8D       ; Set mod B3
  STA $7E9E8E       ; Set mod B4
  REP #$20          ; 16-bit A
  LDA #$8223        ; Tilemap ptr
  STA $7E9E89       ; Set position
  SEP #$20          ; 8-bit A
  TDC               ; Clear A
  LDA $D85010,X     ; Stat mods LB
  PHA               ; Memorize them
  AND #$0F          ; Vigor index
  ASL A             ; Double it
  JSR $8836         ; Draw modifier
  REP #$20          ; 16-bit A
  LDA #$82a3        ; Tilemap ptr
  STA $7E9E89       ; Set position
  SEP #$20          ; 8-bit A
  TDC               ; Clear A
  PLA               ; Stat mods LB
  AND #$F0          ; Speed index
  LSR A             ; Put in b3-b6
  LSR A             ; Put in b2-b5
  LSR A             ; Put in b1-b4
  JSR $8836         ; Draw modifier
  REP #$20          ; 16-bit A
  LDA #$8241        ; Tilemap ptr
  STA $7E9E89       ; Set position
  SEP #$20          ; 8-bit A
  LDX $2134         ; Item index
  TDC               ; Clear A
  LDA $D85011,X     ; Stats mods HB
  PHA               ; Memorize them
  AND #$0F          ; Stamina index
  ASL A             ; Double it
  JSR $8836         ; Draw modifier
  REP #$20          ; 16-bit A
  LDA #$82c1        ; Tilemap ptr
  STA $7E9E89       ; Set position
  SEP #$20          ; 8-bit A
  TDC               ; Clear A
  PLA               ; Stat mods HB
  AND #$F0          ; Mag.Pwr index
  LSR A             ; Put in b3-b6
  LSR A             ; Put in b2-b5
  LSR A             ; Put in b1-b4
  JSR $8836         ; Draw modifier

;draw defensive properties
  LDX $2134         ; Item index
  LDA $D85000,X     ; Properties
  AND #$07          ; Get class
  BEQ not_weapon    ; branch if tool
  CMP #$01          ; Weapon?
  BEQ is_weapon     ; Branch if so
  CMP #$06          ; item?
  BEQ not_weapon    ; branch if so
  LDA $D85014,X     ; Defense
  JSR $04E0         ; Turn into text
  LDX #$83A1        ; Text position
  JSR $04C0         ; Draw 3 digits
  LDX $2134         ; Item index
  LDA $D85015,X     ; Mag.Def
  JSR $04E0         ; Turn into text
  LDX #$83BF        ; Text position
  JSR $04C0         ; Draw 3 digits
  LDY #PowerDash
  JSR $02f9
is_weapon:
  TDC
  LDX $2134        ; item index
  LDA $D85000,x    ; properties
  AND #$07
  CMP #$01
  BNE not_weapon
  LDA #$20       ; Palette 0
  STA $29        ; Color: User's
  CMP #$51       ; Dice?
  BEQ hide_bpow      ; Hide if so
  LDX $2134
  LDA $D85014,X  ; Bat.Pwr
  JSR $04E0      ; Turn into text
  LDX #$813F        ; Text position
  JSR $04C0      ; Draw 3 digits
  LDY #DefDash
  JSR $02F9
  LDY #MDefDash
  JSR $02F9
  BRA not_weapon

hide_bpow:
  LDY #UnknownTxt     ; Text pointer
  JSR $02F9      ; Draw "???"

not_weapon:
  JSR all_dashes
  REP #$20       ; 16-bit A
  LDA #$8321     ; Tilemap ptr
  STA $7E9E89    ; Set position
  SEP #$20       ; 8-bit A
  LDX $2134      ; Item index
  TDC            ; Clear A
  LDA $D8501A,X  ; Evasion mods
  PHA            ; Memorize them
  AND #$0F       ; Evade index
  ASL A          ; x2
  ASL A          ; x4
  JSR $881A      ; Draw modifier
  REP #$20       ; 16-bit A
  LDA #$833f     ; Tilemap ptr
  STA $7E9E89    ; Set position
  SEP #$20       ; 8-bit A
  LDX $2134      ; Item index
  TDC            ; Clear A
  PLA            ; Evasion mods
  AND #$F0       ; MBlock index
  LSR A          ;
  LSR A          ;
  TAX            ; Index it
  LDA $C38854,X  ; Sign
  STA $7E9E8B    ; Add to string
  LDA $C38855,X  ; Tens digit
  STA $7E9E8C    ; Add to string
  LDA $C38856,X  ; Ones digit
  STA $7E9E8D    ; Add to string
  JSR $8847      ; Draw modifier

; name and cleanup
  REP #$20
  LDA #$810D        ; tilemap ptr
  STA $7E9E89
  SEP #$20        
  JSR $BFC2        ; get item
  JSR $C068        ; load item name
  JSR $7FD9
  PLP
  PLY
  PLX
  PLA
  JSR $BC92
  RTS

all_dashes:
  LDX $2134
  LDA $D85000,x
  AND #$07
  CMP #$06
  BNE skip_all_dashes
  LDY #PowerDash
  JSR $02F9
  LDY #DefDash
  JSR $02F9
  LDY #MDefDash
  JSR $02F9
skip_all_dashes:
  RTS
gear_desc:
  LDA $02
  CMP $4B
  BNE gear_desc_end
  JSR gear_desc2    ; build description tilemap for shop menu
  JSR $B4E6        ; set description flags
  JSR $B4EF        ; load item description for buy menu
gear_desc_end:
  LDA $4B
  STA $02
  RTS

gear_desc2:
  LDX #$7849     ; Base: 7E/7849
  STX $EB        ; Set map ptr LBs
  LDA #$7E       ; Bank: 7E
  STA $ED        ; Set ptr HB
  LDY #$0CBC     ; Ends at 30,19
  STY $E7        ; Set row's limit
  LDY #$0C84     ; Starts at 3,19
  LDX #$3500     ; Tile 256, pal 5
  STX $E0        ; Priority enabled
  JSR $A783      ; Do line 1, row 1
  LDY #$0CFC     ; Ends at 30,20
  STY $E7        ; Set row's limit
  LDY #$0CC4     ; Starts at 3,20
  LDX #$3501     ; Tile 257, pal 5
  STX $E0        ; Priority enabled
  JSR $A783      ; Do line 1, row 2
  LDY #$0D3C     ; Ends at 30,21
  STY $E7        ; Set row's limit
  LDY #$0D04     ; Starts at 3,21
  LDX #$3538     ; Tile 312, pal 5
  STX $E0        ; Priority enabled
  JSR $A783      ; Do line 2, row 1
  LDY #$0D7C     ; Ends at 30,22
  STY $E7        ; Set row's limit
  LDY #$0D44     ; Starts at 3,22
  LDX #$3539     ; Tile 313, pal 5
  STX $E0        ; Priority enabled
  JMP $A783      ; Do line 2, row 2

HelpText:
  dw $791f : db "Hold Y for details.",$00
VigorText:
  dw $820d : db "Vigor",$00 ; +12 = $821f
MagicText:
  dw $828d : db "Speed",$00 ; +12 = $829f
StaminaText:
  dw $822b : db "Stamina",$00 ; +12 = $823d
SpeedText:
  dw $82ab : db "Magic",$00 ; +12 = $82bd
DefText:
  dw $838d : db "Defense",$00 ; +12 = $819f
MDefText:
  dw $83ab : db "M.Def.",$00 ; +12 = $81bd
EvadeText:
  dw $830d : db "Evade",$00 ; +12 = $831f
MEvadeText:
  dw $832b : db "M.Evade",$00 ; +12 = $833f
PowerText:
  dw $812b : db "B.Power",$00 ; + 12 = $813d
UnknownTxt:
  dw $813f : db "???",$00
PowerDash:
  dw $813f : db "---",$00
DefDash:
  dw $83a1 : db "---",$00
MDefDash:
  dw $83bf : db "---",$00
EleResist:
  dw $7B8D : db "Resist:",$00
EleAbsorb:
  dw $7C0D : db "Absorb:",$00
EleImmune:
  dw $7C8D : db "Nullify:",$00
EleWeak:
  dw $7D0D : db "Weakness:",$00

; Window layout data
GearWindow:  : dw $718B : db $1C,$06
GearActors:  : dw $750B : db $1C,$06
GearNameBox: : dw $708B : db $1C,$02
GearDesc:    : dw $738B : db $1C,$04

; ------------------------------------------------------------------------
; More EL/EP/SpellBank Helpers
; TODO: Some of this code deprecates unused labels above
; TODO: Some of this code may not be used at all

org $C3FD08
FinishSP:
  LDA #$8F          ; P
  STA $2180
  STZ $2180         ; EOS
  JMP $7FD9         ; String done, now print it

MPCost:             ; TODO: Apparently unused [??]
  PHA               ; Store SP cost for retrieval
  PHX               ; Preserve X for isolation purposes
  LDA #$FF
  STA $2180
  LDA $E1           ; ID of the spell
  JSR $50F5         ; Compute index
  LDX $2134         ; Load it
  LDA $C46AC5,X     ; Base MP cost
  PLX               ; Restore X
  JSR $04E0         ; Turns A into displayable digits
  LDA $F8           ; tens digit
  STA $2180
  LDA $F9           ; ones digit
  STA $2180
  LDA #$FF          ; space
  STA $2180
  LDA #$8C          ; M
  STA $2180
  LDA #$8F          ; P
  STA $2180
  LDA #$FF          ; 3 spaces
  STA $2180
  STA $2180
  STA $2180
  LDA $AA
  LSR
  BCC .unknown
.known
  PLA
  JMP Known         ; print a checkmark
.unknown
  PLA
  JSR $04E0         ; Turns A into displayable digits
  JMP SPCost        ; go back to where we sliced in and output SP cost

Known:  
  LDA #$FF          ; 2 spaces to center checkmark
  STA $2180
  STA $2180
  
  LDA #$CF          ; checkmark
  STA $2180
  
  LDA #$FF          ; 2 more spaces to overwrite stale text in this slot
  STA $2180
  STA $2180

  STZ $2180         ; EOS
  JMP $7FD9

NewLabels:
; The flip-flopping from white to blue for all of the static positioned
; text could be streamlined, but this is just so much simpler to grap
; than having to slice the blue in with the blue and the white in with
; the white, etc.
  JSR $04B6         ; Write banked SP to screen (relocated)
  LDY #SPMax
  JSR $02F9         ; Print "/30" with SP bank
  LDA #$24
  STA $29           ; Set text color to blue
  LDY #LearnLabel
  JSR $02F9         ; Print "Learn"
  LDA #$20
  STA $29           ; Set text color back to white
  LDA #$00
  XBA               ; Wipe HB of A
  LDA $99
  RTS

DrawEsperMP:
  LDA #$FF
  STA $2180         ; 3 spaces
  STA $2180
  STA $2180
  LDA $99           ; Current Esper
  ADC #$36          ; Get attack ID
  PHX
  JSR $50F5         ; Compute index
  LDX $2134         ; Load it
  LDA $C46AC5,X     ; Base MP cost
  PLX
  JSR $04E0         ; Turns A into displayable digits
  LDA $F8           ; tens digit
  STA $2180
  LDA $F9           ; ones digit
  STA $2180
  LDA #$FF          ; space
  STA $2180
  LDA #$8C          ; M
  STA $2180
  LDA #$8F          ; P
  STA $2180
  STZ $2180         ; EOS
  RTS

