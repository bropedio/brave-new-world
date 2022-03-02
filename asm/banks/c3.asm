hirom

; C3 Bank

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

