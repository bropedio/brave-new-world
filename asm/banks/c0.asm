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

org $C04A65 : BRA C04A93 ; skip tintinabar effect (now freespace)

Dash:            ; Helper for auto-sprint shoes
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

org $C04A93 : C04A93:

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
; Action $66 now used to set character lvl to Max(lvl, 18)
; Action $67 is now used to reset ELs for current party
; Action $7F (Change Character Name) is optimized and shifted to make
; room for a fix to Action $8D (Unequip Character).

org $C09926 : dw Level18
org $C09928 : dw RespecELs
org $C09958 : dw CharName

; #########################################################################
; Random Encounters (Overworld)

org $C0C257 : CMP #$D0 ; increase chance of third/forth formation encounters

; #########################################################################
; Random Encounters (Dungeons)

org $C0C3F0 : CMP #$D0 ; increase chance of third/forth formation encounters

; #########################################################################
; Random Encounters Helpers

; -------------------------------------------------------------------------
; Encounter chance RNG
; Should raise the minimum number of steps for a random encounter to 10,
; while still maintaining the overall rate

org $C0C48C
  LDA #$E9          ; 233
  JSR RandomRangeC0 ; random(233) [uses C2 routine]
  CLC               ; clear carry
  ADC #$04          ; random(4..236)

; -------------------------------------------------------------------------
; Formation selection RNG
; TODO: This RNG change is a bug, which is fixed by a later bropedio patch

org $C0C4A9
  LDA #$E9          ; 233
  JSR RandomRangeC0 ; random(233) [uses C2 routine]
  CLC               ; clear carry
  ADC #$04          ; random(4..236)

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
; HP and MP Addition/Subtraction Actions
; Fix so HP refill also refills MP, eg. in the Lineup Menu

org $C0AE83
HPChangeAction:
.exit
  JMP $AF90        ; exit via MP change code instead
org $C0AEAC
  BRA .exit        ; update exit branch
org $C0AEC7
  BRA .exit        ; update exit branch
org $C0AED5
  JMP $AF3E        ; after maxing HP, jump to MP code

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
; Helper for "Raise Lvl to 18" general action

org $C0D613
Level18:
  LDA $1D4D        ; config settings
  BIT #$08         ; "Experience On"
  BEQ .exit        ; exit if not ^
  JSR $9DAD        ; Y: charcter data offset
  LDA $1608,Y      ; character Level
  CMP #$12         ; >= 18
  BCS .exit        ; exit if ^
  DEC              ; Level index
  STA $20          ; save ^ [for HP/MP routine]
  STZ $21          ; zero   [for HP/MP routine]
  LDA #$12         ; 18
  STA $1608,Y      ; set level 18
  JMP $9F4A        ; set new max HP/MP, learn natural spells
.exit
  LDA #$02         ; # params to skip
  JMP $9B5C        ; done

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
; Esper Junctions (Equip Bonuses)
; TODO: Could save lots of space by converting data to script
;       eg. [op][arg], so Ramuh could be [elem_op][$04]

; Immunity 1    Immunity 2       Status 1      Special           Elem-half
; $80: Death    $80: Sleep       $80: Reflect  $80: MP +12.5%    $80: Water
; $40: Petrify  $40: Seizure     $40: Safe     $40: MP +50%      $40: Earth
; $20: Imp      $20: Muddle      $20: Shell    $20: MP +25%      $20: Pearl
; $10: Clear    $10: Berserk     $10: Stop     $10: HP +12.5%    $10: Wind
; $08: MagiTek  $08: Mute        $08: Haste    $08: HP +50%      $08: Poison
; $04: Poison   $04: Image       $04: Slow     $04: HP +25%      $04: Bolt
; $02: Zombie   $02: Near Fatal  $02: Regen    $02: MDamage +25% $02: Ice
; $01: Dark     $01: Condemned   $01: Float    $01: PDamage +25% $01: Fire

; Speed/Vigor   Magic/Stamina    Defense       MDef              Mblock/Evade
; $x0: Speed    $x0: Magic       $xx: Defense  $xx: Mdef         $x0: Mblock
; $x0: Speed    $x0: Magic       $xx: Defense  $xx: Mdef         $x0: Mblock
; $x0: Speed    $x0: Magic       $xx: Defense  $xx: Mdef         $x0: Mblock
; $x0: Speed    $x0: Magic       $xx: Defense  $xx: Mdef         $x0: Mblock
; $0x: Vigor    $0x: Stamina     $xx: Defense  $xx: Mdef         $0x: Evade
; $0x: Vigor    $0x: Stamina     $xx: Defense  $xx: Mdef         $0x: Evade
; $0x: Vigor    $0x: Stamina     $xx: Defense  $xx: Mdef         $0x: Evade
; $0x: Vigor    $0x: Stamina     $xx: Defense  $xx: Mdef         $0x: Evade

org $C0D690
  db $00                  ; Ramuh: Status immunity 1
  db $00                  ; Ramuh: Status immunity 2
  db $00                  ; Ramuh: Innate status
  db $00                  ; Ramuh: Damage & HP%/MP% bonuses
  db $04                  ; Ramuh: Elemental resistance
  db $00                  ; Ramuh: Speed & Vigor
  db $00                  ; Ramuh: Magic & Stamina
  db $00                  ; Ramuh: Defense
  db $00                  ; Ramuh: Magic Defense
  db $00                  ; Ramuh: M.Block & Evade

  db $00,$00,$00,$00,$01,$00,$00,$00,$00,$00    ; Ifrit
  db $00,$00,$00,$00,$02,$00,$00,$00,$00,$00    ; Shiva
  db $01,$28,$00,$00,$00,$00,$00,$00,$00,$00    ; Siren
  db $00,$00,$00,$00,$40,$00,$00,$00,$00,$00    ; Terrato
  db $00,$00,$00,$00,$00,$00,$05,$00,$00,$00    ; Shoat
  db $00,$00,$00,$00,$10,$00,$00,$00,$00,$00    ; Maduin
  db $00,$00,$00,$00,$80,$00,$00,$00,$00,$00    ; Bismark
  db $24,$10,$00,$00,$00,$00,$00,$00,$00,$00    ; Stray
  db $00,$00,$08,$00,$00,$00,$00,$00,$00,$00    ; Palidor
  db $00,$00,$20,$00,$00,$00,$00,$00,$00,$00    ; Tritoch
  db $00,$00,$00,$00,$00,$50,$00,$00,$00,$00    ; Odin
  db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00    ; Raiden
  db $00,$00,$40,$00,$00,$00,$00,$00,$00,$00    ; Bahamut
  db $00,$00,$80,$00,$00,$00,$00,$00,$00,$00    ; Crusader
  db $00,$00,$00,$02,$00,$00,$00,$00,$00,$00    ; Ragnarok
  db $00,$00,$00,$01,$00,$00,$00,$00,$00,$00    ; Alexandr
  db $00,$00,$00,$00,$00,$00,$50,$00,$00,$00    ; Kirin
  db $00,$00,$00,$00,$00,$00,$00,$00,$0A,$00    ; Zoneseek
  db $00,$00,$02,$00,$00,$00,$00,$00,$00,$00    ; Carbunkl
  db $00,$00,$00,$00,$00,$00,$00,$00,$00,$A0    ; Phantom
  db $C2,$80,$00,$00,$00,$00,$00,$00,$00,$00    ; Seraph
  db $00,$00,$00,$00,$00,$00,$00,$0A,$00,$00    ; Golem
  db $00,$00,$00,$00,$00,$05,$00,$00,$00,$00    ; Unicorn
  db $00,$00,$00,$00,$00,$00,$00,$00,$00,$0A    ; Fenrir
  db $00,$00,$00,$20,$00,$00,$00,$00,$00,$00    ; Starlet
  db $00,$00,$00,$04,$00,$00,$00,$00,$00,$00    ; Phoenix

; -------------------------------------------------------------------------
; Esper Equip Bonus application

org $C0D79E
EsperBonuses:
  LDA $15FB,X       ; equipped esper
  BPL .chk_bonus    ; branch if not null ^
  JMP .finish       ; else, exit/finish
.chk_bonus
  XBA               ; store esper index
  LDA #$0A          ; size of esper item block
  REP #$20          ; 16-bit A
  STA $004202       ; set multiplication register
  PHX               ; store X
  PHY               ; store Y
  NOP               ; wait for multiplication
  LDA $004216       ; esper data offset
  TAX               ; index it ^
  LDA $C0D690,X     ; Status protection
  TSB $11D2         ; add to equipment status protection
  LDA $C0D692,X     ; Innate statuses and percent bonuses
  JSR EarringFix    ; hook to extend handling in subroutine
  LDA $C0D695,X     ; Stat bonuses
  LDY #$0006        ; stat iterator (4 stats)
.loop
  PHA               ; store stat bonuses
  AND #$000F        ; buttom nibble
  CLC               ; clear carry
  ADC $11A0,Y       ; add to equipment stat bonus byte
  STA $11A0,Y       ; update ^
  PLA               ; restore stat bonuses
  LSR #4            ; shift next stat into place
  DEY #2            ; decrement iterator
  BPL .loop         ; loop through all 4 core stats
  SEP #$20          ; 8-bit A
  LDA $C0D699,X     ; Evade & Mblock
  PHA               ; store ^
  AND #$0F          ; bottom nibble TODO: Missing CLC
  ADC $11A8         ; add to equipment Evade stat
  STA $11A8         ; update ^
  PLA               ; restore Evade/MBlock
  AND #$F0          ; get MBlock TODO: Unnecessary AND, just CLC after LSR
  LSR #4            ; shift MBlock into place
  ADC $11AA         ; add to equipment MBlock stat
  STA $11AA         ; update ^
  LDA $C0D694,X     ; Elemental resistances
  TSB $11B9         ; add to equipment resistances
  LDA $C0D697,X     ; Defense TODO: Missing CLC, but probably no bug
  ADC $11BA         ; add to equipment defense
  BCC .noCap1       ; branch if no overflow
  LDA #$FF          ; else use max 255
.noCap1
  STA $11BA         ; update equipment defense
  LDA $C0D698,X     ; M.Def TODO: Missing CLC
  ADC $11BB         ; add to equipment M.Def
  BCC .noCap2       ; branch if no overflow
  LDA #$FF          ; else use max 255
.noCap2
  STA $11BB         ; update equipment M.Def
  PLY               ; restore Y
  PLX               ; restore X
.finish
  LDA $15ED,X       ; [displaced] MaxMP hibyte
  AND #$3F          ; [displaced] mask +% effects
  RTL

org $C0D827
EarringFix:         ; TODO: Move this code in-line
  TSB $11D4         ; [displaced] add to equipment innate statuses/etc
  SEP #$20          ; 8-bit A
  XBA               ; A = 11D5 bits 
  AND #$02          ; isolate earring bit
  TSB $11D7         ; set earring bit
  REP #$20          ; 16-bit A
  RTS

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
; Freespace

org $C0FF90
RandomRangeC0:
  JSL RandomRange ; leverage C2 random in range routine
  RTS

; #########################################################################
; ROM Data for SNES
;
; Note, internal title is set in part to ensure BNW cannot be opened up
; inside of FF3usME, since it overwrites custom event scripting.

org $C0FFC0 : db "FF6: BRAVE NEW WORLD " ; set internal title (ASCII)

