hirom

; C0 Bank

; #########################################################################
; Local access to RNG routine

org $C0062E : JSL Random : RTS

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
%free($C04978)

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
; Action $66 now used to set character lvl to Max(lvl, [18,19,20,21])
; Action $67 is now used to reset ELs for current party
; Action $68 is now used to add WoB formations to WoR veldt
; Action $7F (Change Character Name) is optimized and shifted to make
; room for a fix to Action $8D (Unequip Character).

org $C09926 : dw Level18
org $C09928 : dw RespecELs
org $C0992A : dw VeldtFree
org $C09958 : dw CharName

; #########################################################################
; Level Averaging (General Action $77)

org $C09F45 : BCC SkipExpReset ; don't zero experience when level unchanged
org $C09F73 : SkipExpReset:

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

org $C0C4A9 : JSL $C0FD00

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

%nop($C0A07C)

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
; Now uses variable "minimum" level based on when character rejoins party

org $C0D613
Level18:
  LDA $1D4D          ; config settings
  AND #$08           ; "Experience Enabled"
  BNE .lvlup         ; branch if ^ (else, A=0)
.finish
  JMP $9F35          ; A will be minimum new level
.lvlup
  LDA $EB            ; event param
  TAX                ; X = character #
  LDA.l RejoinLvl,X  ; A = rejoin level
  BRA .finish        ; set new level

RejoinLvl:
  db $15 ; Terra
  db $15 ; Locke
  db $15 ; Cyan
  db $15 ; Shadow
  db $13 ; Edgar
  db $12 ; Sabin
  db $12 ; Celes
  db $15 ; Strago
  db $15 ; Relm
  db $14 ; Setzer
  db $15 ; Mog
  db $15 ; Gau
  db $15 ; Gogo
  db $15 ; Umaro

; -------------------------------------------------------------------------
; Helper for Respec general action

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

; -------------------------------------------------------------------------
; Esper Junctions (Equip Bonuses)
;
; Implement one bonus per esper. We use a series of lookup tables and
; control bytes to apply each bonus. Ensure the variables directly below
; always align with the EBonCmd lookup table order.

; Note that these control bytes are already x2 to avoid ASL
!eb_status = $00 ; Offset into status lookup (multiples of 2)
!eb_innate = $02 ; Status bitmask 3
!eb_percnt = $04 ; Percent special effects ($11D5)
!eb_stat_a = $06 ; $aaaaZZZZ | a: boost size, Z: stat offset from $11A0
!eb_stat_b = $08 ; $aaaaZZZZ | a: boost size, Z: stat offset from $11B0
!eb_elemnt = $0A ; Element resist bitmask

EBonCmd:
  dw StatusBonus
  dw InnateBonus
  dw PercentBonus
  dw StatABonus
  dw StatBBonus
  dw ElemBonus

EStatus:   ; Status bitmask 1 & 2
  dw $3800 ; $00 - Siren (mute, muddle, bserk)
  dw $0025 ; $02 - Stray (blind, poison, imp)
  dw $80C2 ; $04 - Seraph (sleep, petrify, death)

EBonus:
  db !eb_elemnt,$04   ; Ramuh (resist bolt)
  db !eb_elemnt,$01   ; Ifrit (resist fire)
  db !eb_elemnt,$02   ; Shiva (resist ice)
  db !eb_status,$00   ; Siren (status-0)
  db !eb_elemnt,$40   ; Terrato (resist earth)
  db !eb_stat_a,$52   ; Shoat (+5 stamina)
  db !eb_elemnt,$10   ; Maduin (resist wind)
  db !eb_elemnt,$80   ; Bismark (resist water)
  db !eb_status,$02   ; Stray (status-1)
  db !eb_innate,$08   ; Palidor (auto-haste)
  db !eb_innate,$20   ; Tritoch (auto-shell)
  db !eb_stat_a,$54   ; Odin (+5 speed)
  db !eb_stat_a,$00   ; Raiden (+0 magic)
  db !eb_innate,$40   ; Bahamut (auto-safe)
  db !eb_innate,$80   ; Crusader (auto-reflect)
  db !eb_percnt,$02   ; Ragnarok (+25% magical-dmg)
  db !eb_percnt,$01   ; Alexandr (+25% physical-dmg)
  db !eb_stat_a,$50   ; Kirin (+5 magic)
  db !eb_stat_b,$AB   ; Zoneseek (+10 MDef) [$11BB]
  db !eb_innate,$02   ; Carbunkl (auto-regen)
  db !eb_stat_a,$AA   ; Phantom (+10 MBlock) [$11AA]
  db !eb_status,$04   ; Seraph (status-2)
  db !eb_stat_b,$AA   ; Golem (+10 Def) [$11BA]
  db !eb_stat_a,$56   ; Unicorn (+5 vigor)
  db !eb_stat_a,$A8   ; Fenrir (+10 Evade) [$11A8]
  db !eb_percnt,$20   ; Starlet (+25% MP)
  db !eb_percnt,$04   ; Phoenix (+25% HP)

; -------------------------------------------------------------------------
; Apply Esper Equip Bonuses

EsperBonuses:
  LDA $15FB,X       ; equipped esper
  BMI .finish       ; exit if null ^
  PHX               ; store X
  ASL               ; esper index * 2
  TAX               ; index it ^
  LDA.l EBonus+1,X  ; bonus arg
  PHA               ; store on stack for a moment
  LDA.l EBonus,X    ; get bonus type (already x2)
  TAX               ; index to bonus jmp table
  PLA               ; get bonus arg
  JSR (EBonCmd,X)   ; execute bonus cmd
  PLX               ; restore X
.finish
  LDA $15ED,X       ; [displaced] MaxMP hibyte
  AND #$3F          ; [displaced] mask +% effects
  RTL

StatusBonus:
  TAX               ; index status lookup offset
  REP #$20          ; 16-bit A
  LDA.l EStatus,X   ; get status protection bits
  TSB $11D2         ; add to equipment status protection bitmask 1 & 2
  SEP #$20          ; 8-bit A
  RTS
InnateBonus:
  TSB $11D4         ; set innate statuses
  RTS
ElemBonus:
  TSB $11B9         ; add to equipment resistances
  RTS
PercentBonus:
  TSB $11D5         ; set percent bonuses
  AND #$02          ; isolate earring bit
  TSB $11D7         ; set earring bit if needed
  RTS
StatABonus:
  PHA               ; store bonus arg
  AND #$0F          ; isolate stat offset
.x
  TAX               ; index stat offset
  PLA               ; restore bonus arg
  LSR #4            ; get boost size
  CLC : ADC $11A0,X ; add to base stat Vig/Mag/Spd/Stam/Evd/MEvd/Def/MDef
  BCC .safe         ; branch if no overflow
  LDA #$FF          ; else use max 255
.safe
  STA $11A0,X       ; save new stat value
  RTS
StatBBonus:
  PHA               ; store bonus arg
  AND #$0F          ; isolate stat offset
  CLC : ADC #$10    ; start at $11B0 instead of $11A0
  BRA StatABonus_x  ; branch to regular $11A0 offset handling

; -------------------------------------------------------------------------
; Informative Miss Helpers

MaybeNull:        ; 33 bytes
  LDA $11A4       ; attack flags
  AND #$0004      ; does attack lift status?
  BEQ SetNull     ; set null flag if not
  TDC             ; set Z flag
  RTL
SetKill:
  LDA $3AA1,Y     ; check immune to instant death bit
  BIT #$04        ; immune to instant death (or fractional)
  BEQ SetEnd      ; if not immune, exit
SetNull:
  PHP             ; save M, Z flags
  REP #$20        ; 16-bit A
  LDA $3018,Y     ; get unique bit for target
  TSB !null       ; set null miss bit
  PLP             ; restore 8-bit A, no zero flag
SetEnd:
  RTL

StamPhase:        ; 27 bytes
  LDA $11A4
  BIT #$20        ; check for "cannot dodge" flag (needed for 2nd phase)
  BNE .exit       ; if cannot dodge, exit without Carry change
  BIT #$10        ; check for stamina evade flag
  BEQ .exit       ; if no stamina evade, exit without Carry change
  ORA $11A3       ; top bit holds fractional|MP bit
  BMI .first      ; first phase if Fractional or MP
  LDA $11A9       ; special effect
  CMP #$52        ; "North Cross"
  BEQ .first      ; first phase if N.Cross
.second
  SEC             ; return carry set for second phase
.exit
  RTL
.first
  CLC             ; return carry clear for first phase
  RTL

TootHelp1:        ; 61 bytes
  LDA $11A9       ; Special Effect index
  AND #$00FF      ; zero B 
  CMP #$0076      ; Evil Toot
  BNE .mind       ; if not toot, check mind blast next
  LDY #$01        ; else, set one random status
  BRA .end
.mind
  CMP #$0050      ; Mind Blast
  BNE TootHelp2   ; use regular handling if not mind blast or evil toot
  STZ $E8         ; used to flag whether target was targeted
  LDA $3018,Y     ; target's unique bit
  LDY #$00        ; start w/ no random statuses
  LDX #$08        ; prepare mind blast loop
.loop
  BIT !blast,X    ; check mind blast target bytes
  BEQ .next       ; if not this target, try next
  INC $E8         ; mark target as intended target
  PHA             ; store unique bit
  SEP #$20        ; 8-bit A
  JSL $C0FD00     ; get rand(0..256)
  LSR             ; rand(0..128)
  CLC             ; this aligns with C2 stamina evade check math
  SBC $3B40,Y     ; compare to stamina 
  REP #$20        ; 16-bit A
  PLA             ; restore unique bit
  BCC .next       ; skip hit if stamina evades
  INY             ; else, add 1 random status to set
.next
  DEX
  DEX             ; get next mind blast target index
  BPL .loop       ; end loop after checking index 0
  DEC $E8
  BMI .miss       ; if this target was not targeted, flag miss
  CPY #$00
  BNE .end        ; if was targeted, and a hit landed, exit
  TSB !fail       ; if all hits were evaded, flag "fail"
.miss
  TSB !miss       ; flag "miss" (overriden by fail above)
.end
  RTL

TootHelp2:        ; 10 bytes
  LDA $11AA       ; attack status bytes 1-2
  STA $FC         ; set status-to-set bytes 1-2
  LDA $11AC       ; attack status bytes 3-4
  STA $FE         ; set status-to-set bytes 3-4
  PLA             ; remove C2 address of RTL
  PEA $447A       ; make RTL below return to end (must keep aligned w/ old_miss)

TootHelp3:        ; 9 bytes
  LDA $F8         ; current status 1-2
  TRB $FC         ; remove from status to set
  LDA $FA         ; current status 3-4
  TRB $FE         ; remove from status to set
  RTL

StatusHelp:       ; 20 bytes
  BEQ .miss       ; if Z flag set, no fail bit
  LDA $3018,Y     ; get unique bit for target
  TSB !fail       ; set fail miss bit
.miss
  PHA             ; save unique bit (or zero)
  LDA $11A7
  LSR             ; "miss if status unchanged" flag
  PLA             ; load unique bit (or empty)
  BCC .end        ; if no full miss, exit
  TSB !miss       ; else, set full miss bit
.end
  RTL

; -------------------------------------------------------------------------
; Status Removal After Death (delayed) Helpers
;
; When monsters die, avoid removing the following statuses
; until after any possible counterattack or additional strike
; has a chance to execute. Otherwise, that counterattack or
; strike will behave as though these statuses were not set.
; Statuses: Dark, Mute, Shell, Safe, Sleep, Muddle, Berserk, Freeze, Stop

StatusRemove:
  CPY #$08             ; is target a monster?
  BCC .skip            ; branch if character
  LDA $3018,Y          ; unique entity bit
  TSB !died_flag       ; flag this entity for status cleanup
.skip
  LDA $FA              ; vanilla code (curr status 3-4)
  ORA $FE              ; vanilla code (status to set 3-4)
  AND #$9BFF           ; statuses removed by death
  BCC .all
  AND #$998F           ; skip removing Shell, Safe, Freeze, Stop
.all
  TSB $F6              ; set status-to-clear 3-4
  RTL

StatusFinHelp:         ; 33 bytes
  LDX #$12             ; prepare loop through all entities
.loop
  LDA $3018,X          ; entity's unique bit
  TRB !died_flag       ; did this entity just die?
  BEQ .next            ; branch if not
  LDA $3EE4,X          ; status 1-2
  AND #$B801           ; Dark, Mute, Sleep, Muddle, Berserk
  STA $3DFC,X          ; status-to-clear 1-2
  LDA $3EF8,X          ; status 3-4
  AND #$0270           ; Frozen, Stop, Safe, Shell
  STA $3E10,X          ; status-to-clear 3-4
.next
  DEX
  DEX                  ; point to next lowest entity
  BPL .loop            ; loop through all entities
  RTL

; -------------------------------------------------------------------------
; Helper for Poison Tick Adjustments (from C2)

TickLogic:
  STA $BD         ; set damage increment
  BEQ .incr       ; initialize tick to 100%
  CPY #$08        ; monster range
  BCC .incr       ; branch if player target
  ASL             ; double tick for monsters
  INC             ; +50% more damage
  RTL
.incr
  INC #2          ; add 100% more damage
  RTL

; -------------------------------------------------------------------------
; Helper for North Cross targeting
; (runs immediately before status phase)

NorthCrossMiss:
  PHP
  LDA $11A9              ; special effect
  CMP #$52               ; "N.Cross" special index
  BNE .exit              ; exit if not "N.Cross"
  REP #$20               ; 16-bit A
  LDA !miss              ; get "missed" targets
  STA !fail              ; use "failed" message
  LDA $A4                ; remaining targets
  TSB !miss              ; set all as missed
  PHX                    ; store X
  JSL PostCheckHelp      ; will change X
  PLX                    ; restore X
  ORA $E8                ; combine both targets
  STA $A4                ; set as new targets
  TRB !miss              ; remove from "missed" targets
.exit
  PLP
  RTL

; -------------------------------------------------------------------------
; Helpers for Elemental Status Null patch

Nulled:
  JSR RemoveStatuses  ; if null dmg, remove statuses
  STZ $F0             ; zero dmg lobyte [moved]
  STZ $F1             ; zero dmg hibyte [moved]
  RTL
Absorb:
  JSR RemoveStatuses  ; if absorb dmg, remove statuses
  LDA $F2             ; attack flags [moved]
  EOR #$01            ; toggle "Heal" [moved]
  RTL
RemoveStatuses:
  PHP                 ; store flags 
  TDC                 ; zero A/B
  REP #$20            ; 16-bit A
  STA $3DD4,Y         ; clear status-to-set 1, 2
  STA $3DE8,Y         ; clear status-to-set 3, 4
  LDA $3018,Y         ; unique bit for target
  TRB !null           ; remove "null" message (if set)
  TRB !fail           ; remove "fail" message (if set)
  PLP                 ; restore flags
  RTS

; -------------------------------------------------------------------------
; Helpers for Palidor Redux (in C2)

WaitTimer:
  LDA $3204,X            ; load 3204,X and 3205,X
  BPL .flying            ; branch if entity is riding Palidor
  LDA $3AC8,X            ; ATB timer incrementor
  LSR                    ; divided by two
  RTL
.flying
  LDA #$00C8             ; use fixed ATB increment while flying
  RTL

BetterPaliFlags:
  BMI .done              ; if not landing, return
  ORA #$80               ; "has landed since boarding Palidor"
  STA $3205,X            ; set "has landed" bit
  LDA $3AA0,X            ; get battle flow byte
  BPL .done              ; skip setting flag if no extra turn
  ORA #$08               ; set bit 3 to preserve ATB
  STA $3AA0,X            ; update battle flow byte
.done
  RTL

ClearWaitQ:
  LDY $3A64              ; current wait queue index
.loop
  TXA                    ; put this rider's index in A
  CMP $3720,Y            ; is this rider in wait queue here?
  BNE .next              ; if not, branch
  LDA #$FF               ; null
  STA $3720,Y            ; set this wait queue entry to null
.next
  INY                    ; get next wait queue index
  CPY $3A65              ; is this lower than the next unfilled entry?
  BCC .loop              ; continue loop if so
  LDA $3205,X            ; vanilla code
  AND #$7F               ; vanilla code
  RTL

; -------------------------------------------------------------------------
; Helper for X Fight Retargeting Fix (in C2)

HandleXFight:            ; 27 bytes
  LDA #$20               ; "First strike of turn"
  TRB $B2                ; test and clear
  BNE .retarget          ; if set, exit without setting "no retarget"
  LDA $B5                ; command ID
  BNE .no_retarget       ; if not "Fight", set "no retarget"
  LDA #$01               ; odd bit set for right-hand swings
  BIT $3A70              ; # of hits remaining (after this one)
  BNE .retarget          ; if right-hand, skip setting "no retarget"
  LDA $3B68,X            ; right-hand battle power
  BNE .no_retarget       ; if nonzero, lefthand is dualwield, so no retarget
.retarget
  LDA #$20               ; prepare BIT check (and clear zero flag)
  RTL
.no_retarget
  TDC                    ; set zero flag
  RTL

; -------------------------------------------------------------------------
; Helpers for Invalid Targets Spellproc fix (C2)
; Fix vanilla bug that allows procs to fire even if
; the accompanying weapon strike had no targets to
; strike.

ProcFix:               ; 12 bytes
  LDA $B8              ; character targets
  ORA $B9              ; enemy targets
  BEQ .exit            ; if none, abort spellcast
  LDA $3A89            ; spellcast byte (vanilla code)
  BIT #$40             ; "cast randomly" flag
.exit
  RTL                  ; on return, abort spellcast if Z flag set
ProcFix2:              ; 14 bytes
  LDA $B8              ; character targets
  ORA $B9              ; enemy targets
  BEQ .exit            ; if none, abort spellcast
  XBA                  ; get spell #
  STA $3400            ; [displaced] set addition magic
  INC $3A70            ; [displaced] increment number of remaining strikes
.exit
  RTL

; -------------------------------------------------------------------------
; Helper for Defending boost to Tank+Spank
;
; Apply on top of Tank+Spank patch to double chance
; of covering healthy allies when in "defend" mode.

DefendBetter:          ; [13 bytes]
  SEP #$20             ; 8-bit A
  LDA $3AA1,X          ; knight's special flags
  LSR #2               ; shift "defending" flag to carry
  LDA #$C0             ; 192 (cover threshold / 255)
  BCC .done            ; branch if not defending
  LSR                  ; 96 (lower cover threshold / 255)
.done
  RTL

; -------------------------------------------------------------------------
; Helpers for "Half Battle Power" patch

GetBushPwr:
  REP #$20        ; 16-bit A [moved]
  PHA             ; save power so far
  SEP #$20        ; 8-bit A
  LDA $3C58,X     ; weapon effects
  BIT #$10        ; dual wielding
  JSR GetBatPwr   ; get base battle power (preserves Z flag)
  REP #$20        ; 16-bit A
  BEQ .norm       ; branch if not dual wielding
  ASL             ; else, double base battle power
.norm
  CLC : ADC $01,S ; add to power-so-far
  STA $01,S : PLA ; clean up stack
  LSR #2          ; [moved]
  RTL

GetPwrFork:
  SEP #$20        ; [moved]
  LDA $B5         ; command ID
  CMP #$16        ; is command "Jump"
  BEQ .get_pwr    ; branch if ^
  LDA $3413       ; backup command (fight/mug)
  BMI .exit       ; exit if not fight/mug or battle
.get_pwr
  JSR GetBatPwr   ; get base battle power
  REP #$21        ; 16-bit A
  ADC $04,S       ; add to stored power on stack
  STA $04,S       ; overwrite with full power
  SEP #$20        ; 8-bit A
.exit
  LDA $B5         ; [moved]
  RTL

GetBatPwr:
  PHP             ; store flags (including Z)
  LDA $3ED8,X     ; character X's ID
  STA $004202     ; prep multiplication
  LDA #$16        ; size of character startup block
  STA $004203     ; start mutliplication
  NOP #3          ; wait for processor
  REP #$30        ; 16-bit X/Y,A
  LDA $004216     ; get product
  PHX             ; save character index 
  TAX             ; index to character data
  TDC             ; zero A/B
  SEP #$20        ; 8-bit A
  LDA $ED7CAA,X   ; character battle power
  PLX             ; restore character index
  PLP             ; restore flags (including Z)
  RTS

; -------------------------------------------------------------------------
; Gau Veldt Freebies

; Add a new event command to automatically unlock all the WoB-exclusive
; formations on the Veldt (very hardcoded to formations as they appeared
; in BNW 2.1).

VeldtFree:
  PHA                 ; Preserve A
  PHX                 ; Preserve X
  PHP                 ; Preserve CPU flags
  SEP #$30            ; Set 8-bit accumulator and index registers
  LDX #$11            ; Loop through 17 bytes
.loop
  LDA $7E1DDC,X       ; Index of Veldt formations clear data in SRAM
  ORA.l FreeForms-1,X ; Combine with table data
  STA $7E1DDC,X
  DEX                 ; Next value
  BNE .loop           ; Loop 15 times
  PLP                 ; Restore CPU flags
  PLX                 ; Restore X
  PLA                 ; Restore A
  LDA #$01            ; Number of bytes until next event command in script = 1
  JMP $9B5C           ; Advance event queue

FreeForms:
  db $EE              ; Formations 0-7
  db $77              ; Formations 8-15
  db $A0              ; Formations 16-23
  db $48              ; Formations 24-31
  db $88              ; Formations 32-39
  db $A0              ; Formations 40-47
  db $54              ; Formations 48-55
  db $11              ; Formations 56-63
  db $00              ; Formations 64-71
  db $00              ; Formations 72-79
  db $19              ; Formations 80-87
  db $C8              ; Formations 88-95
  db $31              ; Formations 96-103
  db $50              ; Formations 104-111
  db $C9              ; Formations 112-119
  db $98              ; Formations 120-127
  db $11              ; Formations 128-135

; -------------------------------------------------------------------------

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

; -------------------------------------------------------------------------
; Helper for Gau Targeting (single target across field) support

SpreadRandom:        ; 24 bytes
  LDA $BB            ; targeting byte (vanilla code)
  AND #$2C           ; "multi" flags or "manual" flag
  CMP #$20           ; "manual party select"
  BEQ .chance        ; if only "manual" set, flip coin
  AND #$0C           ; "both parties"/"one party" (vanilla code)
  RTL
.chance
  JSL Random         ; random number
  LSR                ; 50% chance of carry set
  TDC                ; neither "multi" flags set
  BCC .done          ; finish 50% of time (single target)
  LDA #$08           ; "autoselect one party"
  TSB $BB            ; spread targeting
.done
  RTL

; -------------------------------------------------------------------------
; Helper for "Mug Better" patch
;
; Delay check for added "Steal" until special effect routine 
; so other weapon special effects are preserved.

MugHelper:
  PHP                   ; store M/X flags
  SEP #$20              ; 8-bit A
  JSL LongSpecial       ; process original special effect
  LDA $B5               ; command id
  CMP #$06              ; "Mug" command ID
  BNE .exit             ; exit if not
  LDA $11A9             ; weapon special effect
  PHA                   ; store on stack
  LDA #$A4              ; steal effect (id $52)
  STA $11A9             ; set steal as temporary special effect
  JSL LongSpecial       ; run Steal function (for Mug attempt)
  PLA                   ; pull weapon special effect off stack
  STA $11A9             ; restore original special effect byte
  CMP #$02              ; "SwitchBlade" special
  BEQ .exit             ; attack always hits for SwitchBlade proc
  LDA $3401             ; steal result message
  CMP #$03              ; was steal successful?
  BCS .exit             ; branch if ^
  STA $3A48             ; flag target as missed
  LDA #$20              ; "Flash Screen" animation flag
  TRB $A0               ; remove "Flash" from animation flags
.exit
  PLP                   ; restore M/X flags
  LDA $3A48             ; missed flag (vanilla code)
  RTL

; -------------------------------------------------------------------------

warnpc $C0DFA0          ; end of large freespace

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

; -------------------------------------------------------------------------
; Elemental Damage Modification Helper

org $C0FD40
EleModLoop:
  BIT $3BCD,X      ; check immunities
  BNE .next        ; if immune, skip dmg increments
.inys
  BIT $3BE1,X      ; check resistances
  BNE .half        ; only iny 50%
  INY
.half
  INY
  BCS .skip        ; skip weakness check 2nd time
  SEC              ; track weakness loop
  BIT $3BE0,X      ; check weaknesses
  BNE .inys        ; double increments via loop
.skip
  CLC
.next
  INC $EE
  DEC $EE          ; check if no remaining attack elems
  RTL
%free($C0FD84)

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

