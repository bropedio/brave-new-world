hirom

; C0 Bank

incsrc ram.asm

; #########################################################################
; Local access to RNG routine

org $C0062E : JSL Random : RTS
org $C00636 : JSL Random ; [TODO: Remove -- redundant with above]

; #########################################################################
; RNG

org $C04012 : JSL Random

; #########################################################################
; Diagonal Movement Handlers
;
; Modified to add various handling to diagonal movement (eg on stairs)
; Original patch by Lenophis

org $C0496A
FancyWalking:
  JSR $4A03 ; add to step count, deal with poison damage, save point use, etc
  LDA #$01
  STA $57
  STZ $078E
  RTS
padbyte $FF : pad $C04978
warnpc $C04978+1

; #########################################################################
; Movement Helpers (Auto-Dash)
;
; Modified by Synchysi's handling of auto-sprint shoes. Note that freespace
; at $C04A67 is used, replacing now-unused Tintinabar effect handling.

org $C04A67
Dash:
  LDA $4219      ; controller 1 input-2
  ROL            ; C: "Pressing B"
  LDA $1D4E      ; config option flags
  BIT #$10       ; "B-Button Dash"
  BEQ .exit      ; exit if ^
  BCC .carry     ; else, toggle carry
  CLC            ; ^
  RTS
.carry
  SEC            ; ^
.exit
  RTS

org $C04E28
MovementSpeed:
  JSR Dash
  NOP #2
  BCC .no_dash   ; branch if not dashing
org $C04E33
.no_dash

; #########################################################################
; General Actions pointer updates
;
; Action $67 is now used to reset ELs for current party
; Action $7F (Change Character Name) is optimized and shifted to make
; room for a fix to Action $8D (Unequip Character).

org $C09928 : dw RespecELs
org $C09958 : dw CharName

; #########################################################################
; Random Encounters (Overworld)

org $C0C257 : CMP #$D0 ; increase chance of third/forth formation encounters

; #########################################################################
; Random Encounters (Dungeons)

org $C0C3F0 : CMP #$D0 ; increase chance of third/forth formation encounters

; #########################################################################
; RNG

;org $C0C48C : JSL Random ; Now handled in Seibaby's compilation patch
;org $C0C4A9 : JSL Random ; Functionality changed in sei_encounter_rate.asm

; #########################################################################
; Unequip Character (General Action $8D) [end of routine]
;
; Leet Sketcher's "Unequipium" patch adds handling at the end of this
; routine to ensure equipment properties and stat changes are removed
; when the equipment is removed.

org $C0A035
  LDA $EB          ; character ID
  JSL $C20006      ; recalculate properties from equipment
  LDA #$02         ; args to advance
  BRA Advance      ; advance script

; #########################################################################
; Character Name Change (General Action $7F)
;
; Shifted and optimized to make room for code directly above. Otherwise
; unchanged. Note that the "Advance" label is now used by the code above.

CharName:
  JSR $9DAD        ; [?]
  LDA $EC          ; character ID
  PHA              ; store on stack
  STA $4202        ; save multiplicand
  LDA #$06         ; length of name
  STA $4203        ; multiply
  STA $EC          ; initialize counter
  NOP #2           ; wait for multiplication
  LDX $4216        ; offset to name
  PHX              ; store X
  PHY              ; store Y

.loop
  LDA $C478C0,X    ; next name char
  STA $1602,Y      ; save character name
  INX              ; next source index
  INY              ; next SRAM index
  DEC $EC          ; six characters total
  BNE .loop        ; loop through all 6 chars
  PLY              ; restore Y
  PLX              ; restore X
  PLA              ; restore $EC
  STA $EC          ; restore $EC value
  LDA #$03         ; advance script by 3

Advance:
  JMP $9B5C        ; advance script

padbyte $EA : pad $C0A07C
warnpc $C0A07C+1

; #########################################################################
; Initializing SRAM on Game Creation
;
; Modified to free up SRAM for EL/EP/SP system (synchysi)
; Modified to initialize RNG seed to non-zero (Think)

org $C0BDE2
InitStuff:
  NOP
  INC $01F1      ; initialize RNG seed to 1 [?]
  LDX $00        ; zero X
.ep_loop
  STZ !EP,X      ; zero SRAM (starting with EP)
  INX            ; next byte
  CPX #$0030     ; zero 48 bytes
  BNE .ep_loop   ; loop till done

org $C0BE03
  CPX #$0077     ; for SP SRAM initialization, plus extra space, too

; #########################################################################
; Freespace

; -------------------------------------------------------------------------
; Helper for Respec general action

org $C0D636
RespecELs:
  LDA #$16         ; length of character base stats data
  STA $4202        ; set multiplier
  LDA $EB          ; character ID
  STA $4203        ; set multiplicand
  TAY              ; index character ID
  LDA !EL,Y        ; character's esper level
  STA !EL_bank,Y   ; set in unspent esper levels
  NOP              ; wait for multiplication
  LDX $4216        ; get offset to character base stats
  PHX              ; store ^
  JSR $9DAD        ; Y: offset to character's info block
  PLX              ; restore offset to character base stats
  LDA $ED7CA6,X    ; character base vigor
  STA $161A,Y      ; reset current vigor
  LDA $ED7CA7,X    ; character base speed
  STA $161B,Y      ; reset current speed
  LDA $ED7CA8,X    ; character base stamina
  STA $161C,Y      ; reset current stamina
  LDA $ED7CA9,X    ; character base magic
  STA $161D,Y      ; reset current magic
  LDA $ED7CA0,X    ; character base level 1 MaxHP
  STA $160B,Y      ; reset current MaxHP (lobyte)
  LDA $ED7CA1,X    ; character base level 1 MaxMP
  STA $160F,Y      ; reset current MaxMP (lobyte)
  TDC              ; zero A/B
  STA $160C,Y      ; zero current MaxHP (hibyte)
  STA $1610,Y      ; zero current MaxMP (hibyte)
  STZ $20          ; zero scratch RAM
  STZ $21          ; zero scratch RAM
  LDA $1608,Y      ; character level
  JMP $9F4A        ; run level averaging to set new max HP/MP and check
  LDA #$02         ; [unused] TODO Remove this
  JMP $9B5C        ; [unused] TODO Remove this

; -------------------------------------------------------------------------
org $C0DE5E
SetMPDmgFlag:
  ORA #$01           ; [moved] Add "enable dmg numeral" flag
  PHA                ; store flags so far
  LDA ($76)          ; battle dynamics command ID
  CMP #$0B           ; is this the non-alias cmd (for cascade)
  BEQ .done          ; branch if ^
  PLA                ; else, get flags
  ORA #$40           ; add "MP Dmg" flag
  BRA .set           ; branch to exit
.done
  PLA                ; get flags
.set
  STA $631A,X        ; set animation thread flags
  RTL

SetMPDmgFlagMass:
  ORA #$01           ; [moved] Add "enable dmg numeral" flag
  PHA                ; store flags so far
  LDA ($76)          ; battle dynamics command ID
  CMP #$03           ; is this the non-alias cmd (for mass)
  BEQ .done          ; branch if ^
  PLA                ; else, get flags
  ORA #$40           ; add "MP Dmg" flag
  BRA .set           ; branch to exit
.done
  PLA                ; get flags
.set
  STA $7B3F,X        ; set animation thread flags
  RTL

PaletteMP:
  PHA                ; store palette
  LDA $631A,X        ; regular damage numerals
  BRA .check_mp      ; branch to check mp flag
.mass
  PHA                ; store palette
  LDA $7B3F,X        ; mass damage numerals
.check_mp
  AND #$40           ; "MP dmg" flag
  BEQ .normal        ; branch if not ^
  PLA                ; else, get palette
  CLC : ADC #$04     ; and advance to next palette
  BRA .set_palette   ; set palette
.normal
  PLA                ; get hp palette color
.set_palette
  STA $0303,Y        ; store palette [?]
  STA $0307,Y        ; store palette [?]
  RTL
warnpc $C0DEA0+1

; #########################################################################
; XOR Shift RNG Algorithm (replaces RNG Table)
; NOTE: The rest of RNG table is cleared out - 192 bytes free!

org $C0FD00
Random:
  PHP            ; store flags
  SEP #$20       ; 8-bit A
  XBA            ; get B
  PHA            ; store B
  REP #$20       ; 16-bit A
  LDA $01F1      ; last RNG value
  ASL #2         ; << 2
  EOR $01F1      ; XOR with RNG
  STA $01F1      ; update RNG
  LSR #7         ; >> 7
  EOR $01F1      ; XOR with RNG
  STA $01F1      ; update RNG
  ASL #15        ; << 15
  EOR $01F1      ; XOR with RNG
  STA $01F1      ; update RNG
  SEP #$20       ; 8-bit A
  PLA            ; restore B
  XBA            ; put B back
  LDA $01F1      ; RNG value
  EOR $01F0      ; XOR with frame counter
  PLP            ; restore flags
  RTL

; #########################################################################
; ROM Data for SNES
;
; Note, internal title is set in part to ensure BNW cannot be opened up
; inside of FF3usME, since it overwrites custom event scripting.

org $C0FFC0 : db "FF6: BRAVE NEW WORLD " ; set internal title (ASCII)

