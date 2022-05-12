hirom

; C2 Bank

; #########################################################################
; Part of Attack Prep

; -------------------------------------------------------------------------
; Skip handling that turns commands into "Fight" when Imped. Below this
; point is now freespace

org $C202A0 : PLA : RTS

; -------------------------------------------------------------------------
; MP Critical Helper

MPCritCost:
  LDA $3C45,y       ; relic effects
  BIT #$0020        ; "Halve MP Cost"
  BEQ .exit         ; exit if not ^
  LSR $EE           ; halve MP cost for MP Crit
.exit
  RTS

; -------------------------------------------------------------------------
; Note, assumes no more than 1 overflow in $EA from multiplication
; (Imp command disabling used as Freespace)

org $C202AD
AtmaOver:
  TDC : DEC         ; $FFFF
  JSR $4792         ; 65535 / (maxHP / 256 + 1)
  CLC : ADC $F0     ; add to final damage
  STA $F0           ; update final damage
  RTS
warnpc $C202B8+1

; -------------------------------------------------------------------------
; Zantetsuken helper
; Undead killer weapon effect enters here due to 50% proc rate

org $C202BC
  LDA #$EE          ; "XKill" animation ID [TODO: No longer used]
KillZombie:
  XBA               ; store in B
  JSR $4B5A         ; random(0..256)
  CMP #$80          ; C: 50% chance [TODO: Use random(0..2) function]
  JMP Undead_Killer ; jump to another helper

warnpc $C202DC+1

; #########################################################################
; Adding Command to Wait Queue + Swap Roulette to Enemy Roulette

; -------------------------------------------------------------------------
; Removes the check for enemy Roulette
; NOTE: Creates freespace below

org $C203B0
  JSR $03E4        ; [moved] determine time to wait
  JMP $4ECB        ; [moved] queue chosen command

; -------------------------------------------------------------------------
; Helper for Boss death ignoring HP reduction

BossDeath:
  LDA $3C95,Y      ; special monster flags
  AND #$0040       ; "Boss" (formerly "Auto crit if Imp")
  BEQ .death       ; branch if not ^
  RTS              ; else, exit now to prevent bosses from dying from HP loss
.death
  LDA #$0080       ; "Death" status
  JMP $0E32        ; add ^ to status-to-set byte 1

; #########################################################################
; Time to Wait Determination

; -------------------------------------------------------------------------
; Hook for Moogle Charm "falls like a stone" effect

org $C203EE : JSR Charm_Chk

; #########################################################################
; Select actions/commands for uncontrollable characters
; 
; Rewritten as part of Assassin's "Swordless Runic" patch, to fix a bug
; that would allow Celes to perform "Runic" when confused, even when not
; wielding a sword.
;
; Additionally, creates space for additional commands with special handling
; when confused.
;
; Modified by "Brushless Sketch" to add support for disabling "Sketch"
; when muddled and not wielding a brush.

org $C20420
UncontrollableCmds:
  TXA                ; attacker index
  XBA                ; store in B
  LDA #$06           ; multiplicand
  JSR $4781          ; X * 6
  TAY                ; index to menu data
  STZ $FE            ; save Fight as command 5
  STZ $FF            ; save Fight as command 6
  LDA $202E,Y        ; menu slot 1
  STA $F6            ; save
  LDA $2031,Y        ; menu slot 2
  STA $F8            ; save
  LDA $2034,Y        ; menu slot 3
  STA $FA            ; save
  LDA $2037,Y        ; menu slot 4
  STA $FC            ; save
  LDA #$05           ; assume 5 valid commands
  STA $F5            ; save ^
  STZ $F4            ; zero "Mostly Uncontrollable"
  LDA $3EE5,X        ; status-2 Bit 5 = Muddled
  BIT #$10           ; "Berserk"
  BNE .skip          ; branch if ^
  ASL #2             ; N: "Muddled", V: "Berserk"
  STA $F4            ; save ^
  LDA $3395,X        ; charmer
  EOR #$80           ; $7F=nocharmer, $8x=charmer
  ORA $3A97          ; top bit indicates Colosseum battle
  TSB $F4            ; set bit 7 if in Colosseum or being charmed
.skip
  TXY                ; Y: attacker index
  PHX                ; store attacker index
  LDX #$06           ; initialize command slot loop
.slot_loop
  PHX                ; save loop index
  LDA $F6,X          ; next command slot
  PHA                ; save command ID
  BMI .skip2         ; branch if null command ID
  CLC                ; clear carry
  LDX $F4            ; N: "Uncontrollable but not Berserked"
  BMI .no_bserk      ; branch if ^
  JSR $5217          ; X: index to bitmask, A: command bit in bitmask
  AND ZombieCmds,X   ; command allowed when Berserked/Zombied
  BEQ .skip2         ; branch if not ^
  BRA .skip3         ; else, branch
.no_bserk
  JSR $5217          ; X: index to bitmask, A: command bit in bitmask
  AND MuddleCmds,X   ; command allowed when Muddled/Charmed/Colosseum
  BNE .skip3         ; branch if ^
.skip2
  LDA #$FF           ; "null" command
  STA $01,S          ; replace current command with null
  DEC $F5            ; decrement valid command count
.skip3
  TDC                ; zero A/B (B important below)
  LDA $01,S          ; current command
  LDX #$0B           ; prep next loop
.special_loop
  CMP SpecialCmds,X  ; matches command requiring special function
  BNE .next          ; branch to next if not ^
  TXA                ; table index
  ASL                ; x2
  TAX                ; index to special command function
  LDA $01,S          ; get current command (again, for safety)
  JSR (CmdFuncs,X)  ; run special routine (returns attack/spell #)
  XBA                ; B: attack/spell number [?]
  BRA .continue      ; exit loop
.next
  DEX                ; next command index
  BPL .special_loop  ; loop through all special commands
.continue
  PLA                ; get current command
  PLX                ; get current command menu slot
  STA $F6,X          ; update command in this slot
  XBA                ; get attack/spell # from special routine (or zero)
  STA $F7,X          ; save ^
  DEX #2             ; next command slot
  BPL .slot_loop     ; loop through 4 slots
  LDA $F5            ; how many valid commands
  JSR $4B65          ; random(commands.length)
  TAY                ; index it
  LDX #$08           ; point to command slot 5
.loop3
  LDA $F6,X          ; command in slot
  BMI .next2         ; branch if nulled
  DEY                ; decrement selected command number
  BMI .finish        ; branch if found our random command
.next2
  DEX #2             ; point to next command slot
  BPL .loop3         ; loop through all 5 slots
  TDC                ; zero A/B
  BRA .exit          ; exit if no valid command found (maybe unnecessary)
.finish
  XBA                ; store command ID
  LDA $F7,X          ; attack/spell number
  XBA                ; swap back
.exit
  PLX                ; restore X
  RTS                ; A: command ID, B: spell ID

MuddleCmds:
  db $ED  ; Fight, Magic, Morph, Steal, Capture, SwdTech
  db $3E  ; Tools, Blitz, Runic, Lore, Sketch
  db $DD  ; Rage, Mimic, Dance, Row, Jump, X-Magic
  db $2D  ; GP Rain, Health, Shock, MagiTek

ZombieCmds:
  db $41  ; Fight, Capture
  db $00  ; none
  db $41  ; Rage, Jump
  db $20  ; MagiTek

SpecialCmds:
  db $02  ; Magic
  db $17  ; X-Magic
  db $07  ; SwdTech
  db $0A  ; Blitz
  db $10  ; Rage
  db $13  ; Dance
  db $0C  ; Lore
  db $03  ; Morph
  db $1D  ; MagiTek
  db $09  ; Tools
  db $0B  ; Runic
  db $0D  ; Sketch
  db $FF  ; Currently unused
  db $FF  ; Currently unused

CmdFuncs:
  dw $051A        ; Magic
  dw $051A        ; X-Magic
  dw $0560        ; SwdTech
  dw $0575        ; Blitz
  dw $05D1        ; Rage
  dw $059C        ; Dance
  dw $04F6        ; Lore
  dw $0519        ; Morph (RTS -- always available now)
  dw $0584        ; MagiTek
  dw $058D        ; Tools
  dw RunicCheck   ; Runic
  dw MuddleSketch ; Sketch
  dw $FFFF        ; Currently unused
  dw $FFFF        ; Currently unused
warnpc $C204F6+1

; ########################################################################
; Uncontrollable/Muddle Random Attack Selections

; ------------------------------------------------------------------------
; Morph random behavior (now freespace)

org $C20557
ItemMod:
  BCS .done ; branch if not an actual item
  STZ $3414 ; ignore damage modification
.done
  LDA $3411 ; [displaced]
  RTS

; ------------------------------------------------------------------------
; Changes the odds each dance step shows up.

org $C205CE : dl $104090 ; 10/FF; 30/FF; 60/FF
org $C20600 : JSR Rage   ; rage selection helper

; ########################################################################
; Command Wait Times

org $C2067B
CommandWaitTimes:
  db $10   ; Fight
  db $10   ; Item
  db $20   ; Magic
  db $40   ; Morph
  db $00   ; Revert
  db $00   ; Steal
  db $00   ; Capture
  db $20   ; Bushido
  db $10   ; Throw
  db $20   ; Tools
  db $20   ; Blitz
  db $00   ; Runic
  db $20   ; Lore
  db $10   ; Sketch
  db $20   ; Control
  db $20   ; Slot
  db $10   ; Rage
  db $00   ; Leap
  db $00   ; Mimic
  db $10   ; Dance
  db $00   ; Row
  db $00   ; Defend
  db $70   ; Jump
  db $20   ; X-Magic
  db $20   ; GP Rain
  db $40   ; Summon
  db $10   ; Health
  db $10   ; Shock
  db $00   ; Possess
  db $00   ; MagiTek

; ########################################################################
; Initialize some things at battle start

org $C20847
  PHY            ; store Y
  JSR XMagCntr   ; hook to persist X-Magic counter till second strike
  PLY            ; restore Y
  NOP            ; [padding]

; ########################################################################
; Condemned Counter Initialization
; Timer starting value reduced due to nATB slowing things down

org $C209BB : NOP #3 ; shorten countdown time by one level count
org $C209C1 : LDA #$1E ; subtract from 30 instead of 60
org $C209C8 : ADC #$0A ; add 10 instead of 20

; ########################################################################
; ATB Multipliers (slow/haste/normal)

org $C209D2
ATBMultipliers:
  PHP             ; store flags
  LDY #$3C        ; multiplier 60 if slowed
  LDA $3EF8,X     ; status-3
  BIT #$04        ; "Slow"
  BNE .set_mult   ; branch if ^
  LDY #$4B        ; multiplier 75 normally
  BIT #$08        ; "Haste"
  BEQ .set_mult   ; branch if not ^
  LDY #$5A        ; multiplier 90 if hasted
.set_mult
  TYA             ; ATB multiplier
  STA $3ADD,X     ; save ^
  PHA             ; store ^
  CPX #$08        ; monster entity
  BCC .character  ; branch if not ^
  LSR             ; multiplier / 2
  CLC             ; clear carry
  ADC $01,S       ; multiplier * 1.5
  STA $01,S       ; set ^
  LDA #$14        ; monster speed bonus (20)
  CLC             ; clear carry
  BRA .add_speed  ; branch
.character
  LDA #$33        ; character speed bonus (51)
.add_speed
  ADC $3B19,X     ; add entity speed
  XBA             ; store ^ plus bonus in B
  PLA             ; multiplier (*1.5 for monsters)
  JSR $4781       ; multiplier * (Speed + bonus)
  REP #$20        ; 16-bit A
  LSR #4          ; multiplier * (Speed + bonus) / 16
  STA $3AC8,X     ; save ATB increment size
  PLP             ; restore flags
  NOP #2          ; 2 bytes padding
  RTS

; ########################################################################
; SOS Equipment Activations

org $C20A6A : LDA #$23 ; update spell ID for SOS Shell
org $C20A78 : LDA #$22 ; update spell ID for SOS Safe

; ########################################################################
; Switch between Morph and Revert (freespace)

org $C20AE5 : RTS ; bypass all morph gauge handling

; ------------------------------------------------------------------------
; Helper for reflect removal via hit/miss

ReflectClear3:
  LDA $3E10,Y          ; status-to-clear-3
  ORA #$80             ; add "Reflect"
  STA $3E10,Y          ; update status-to-clear-3
  RTS

; ------------------------------------------------------------------------
; Helpers for Periodic Effects/Damage

Sap_Chk:
  LDA $11A7        ; Load special byte 3
  BIT #$0080       ; Test if bit 8 is set
  BNE Skip_Halving ; If it is, branch
  LDA $11A4        ; Else, restore displaced code at $C20D24 and return
  RTS

Skip_Halving:
  PLA              ; No longer need to RTS
  JMP DmgModInc    ; Jump back, skipping the damage halving instruction

Tick_Calc:
  PHA              ; store A (Max HP)
  LDA $3EF8,Y      ; current status-3
  AND #$0002       ; "Regen"
  BEQ .no_regen    ; branch if no ^
  SEP #$20         ; 8-bit A
  LDA $E8          ; Stamina
  XBA              ; save multiplier
  LDA $3B18,Y      ; Level
  JSR $4781        ; Stamina * Level
  REP #$20         ; 16-bit A
  LSR #4           ; Stamina * Level / 16
  STA $E8          ; save total so far
  PLA              ; restore A (Max HP)
  LDX #$40         ; divisor: 64
  JSR $4792        ; Max HP / 64
  CLC : ADC $E8    ; Max HP / 64 + Stamina * Level / 16
  BRA .end         ; branch to end

.no_regen
  SEP #$20         ; 8-bit A
  LDA $E8          ; Stamina
  LSR #3           ; Stamina / 8
  CLC : ADC #$10   ; Stamina / 8 + 16
  TAX              ; set divisor ^
  REP #$20         ; 16-bit A
  PLA              ; restore A (Max HP)
  JSR $4792        ; Max HP / (Stamina / 8 + 16)

.end
  PHA              ; store A
  SEP #$20         ; 8-bit A
  LDA $11A7        ; special byte 3
  ORA #$80         ; add "Periodic" flag (new flag in BNW)
  STA $11A7        ; update special byte 3 TODO: Use TSB instead
  REP #$20         ; 16-bit A
  PLA              ; restore A
  RTS

warnpc $C20B4A+1

; ########################################################################
; Damage Modification (per-target)

org $C20CA6 : SEP #$30        ; 8-bit A, X/Y
org $C20CB0 : JMP NewVariance ; hook for new vigor/stam-based variance
OldVariance:                  ; [label] for jump back
org $C20CBA : AfterVar:       ; [label] for after old variance handling
org $C20CC9 : BNE IgnoreDef   ; Defense ignoring now still modified by Morph
org $C20CE0 : LDA #$81        ; Set Golem's Defense to 128

; ------------------------------------------------------------------------
; Forces magic attacks to take defending targets into consideration
; Changes the back row defense boost from 50% damage reduction to 25%

org $C20CFF
  LDA $3AA1,Y     ; target special state flags
  BIT #$02        ; "Defending"
  BEQ .row        ; branch if not ^
  LSR $F1         ; dmg / 2
  ROR $F0         ; dmg / 4
.row
  PLP             ; restore flags
  BCC IgnoreDef   ; branch if not "Physical"
  BIT #$20        ; "Back Row"
  BEQ IgnoreDef   ; branch if not ^
  JSR Row_Dmg     ; else lower damage by 25%
  NOP

; ------------------------------------------------------------------------
; Change how morphed character damage is modified

IgnoreDef:
  LDA $3EF9,Y      ; target status byte 4
  BIT #$08         ; "Morphed"
  BEQ .done        ; branch if not ^
  LDA $3B40,Y      ; target stamina
  JSR MorphDmg     ; modify damage
.done

; ------------------------------------------------------------------------

org $C20D24 : JSR Sap_Chk ; Add hook to halve sap damage on party
org $C20D34 : DmgModInc:  ; [label] finish with damage increment

; ########################################################################
; Atlas Armet / Earring Boosts

org $C20D4B : JSR Sap_Chk2 : ASL ; replace "heal" skip with "sap/regen"
org $C20D6A : NOP #2             ; remove double earring support
org $C20D85 : AtlasEnd:          ; [label] end of routine

; ########################################################################
; Atma Weapon Damage (special effect)
;
; Partially rewritten as part of Synchysi's Atma Weapon changes.

org $C20E41
AtmaWpn:
  STA $E8         ; save (currHP / 256) + 1
  LDA $F0         ; damage so far
  JSR $47B7       ; 24-bit $E8 = damage * (former $E8)
  LDX $3C1D,Y     ; maxHP / 256
  INX             ; +1
  PHX             ; save (maxHP / 256 + 1)
  REP #$20        ; 16-bit A
  LDA $E8         ; damage * (currHP / 256 + 1)
  JSR $4792       ; divide by (maxHP / 256 + 1)
  STA $F0         ; update damage so far
  PLX             ; maxHP / 256 + 1
  PHY             ; save attacker index
  LDY $EA         ; overflow
  BEQ .exit       ; branch if no ^
  JSR AtmaOver    ; else, handle overlow
  NOP             ; [unused space]
.exit
  PLY             ; restore attacker index
warnpc $C20E61+1

; ########################################################################
; Equipment Check Function
;
; One portion of the equipment check function is included below, rewritten
; by Assassin to fix a bug that stopped the Genji Glove effect from reducing
; each weapon to 75% damage.

org $C20EF3 : JSL EsperBonuses : NOP ; hook to apply esper equip bonuses

org $C20F15
GengiCheckFunction:
  PHD               ; store direct page
  PEA $1100         ; new direct page on stack
  PLD               ; set new direct page $11xx

  LDX #$000A        ; initialize loop
.loop
  LDA $A1,X         ; high byte of stat
  BEQ .next         ; branch if no overflow
  ASL               ; C: negative stat
  LDA #$00          ; zero
  BCS .set          ; branch if negative
  DEC               ; else, use $FF
.set
  STA $A0,x         ; update capped stat
.next
  DEX #2            ; next stat index
  BPL .loop         ; loop till done
  LDX $CE           ; weapon function pointer
  LDA #$10          ; "Genji Glove Effect"
  TSB $CF           ; default to off ^
  JSR (WeapFuncs,X) ; run weapon function
  LDA $D7           ; N: "Boost Vigor" effect
  BPL .exit         ; branch if not ^
  REP #$20          ; 16-bit A
  LDA $A6           ; vigor stat
  LSR               ; / 2
  CLC : ADC $A6     ; add to full vigor
  STA $A6           ; update vigor value
.exit
  PLD               ; restore direct page
  PLP               ; restore flags
  PLB               ; restore bank
  PLY               ; restore Y
  PLX               ; restore X
  RTL

WeapFuncs:
  dw WeapChk_exit        ; shield/shield
  dw WeapChk_shieldleft  ; shield/weapon
  dw WeapChk_shieldright ; weapon/shield
  dw WeapChk_dual        ; weapon/weapon
  dw WeapChk_shieldleft  ; shield/bare
  dw WeapChk_exit        ; n/a
  dw WeapChk_leftonly    ; weapon/bare
  dw WeapChk_exit        ; n/a
  dw WeapChk_shieldright ; bare/shield
  dw WeapChk_rightonly   ; bare/weapon
  dw WeapChk_exit        ; n/a
  dw WeapChk_exit        ; n/a
  dw WeapChk_shieldright ; bare/bare

WeapChk:
.shieldleft
  JSR WeapChk_nogaunt  ; disable gauntlet effect
.rightonly
  STZ $AC           ; clear lefthand power
  RTS
.shieldright
  JSR WeapChk_nogaunt  ; disable gauntlet effect
.leftonly
  STZ $AD           ; clear righthand power
  RTS
.dual
  TRB $CF           ; allow genji glove effect
.nogaunt
  LDA #$40          ; "Gauntlet" effect
  TRB $DA           ; turn off left hand
  TRB $DB           ; turn off right hand
  RTS
  NOP #3
.exit
  RTS

; #########################################################################
; Load Item Data into Memory

; -------------------------------------------------------------------------
; Skip Imp Equipment handling
; Frees up some 16 bytes or so in between BRA

org $C2101C : BRA AfterImpEquip
org $C21031 : AfterImpEquip:

; #########################################################################
; Called Every Frame (NMI, Sort of)

; -------------------------------------------------------------------------
; nATB: pause time during animations (variable repurposed from Wait/Active)

org $C21124 : ORA $3A8F

; -------------------------------------------------------------------------
; Skip morph gauge decrement

org $C21143 : BRA BypassMorphCalc
org $C2114B : BypassMorphCalc:

; -------------------------------------------------------------------------
; Update ATB, check for "ATB Autofill"

org $C211C3 : JSR CheckCantrip ; C: whether ATB filled/overflowed

; #########################################################################
; Decrease Morph Timer (freespace)

; -------------------------------------------------------------------------
; Tools Helpers

org $C21211
Noiseblaster:
  LDA #$10            ; "Stamina Evade"
  STA $11A4           ; set ^ in attack flags
  ASL                 ; "Muddle" status
  STA $11AB           ; set ^ in attack status-2
  STZ $11A2           ; remove "Physical"
  RTS

; #########################################################################
; True Knight and Love Token
; Changes the True Knight effect to trigger with a Stamina / 192 chance
;   even if the target isn't in Near Fatal status.
; Modify which statuses prevent cover.
; Only allows back row targets for Stamina-based cover
; Removes support for monster guards

org $C2123B
TrueKnight:
  PHX                 ; store attacker index
  LDA $B2             ; attack flags
  BIT #$0002          ; "Ignore True Knight"
  BNE .exit           ; exit if ^
  LDA $B8             ; intended target (no True Knight for multi-target)
  JMP SmartCover      ; jump to new helper
.jmp
  LDX #$12            ; iterator for all entities
.loop
  LDA $3C57,X         ; potential guard relic flags 3 ($3C58,X)
  ASL #2              ; C: "True Knight"
  BCC .next           ; branch if no ^
  LDA $3018,X         ; potential guard bit
  BIT $F0             ; check bodyguard pool
  BEQ .next           ; branch if not in pool (on same team as target)
  JSR EvalKnight      ; validate guard, use if HP higher than current guard
.next
  DEX #2              ; decrement entity index iterator
  BPL .loop           ; check all characters and monsters
  LDA $F2             ; valid (tentative) bodyguard's HP
  BEQ .exit           ; exit if none ^
  JSR Intercept       ; make bodyguard intercept attack
.exit
  PLX                 ; return attacker index
  RTS

Intercept:
  LDX $F4             ; chosen bodyguard
  BMI .exit           ; exit if no bodyguard (null)
  CPY $F8             ; compare original target (Y) to current target ($F8)
  BNE .exit           ; exit if target has already been replaced (love token)
  STX $F8             ; update target to bodyguard's index
  STY $A8             ; save original (covered) target for animation
  LSR $A8             ; convert index for animation code (0..A)
  LDA $3018,X         ; bodyguard bit
  STA $B8             ; set bodyguard as new target
  SEP #$20            ; 8-bit A
  LDA $3AA1,X         ; bodyguard special state flags
  BIT #$02            ; "Defending"
  BEQ .noDef          ; exit if not ^
  JSR $0A41           ; else, remove "Defending" flag
  JSR $0A3C           ; and update sprite graphic
.noDef
  REP #$20            ; 16-bit A
.exit
  RTS

EvalKnight:
  LDA #$0020          ; "Back Row"
  BIT $3AA1,X         ; check ^ guard's special state flags
  BNE .exit           ; exit if guard ^
  LDA $3EE5,Y         ; target status-2
  LSR #2              ; C: "Near Fatal"
  BCS .skip           ; branch to auto-cover if target ^
  LDA $3AA1,Y         ; target's special state flags
  BIT #$0020          ; "Back Row"
  BEQ .exit           ; exit if target not ^
  LDA $3EE5,X         ; guard status-2
  LSR #2              ; "Near Fatal"
  BCS .exit           ; exit if guard ^
  SEP #$20            ; 8-bit A
  LDA #$C0            ; 192
  JSR $4B65           ; random(0..191)
  CMP $3B40,X         ; greater than guard stamina (max 128)
  REP #$20            ; 16-bit A
  BCS .exit           ; exit if Stamina too low
.skip                 ; Love Token enters here
  LDA $3AA0,X         ; guard special state flags
  LSR                 ; C: "Present and Alive"
  BCC .exit           ; exit if not ^
  LDA $3358,X         ; guard "Seized By" entity ($3359)
  BPL .exit           ; exit if ^
  LDA $336B,Y         ; target "Love Token Guard" ($336C)
  BMI .noLove         ; branch if no ^
  LDA $3EE4,X         ; guard status-1/status-2
  BIT #$A0DA          ; "Death", "Petrify", "Clear", "Zombie", "Magitek"
  BNE .exit           ; exit if any ^ > "Sleep", "Muddle"
  BRA .love           ; else continue
.noLove
  LDA $3EE4,X         ; guard status-1/status-2
  BIT #$B4DB          ; "Death", "Petrify", "Clear", "Zombie", "Magitek", "Dark",
  BNE .exit           ; exit if any ^ > , "Sleep", "Muddle", "Berserk", "Image"
.love
  LDA $3EF8,X         ; guard status-3/status-4
  BIT #$3211          ; "Dance", "Stop", "Freeze", "Chant", "Hide"
  BNE .exit           ; exit if any ^
  LDA $3018,X         ; guard bit
  TSB $A6             ; set ^ "Jump in Front of Target" animation
  LDA $3BF4,X         ; guard Current HP
  CMP $F2             ; compare to current guard HP
  BCC .exit           ; exit if lower than ^
  STA $F2             ; save new guard HP
  STX $F4             ; set new bodyguard
.exit
  RTS

; #########################################################################
; Process HP and MP Damage
;
; Never set "Death" from HP depletion on bosses. Instead, all boss deaths
; are handled via their AI script. This prevents a bug whereby some non-
; counterable sources of HP loss could bypass special boss death handling,
; messages, and animation.

org $C213A1 : JMP BossDeath

; #########################################################################
; Character/Monster Takes One Turn

org $C2140C : JSR XMagHelp ; hook to skip counterattacks if X-Magic pending

; #########################################################################
; Fight (command)

org $C215D1 : NOP #2   ; Enable desperation attacks at any time (nATB)
org $C21624 : LDA #$03 ; reduce Offering hits from 4 to 2

; #########################################################################
; Umaro's Attacks (Charge, Throw, Storm)

org $C2167F : JSR Tackle ; hook to set Tackle battle power to 255
org $C216D6 : LDA #$12 ; "Always Crit"/"Ignore Dmg Inc" if throwing Mog

; Sets the battle power of Umaro's Rage attack to 255 + gauntlet bonus
org $C216DA
  LDA #$40         ; "Two-Handed"
  TRB $B3          ; set ^
  BRA TackleSkip   ; skip helper below

Tackle:
  JSR $17C7        ; setup battle power and more
  LDA #$FF         ; 255
  STA $11A6        ; force max battle power
  RTS

TackleSkip: ; Destination of branch from above.

; #########################################################################
; Slot (command)

; Detaches Joker Doom (now Jackpot) from Dispatch's spell slot
org $C2172C
SlotCmd:
  BRA .skip      ; skip check for Jokerdoom
org $C21734 : .skip

; #########################################################################
; Dance (command)

org $C2177D : DanceCmd:       ; [label] for Moogle Charm entrypoint 1
org $C21785 : DanceCmd2:      ; [label] for Moogle Charm entrypoint 2
org $C2179D : JSR DanceChance ; use stamina to get dance chance

; #########################################################################
; Jump (command)
;
; Modified by dn's "Blind Jump Fix" patch to make "Blind" affect Jump
; command. Further modified by Synchysi so ensure row is ignored still.

org $C2180B : JSL C3_BlindJump : NOP ; helper routine in C3

; -------------------------------------------------------------------------
; Change the odds of additional bounces from the Dragon Horn effect.

org $C21823 : BPL EndJump
org $C2182B
  CMP #$40        ; random(256) >= $40
  BCS EndJump     ; branch if ^ (3/4 chance)
  INC $3A70       ; else, add second jump
EndJump:
  LDA $3EF9,X     ; status-4
  AND #$DF        ; omit "Hide"
  STA $3EF9,X     ; update status-4
  JMP $317B       ; execute hit

; #########################################################################
; Bushido (command)
;
; Synchysi's "Bushido" hack add support for "Gauntlet" effect to Bushido

org $C2185B
BushidoCommand:
  LDA $3C58,X    ; relic effects
  BIT #$08       ; "Two-handed"
  BEQ .end       ; branch if not ^
  LDA #$40       ; "Gauntlet"
  TRB $B3        ; set ^
  BRA .end       ; branch
org $C2187D
.end

; #########################################################################
; Item (command)

org $C21897 : NOP #3 ; remove instruction that ignores damage modification

; #########################################################################
; Item and Throw (commands)

org $C218C1 : JSR ItemMod ; hook to disable dmg mod for actual items

; -------------------------------------------------------------------------
; Don't clear "can target dead/hidden targets" from all magic-based tools
; and scrolls. This is mainly for the Defibrillator's benefit, though it
; could adversely affect the Mana Battery.

org $C218FF : NOP #2

; #########################################################################
; GP Rain (command)
;
; Modified by Synchysi's Blind patch

org $C21908 : JSR CoinHelp

; #########################################################################
; Code Pointers for Commands

org $C219ED : dw PreDanceCmd ; changed to add Moogle Charm hook

; #########################################################################
; AI Command Scripts

; -------------------------------------------------------------------------
; Script $F0

org $C21B3B : NOP #3 ; don't swap roulette with enemy roulette

; -------------------------------------------------------------------------
; Script $FC, command $06 (unsed to be HP Low Counter)
; Now used for both HP and MP low.

org $C21BB7
MPLowCounter:
  JSR $1D34
  BCC .exit
  TDC
  LDA $3A2F
  XBA
  REP #$20
  LSR
  CPX #$0E          ; is it command $07 - MP low counter?
  BCC .hp           ; branch if it's not (ie. it's $06 - HP low counter)
  CMP $3C08,Y       ; MP
  BRA .exit         ; TODO: RTS
.hp
  CMP $3BF4,Y       ; HP
.exit
  RTS

; -------------------------------------------------------------------------
; Script $FC, command $07 (used to be MP Low Counter)
; Now repurposed for extra "Hit at All" code path

MeleeParams:
  JML MeleeParamsLong
RTS_C2:
  RTS
warnpc $C21BD7+1

; -------------------------------------------------------------------------
; Script $FC, command $05

org $C21C70 : doCounter: ;[label] FC command $05 (Counter if damaged)

; -------------------------------------------------------------------------
; Script $FC, command pointers

org $C21D5F : dw MeleeParams  ; FC command $05 (hit at all)
org $C21D61 : dw MPLowCounter ; FC command $06 (HP low counter)
org $C21D63 : dw MPLowCounter ; FC command $07 (MP low counter)

; -------------------------------------------------------------------------
; Script $F1, Target $45 - Last Character or Enemy to Attack
; Previously, this targeting would include muddled monsters who recently
; attacked. Now, vindictive targeting is only used when the last entity
; who attacked the target is a character (0-3)

org $C22002 : CMP #$04 ; Vindictive Targeting Fix

; #########################################################################
; Hit Determination
;
; Modified by Synchysi's "Blind" patch
;   Have Blind status apply on skills with 255 hit rate and sets the
;   accuracy of a blinded attacker to 50%

org $C22215
HitMiss:
  LDA $11A2        ; attack flags
  BIT #$02         ; "Instant Death"
  BEQ .chk_vanish  ; branch if not ^
  LDA $3AA1,Y      ; special status flags
  BIT #$04         ; "Immune to Instant Death"
  BNE .go_dodge    ; branch if ^
.chk_vanish
  LDA $B3          ; attack flags
  BPL .chk_image   ; branch if "Ignore Vanish"
  LDA $3EE4,Y      ; status-1
  BIT #$10         ; "Vanish"
  BEQ .chk_image   ; branch if no ^
  LDA $11A4        ; attack flags
  ASL              ; N: "L.X Spell" [TODO: BNW changed to "Abort on Enemies"]
  BMI .rm_vanish   ; branch if ^
  LDA $11A2        ; attack flags
  LSR              ; C: "Physical"
  JMP .hit_miss    ; hit or miss based on ^
.rm_vanish
  LDA $3DFC,Y      ; status-to-clear-1
  ORA #$10         ; add "Vanish"
  STA $3DFC,Y      ; set ^ to be cleared
.chk_image
  LDA $11A3        ; attack flags
  BIT #$02         ; "Unreflectable"
  BNE .prep_doggy  ; branch if ^
  LDA $3EF8,Y      ; status-3
  BPL $0A          ; branch if no "Reflect" status
  REP #$20         ; 16-bit A
  LDA $3018,Y      ; target bit
  TSB $A6          ; add reflector for animation
  JMP ReflectClear ; handle reflect behavior
.prep_doggy

; Disable Dog Block if attack was Covered
org $C22282
  LDA $3EF9,Y         ; target status-4
  ASL                 ; N: "Dog Block"
  BPL .golem          ; branch if no ^
  JSR SkipDogBlock    ; C: 50% chance dog block (if no cover)

org $C22291 : .go_dodge
org $C22293 : .golem

org $C222A8           ; replace the old L? spells handling
  BIT #$10            ; "Stamina Evasion"
  BEQ EvadeChk        ; branch if not ^
  JSR StamEvd         ; else, run the stamina check
  BCS .dodge          ; branch if stam check succeeded
  BRA EvadeChk        ; else branch to normal hit determination

org $C222B3 : .hit_miss
org $C222B5 : .dodge
org $C222D1 : .miss

org $C222EC
StamTest:
  LDA $11A7           ; special attack byte 3
  BIT #$04            ; "Stamina Attack"
  BEQ NoStam          ; branch if not ^
  LDA $3B40,X         ; else load Stamina
  RTS
NoStam:
  LDA $3B41,X         ; Magic Power
  RTS

org $C222FB : EvadeChk:

org $C22306
  JSR BlindHelp
  BRA .skip_ahead
org $C22315 : .skip_ahead

; Terii Senshi evasion bugfix, with modification to Image removal
org $C2232C
  BEQ .no_img       ; Branch if the target does not have Image status
  JSR $4B5A         ; random(255)
  CMP #$56          ; 33% chance to clear Image status
  BCS HitMiss_miss  ; branch if not ^
  LDA $3DFD,Y       ; status-to-clear-2
  ORA #$04          ; add "Image"
  STA $3DFD,Y       ; update status-to-clear-2
  BRA HitMiss_miss  ; branch to miss
warnpc $C2233F+1
org $C2233F
.magic_evd_fork
  LDA $3B55,Y       ; 255 - (MBlock *2) + 1
  PHA               ; store hitrate
  BRA HitCalc       ; branch to calculate
.no_img
  JSR HalveEvasion  ; get Evasion (halved in covering)

warnpc $C22348+1
org $C22348
  PHA          ; store hitrate
  NOP

org $C2234A
BlindPatch2:
  BRA .skip_ahead
org $C22358
.skip_ahead
  LDA $3C58,Y       ; [moved] relic effects

org $C2235E : PEA $0004 ; remove evasion penalty from Rerise
org $C22372 : BRA HitCalc ; skip evasion bonuses from all statuses
org $C22388 : HitCalc:

; ------------------------------------------------------------------------
; Dice Helper in freespace from old Stamina Evasion routine

org $C2239C
DiceHelp:
  LDA $3A70         ; which hand is striking (odd = right; even = left)
  LSR               ; C: Righthand
  BCC .lefthand     ; branch if not ^
  LDA $3B7C,Y       ; righthand hitrate (contains # of dice)
  BRA .exit         ; finish up
.lefthand
  LDA $3B7D,Y       ; lefthand hitrate (contains # of dice)
.exit
  RTS

; #########################################################################
; Initialize Many Things at Battle Start

; ------------------------------------------------------------------------
; Always set "Wait" mode variable (nATB)

org $C2247A : STZ $3A8F : NOP #4

; #########################################################################
; Initialize Characters

; -------------------------------------------------------------------------
; Add hook to condense spell lists

org $C2256D : JSR condenseSpellLists

; #########################################################################
; Initialize ATB Timers
;
; Partially rewritten by Seibaby's "ATB Start" patch, which alters the starting
; ATB formula. See included notes:
;   It reduces randomness and increases Speed's contribution to how
;   quickly characters (and enemies) get their first turn.
;   The original formula was:
;     ([Speed..(Speed * 2 - 1)] + [(0..9) * 8] + [G * 16]) * 256 / 65535
;   Where G = (10 - Number of entities in battle)
;   The new formula is:
;     ([(Speed * 2)..(Speed * 3 + 29)] + [(0..9) * 4] + G) * 256 / 65535

org $C22575
InitializeATBTimers:
  PHP            ; store flags
  STZ $F3        ; zero General Incrementor
  LDY #$12       ; entity loop
.ent_loop
  LDA $3AA0,Y    ; entity state flags
  LSR            ; C: "Present and Alive"
  BCS .next_ent  ; branch if ^
  CLC            ; clear carry (prep addition)
  LDA #$01       ; lowered from vanilla
  ADC $F3        ; add to general incrementor
  STA $F3        ; update ^ for missing entities
.next_ent
  DEY #2         ; next entity
  BPL .ent_loop  ; loop for all 10 characters and monsters
  REP #$20       ; 16-bit A
  LDA #$03FF     ; 10 bits set, 10 possible entities in battle
  STA $F0        ; save bitmask ^
  LDY #$12       ; entity loop
.loop
  LDA $F0        ; entity bitmask
  JSR $522A      ; randomly choose one entity
  TRB $F0        ; clear from remaining bitmask
  JSR $51F0      ; X: bit number of chosen bit
  SEP #$20       ; 8-bit A
  TXA            ; chosen bit number
  ASL #2         ; x4
  NOP            ; [unused space]
  STA $F2        ; save [0..9] * 4 in our Specific Incrementor
                 ; the result is that each entity is randomly
                 ; assigned a different value for $F2:
                 ; 0, 4, 8, 12, 16, 20, 24, 28, 32, 36
  LDA $3219,Y    ; ATB Timer high byte
  INC            ; check for null (FF)
  BNE .next      ; skip to next entity if not ^
  LDA $3EE1      ; FF in every case, except for final 4-tier battle
  INC            ; check for null
  BNE .next      ; skip to next entity if not ^
  LDX $201F      ; encounter type.  0=front, 1=back, 2=pincer, 3=side
  LDA $3018,Y    ; entity unique bit
  BIT $3A40      ; character acting as enemy?
  BNE .enemy     ; branch if ^
  CPY #$08       ; in monster range
  BCS .enemy     ; branch if ^
  LDA $B0        ; battle flags
  ASL            ; N: "Preemptive"
  BMI .next      ; branch if ^
  DEX            ; decrement encounter type
  BMI .front     ; branch if front attack
  DEX #2         ; decrement encounter type
  BEQ .next      ; branch if side attack
  LDA #$80       ; fixed starting ATB for "Pincer"
  BRA .set_atb   ; branch to set ^
.enemy
  LDA $B0        ; battle flags
  ASL            ; N: "Preemptive"
  BMI .min_atb   ; branch if ^
  CPX #$03       ; check "Side Attack" encounter type
  BNE .front     ; branch if not ^
.min_atb
  LDA #$01       ; minimum ATB value
  BRA .set_inc   ; set top byte of ATB timer to 2
.front
  LDA $3B19,Y    ; speed
  ADC #$1E       ; add 30
  JSR $4B65      ; random(speed + 30)
  JMP ATBInitHelp
.after_help
  ADC $F2        ; add entity's Specific Incrementor, a
  BCS .max_atb   ; branch if exceeded 255
  ADC $F3        ; add General Incrementor (10 - number of valid entities)
  BCC .set_inc   ; branch if byte didn't exceed 255
.max_atb
  LDA #$FF       ; max ATB (prior to pending turn)
.set_inc
  INC            ; increment ATB + 1
  BNE .set_atb   ; branch if no overflow
  DEC            ; else, decrement
.set_atb
  STA $3219,Y    ; save top byte of ATB timer
.next
  REP #$20       ; 16-bit A
  DEY #2         ; next entity index
  BPL .loop      ; loop for all 10 possible entities
  PLP            ; restore flags
  RTS
warnpc $C22602+1

; #########################################################################
; Death and Poison Immunity Setup/Handling
;
; Modified by dn's "Stop Block" hack to give Stop immunity with Death

org $c2265b : JSR StopBlock ; Add hook to give stop immunity

; #########################################################################
; Load Command and Subcommand Data

; -------------------------------------------------------------------------
; Throw and Tools
; Add Defibrillator and Mana Battery to tools that route through spell IDs

org $C22708
ToolSkeanSpells:
  LDX #$06                 ; iterator for list of Spells as Tools/Skeans
  CMP Tool_Data_1,X        ; check if this tool matches ^
  BNE .skip                ; exit if not ^
  SBC Tool_Data_2,X        ; else, get spell number TODO: Just LDA
org $C22716 : .skip

; #########################################################################
; Load Character Equipment Properties

org $C22872
  BRA NoMog    ; skip turning Moogle Suit wearing into Moogle

; -------------------------------------------------------------------------
; Atlas Armlet / Earring and Sap helper in freespace

Sap_Chk2:
  LDA $B5         ; command ID
  CMP #$01        ; "Item"
  BEQ .nope       ; exit if ^
  LDA $11A7       ; Load special byte 3 (has Periodic flag instead of Heal)
  RTS
.nope
  PLA : PLA       ; clear JSR return offset
  JMP AtlasEnd    ; jump back instead (to end of routine)

; -------------------------------------------------------------------------

org $C22883 : NoMog:
org $C228C1 : JSR GauRageStatuses2

; #########################################################################
; Load Magic/Vigor/Stamina Stat and Level

org $C22955
  LDA $3B2C,X     ; Vigor * 2
  BCS Phys_Atk    ; branch if physical attack (carry set earlier)
  JSR StamTest    ; else, check to see if it should be stamina-based
Phys_Atk:

; #########################################################################
; Load Weapon Properties
;
; Synchysi's Atma Weapon patch modifies the special effect handling
; Synchysi's Blind patch changes how "Cannot Miss" effect is handled

org $C2299F
LoadWeaponProperties:
  PHP               ; store flags
  LDA $3B2C,X       ; attacker vigor (x2)
  STA $11AE         ; save attack stat ^
  JSR $2C21         ; put attacker level (or sketcher) in $11AF
  LDA $B6           ; attack type
  CMP #$EF          ; "Monster Special"
  BNE .get_hand     ; branch if not ^
  LDA #$06          ; message ID to display special attack name
  STA $3412         ; set message ID ^
.get_hand
  PLP               ; restore flags
  PHX               ; store attacker index
  ROR $B6           ; N: "Left Handed" (from carry at start of routine)
  BPL .weapon_fx    ; branch if not ^
  INX               ; else, point to left hand data
.weapon_fx
  JSR SketchChk     ; get battle power (handles sketched monsters)
  STA $11A6         ; save ^
  LDA #$62          ; "Always Crit", "Gauntlet", "Respect Row"
  TSB $B3           ; turn off ^
  LDA $3BA4,X       ; weapon flags
  AND #$60          ; "Ignore Row", "Gauntlet"
  EOR #$20          ; "Ignore Row" -> "Respect Row"
  TRB $B3           ; set attack flags ^
  LDA $3B90,X       ; weapon element
  STA $11A1         ; set ^
  LDA $3B7C,X       ; weapon hitrate
  STA $11A8         ; set ^
  LDA $3D34,X       ; weapon spellcast
  STA $3A89         ; set ^
  LDA $3CBC,X       ; "Special Effect"
  AND #$F0          ; isolate ^
  LSR #3            ; shift down to x2 index
  JSR AtmaStat      ; set special effect and handle Atma damage stat
  LDA $3CA8,X       ; weapon ID
  INC               ; +1
  STA $B7           ; set graphic index
  PLX               ; restore attacker index (no more hand-based inc)
  LDA $3C45,X       ; relic effects
  BIT #$10          ; "Cannot Miss"
  BEQ .chk_offering ; branch if no ^
  LDA #$FF          ; max
  STA $11A8         ; set hit rate to max (can be affected by blind now)
.chk_offering
  LDA $3C58,X       ; relic effects
  LSR               ; C: "X-Fight" (Daryl's Soul)
  BCC .exit         ; branch if no ^
  LDA #$02          ; "No Critical nor True Knight"
  TSB $B2           ; set ^
.exit
  RTS

; #########################################################################
; Load Item Properties

; ------------------------------------------------------------------------
; Save space to allow clearing some default targeting for items, so things
; like Tonics can automatically retarget if the target dies.

org $C22A44
  LDA #$20      ; "Cannot dodge"
  STA $11A4     ; set ^
  INC           ; $21
  STA $11A2     ; set "Ignore Defense"/"Physical"
  INC           ; $22
  STA $11A3     ; set "Retarget if Dead"/"Unreflectable"
  STZ $BA       ; clear "Can Target Dead" and "No Retarget if Dead"

; ------------------------------------------------------------------------

org $C22A71 : JSR ThrowProps ; hook to load weapon properties with throw

; ------------------------------------------------------------------------
; Modified as part of "Abort on Enemies" patch to prevent most items and
; rods from being targeted at enemies. (Synchysi)

org $C22A78 : JSR ItemAbortEnemy ; Set "abort-on-enemies" flag for many items

; ------------------------------------------------------------------------
; Repurpose "Reverse Dmg on Undead" flag on items to indicate that the
; item can target dead entities. In BNW, no items can damage the undead,
; the old handling wasn't needed.

org $C22ACD
  LDA #$08
  TSB $BA : NOP

; ------------------------------------------------------------------------
; Tools Jump Table and Routines

org $C22B1A
  dw Noiseblaster      ; now uses Stamina Evade
  dw ToolsRTS          ; Bio Blaster - RTS
  dw ToolsRTS          ; Flash - RTS
  dw Chainsaw1         ; now always does dmg if target immune to death
  dw ToolsRTS          ; Defibrillator - RTS (old Debilitator)
  dw Drill             ; Add "Sap" to status effects
  dw ToolsRTS          ; Mana Battery - RTS (old Air Anchor)
  dw Autocrossbow      ; check event bit for levelled up ACB

Chainsaw1:
  JSR $4B5A            ; random(0..256)
  AND #$03             ; 75% chance of 0
  BNE Drill_Saw        ; branch if ^ (no hockey mask)
  LDA #$08             ; "Hockey Mask" animation
  STA $B6              ; set ^
  LDA #$AC             ; new "Chainsaw" special effect
  STA $11A9            ; set ^ to handle instant death immunity

Drill_Saw:             ; [fork]
  LDA #$20             ; "Ignore Defense"
  TSB $11A2            ; set ^
  LSR                  ; "Respect Row"
  TSB $11A7            ; set ^
  RTS

Drill:
  LDA #$40             ; "Sap"
  STA $11AB            ; add ^ to attack status-2
  BRA Drill_Saw        ; branch to set flags

Autocrossbow:
  LDA #$40             ; "No Split Damage"
  TSB $11A2            ; set ^
  LDA $1EBB            ; event byte (1D8 - 1DF) - "Rare items"
  BIT #$10             ; bit 1DC - "Schematics"
  BEQ .exit            ; exit if no ^
  LDA #$E1             ; else, battle power 225
  STA $11A6            ; set ^
  LDA #$FF             ; max hitrate (100%)
  STA $11A8            ; set ^
.exit
  RTS

org $C22B2F : ToolsRTS:


; #########################################################################
; Damage Formulas

; -------------------------------------------------------------------------
; Magical Damage Formula

org $C22B9A : JMP Wpn_Chk ; add hook to modify spellproc dmg

; -------------------------------------------------------------------------
; Physical Damage Rewrite
; New physical damage formula for characters only, plus handling for
; Bushido leveraging equipped weapon battle power.
; Also modifies Offering, Genji Glove, and Gauntlet multipliers.

org $C22BB3
PhysDmg:
  CPX #$08        ; attacker is a monster
  BCS .enemy      ; branch if ^
  JMP PlayerPhys  ; else, use player formula
.enemy
  ASL #2          ; BatPwr * 4
  ADC #$003C      ; +60 (instead of enemy vigor)
  SEP #$20        ; 8-bit A
  JSR $47B7       ; Level * ((BatPwr * 4) + 60)
  LDA $E8         ; load product ^
  STA $EA         ; store low byte for later
  PLA             ; restore A (Level)
  STA $E8         ; save multiplier ^
  REP #$20        ; 16-bit A
  LDA $E9         ; Level * ModifiedBatPwr (big endian)
  XBA             ; get ^ little endian
  JSR $47B7       ; multiply by level / 256
  STA $11B0       ; save damage
  PLP             ; restore flags
  RTS

org $C22BDA
PhysDmgJump:
  SEP #$20        ; 8-bit A
  LDA $B5         ; command ID
  CMP #$07        ; "Bushido" or higher
  REP #$20        ; 16-bit A
  BCS .exit       ; branch if ^ (not Fight/Item/Magic/Morph/Revert/Steal/Mug)
  LDA $3C58,X     ; relic flags
  LSR             ; C: "Offering"
  BCC .dual       ; branch if not ^
  JSR DmgQtr      ; else, damage - 25%
.dual
  BIT #$0008      ; "Genji Glove" (shifted from $10)
  BEQ .exit       ; branch if not ^
  JSR DmgQtr      ; else, damage - 25%
.exit
  PLP             ; restore flags
  RTS

DmgQtr:
  PHA             ; store A (relic flags)
  LDA $11B0       ; damage
  LSR #2          ; damage / 4
  EOR #$FFFF      ; toggle bits
  SEC             ; essentially * -1
  ADC $11B0       ; add -25%
  STA $11B0       ; update damage (75%)
  PLA             ; restore A (relic flags)
  RTS

; -------------------------------------------------------------------------
; Chainsaw helper (freespace from old Physical Formula)

org $C22C09           
Chainsaw2:
  LDA $3AA1,Y      ; special status flags
  BIT #$04         ; "Immune to instant death"
  BNE .exit        ; exit if ^
  STZ $11A6        ; zero battle power - this is instant death, no need for damage.
  LDA #$80         ; "Death"
  ORA $3DD4,Y      ; add ^ status-to-set TODO: Should this add to 11AA instead?
  STA $3DD4,Y      ; update ^
  LDA #$10         ; "Stamina Evade"
  STA $11A4        ; set ^
.exit
  RTS

; #########################################################################
; Get Sketcher Level

org $C22C25 : JSR SketchMag  ; Interrupting a check to look for a sketcher

; #########################################################################k
; Load Monster Stats

org $C22CE9
MonsterStamina:
  NOP
  CMP #$20        ; compares monster maxHP hibyte to 32
  BCC .add        ; branch if less than 31
  LDA #$1E        ; else, set stamina equal to 30
.add
  ADC #$01        ; Add 1 to stamina (or 2 if the carry is set from above)

org $C22D30 : NOP #3    ; remove 1.5x spell power from enemies
org $C22D65 : ADC #$18  ; Add 24 to enemy's vigor, giving them a range of 24-30

; #########################################################################
; Load Monster Properties

org $C22E17 : JSR GauRageStatuses

; #########################################################################
; Battle Initialization / Special Event Setup
;
; Portion rewritten to save space and allow for initialization of aura
; cycling variable(s).

org $C2307D
LaterBattleInit:
  PHX                   ; preserve party member index
  LDA $FE               ; get row
  STA $3AA1,X           ; save to special properties
  LDA $3ED9,X           ; preserve special sprite
  PHA                   ; save special sprite
  LDA $05,S             ; get loop variable
  STA $3ED9,X           ; save roster position
  TDC                   ; zero A/B
  TXA                   ; character slot index
  ASL #4                ; x16 (slot x32)
  TAX                   ; index it
  LDA #$06              ; 7-iteration loop
  STA $FE               ; initialize loop counter
  PHY                   ; preserve character SRAM data offset
.loop
  LDA $1601,Y           ; get normal sprite & name characters
  STA $2EAE,X           ; store to display variables
  INX                   ; next destination data
  INY                   ; next source data
  DEC $FE               ; decrement interator
  BPL .loop             ; loop to copy sprite and name
  PLY                   ; restore character SRAM data offset
  PLA                   ; restore special sprite
  CMP #$FF              ; is special sprite null
  BEQ .init_aura        ; branch if ^
  STA.w $2EAE-7,X       ; else, overwrite battle sprite (offset by loop above)
.init_aura
  LDA #$81              ; "Reflect", "WaitBit"
  STA.w !aura_cycle-7,X ; initialize aura to ^ (offset by loop above)
  LDA $03,S             ; character ID
  STA.w $2EC6-7,X       ; save it (offset by loop above)
  CMP #$0E              ; is it Banon or higher?
  REP #$20              ; 16-bit A
  TAX                   ; move to X
padbyte $EA
pad $C230BC
warnpc $C230BC+1

; #########################################################################
; Entity Executes One Hit

; -------------------------------------------------------------------------
; Skip muting all magic except the Imp spell for Imps

org $C2320D : BRA SkipImpMute
org $C23225 : SkipImpMute:

; #########################################################################
; Combat Routine

org $C2334B : JSR SpecialAttStam    ; handle enemy special attacks stamina flag
org $C2336B : NOP #2                ; remove second INC $BC from morph (+50%)
org $C23392
  LDA $11A7                         ; Special byte 3
  JSR Row_Chk                       ; check for row respecting flags (eg. Aurabolt)
org $C233A3 : JSR Imp_Nerf          ; add hook for new Imp damage nerf routine
org $C233BA : JSR SetTarget         ; Enable target's counterattack, even if we miss
org $C233EA : BRA NoImpCrit         ; skip Imp critical handling
org $C233F2 : NoImpCrit:            ; label for BRA above
org $C2343C : JSR CounterMiss : NOP ; Set counter variables early TODO [overwritten]
org $C23447 : NOP #7                ; remove back-attack damage increment

; #########################################################################
; Runic Function
; Set Runicked attacks to Ignore Clear

org $C2357E
  LDA #$2182       ; "Concern MP", "Unreflectable", "Unblockable", "Healing"
  STA $11A3        ; set ^
  LDA #$8040       ; "Runic Animation", "Ignore Clear"
  TRB $B2          ; set ^ ($B3, too)
  SEP #$20         ; 8-bit A
  LDA #$60         ; "Ignore Defense", "No Split Damage"
  STA $11A2        ; set ^
  TDC              ; clear A/B
  LDA $11A5        ; MP cost of spell
  JSR $4792        ; divide ^ by number of Runickers
  STA $11A6        ; save as Battle Power (fixed dmg/healing)
  JSR $385E        ; set level, magic power to 0
  JSR RunicHelper  ; ignore elemental effects and +25% dmg flags
  LDA #$04         ; "Don't Retarget if Target Invalid"
  STA $BA          ; set targeting flag ^
  DEC A            ; "Text on Hit", "Miss if Status not Set" (will be cleared)

; #########################################################################
; Initialize Variables for Counterattack Purposes
; New var $327D contains flags for physical, respects row, and MP dmg

org $C235E9 : JSL InitAttackVars ; hook to track more counterattack vars

; #########################################################################
; Weapon "Addition" Magic

org $C23651 : JSR RandomCast : NOP #2 ; add hook for better procrate

; #########################################################################
; Prepare Attack Name to Display

org $C236D2 : dw $3687 ; JokerDoom hook (was $36A6 - now freespace)

; #########################################################################
; Increment Damage Function ($BC)
; Rewritten to allow damage increments with defense-ignoring attacks

org $C2370B
IncDmgFunc:
  PHY             ; store Y
  LDY $BC         ; increment count
  BEQ .exit       ; exit if zero ^
  PHA             ; store damage
  SEP #$20        ; 8-bit A
  LDA $11A7       ; attack flags 4 ($20="No Increments")
  AND $11A2       ; and attack flags 1 ($20="Ignore Def")
  ASL #3          ; C: Ignore Def and No Increments on Ignor Def
  REP #$20        ; 16-bit A
  PLA             ; restore damage
  BCS .exit       ; exit if ignore increments
  STA $EE         ; else, store damage in scratch
  LSR $EE         ; damage / 2
.loop
  CLC             ; clear carry
  ADC $EE         ; add 50% damage
  BCC .no_cap     ; branch if no overflow
  TDC : DEC       ; else, use max dmg $FFFF
.no_cap
  DEY             ; decrement increment count
  BNE .loop       ; loop till all increments done
  STY $BC         ; zero increment count
.exit
  PLY             ; restore Y
  RTS

; #########################################################################
; Pick Random Esper
; Adds Odin and Raiden to Bar-Bar-Bar results, and removes Phoenix

org $C237DC
  LDA #$1A        ; increase range of espers to choose from
  JSR $4B65       ; select random esper from range
  CLC             ; clear carry
  ADC #$36        ; add offset to esper spells
  RTS

; #########################################################################
; Weapon Addition Magic

org $C2380F
SpellProc:
  BEQ .normal           ; improve silly branching logic from vanilla
  JSR Net_Target        ; hook to bypass "Randomize Targets" for "Net"
  BRA .cannot_miss      ; improve silly branching logic from vanilla
.normal

org $C2381D :  JSL AutoCritProcs ; power-up crit doom to x-zone, multitarget quartr
org $C2382D : .cannot_miss

; #########################################################################
; Maneater Effect (now on Butterfly)

org $C238FD : ManRTS: ; [label] reusable RTS

; #########################################################################
; Hawk Eye Effect
; Increases the incrementer for "randomly thrown" weapons to 2

org $C23905
  INC $BC         ; +50% more dmg (now +100%)
  LDA $3EF9,Y     ; target status-4
  BPL .throw      ; finish up if no "Float"
  LDA $B5         ; command ID
  CMP #$00        ; is it "Fight" [TODO: CMP not necessary]
  BNE ManRTS      ; exit if not ^ (Jump/Steal)

org $C23916 : .throw ; [label] set "Throw" animation for "Critical"

; #########################################################################
; Stone Effect (now freespace)
; Damage = rand(250..500)

org $C23922
NewLife:
  TDC             ; A = $0000
  PHA             ; Push to stack
  LDA #$FB        ; 251
  JSR $4B65       ; Random number 0..250
  PHA             ; Push rand(0..250)
  JSR $3F54       ; Pearl Wind (sets 16-bit A, clears Carry, sets no split loss and ITD)
  PLA             ; Pull 16-bit rand(0..250)
  ADC #$00FA      ; Carry is clear, so add 250
  JMP StoreDamage ; use end of Step Mine effect to store damage and RTS

; #########################################################################
; Discord Effect (now freespace)

org $C23978
Rage:
  PHA         ; store A
  JSR $4B5A   ; 0-255 RNG
  CMP #$AB    ; Carry clear 2/3 chance (use common rage move)
  PLA         ; restore A
  RTS

; #########################################################################
; Steal Effect (rewritten)
; Speed now affects rare steal chance (Speed / 256)

org $C2399E
StealFunction:
  LDA $05,S       ; attacker index
  TAX             ; index it
  LDA #$01        ; "Doesn't have anything!"
  STA $3401       ; set message ID ^
  CPX #$08        ; is attacker a monster
  BCS enemySteal  ; branch if ^
  REP #$20        ; 16-bit A
  LDA $3308,Y     ; target's stealable items
  INC A           ; null check
  SEP #$20        ; 8-bit A
  BEQ failSteal   ; branch if null item (no item)
  INC $3401       ; set message ID "Couldn't steal!!"
  LDA $3B19,X     ; attacker speed
  ASL A           ; x2
  BCS .success    ; always steal if speed >= 128
  ADC #$70        ; +112
  BCS .success    ; steal if > 255
  STA $EE         ; save steal chance
  JSR $4B5A       ; random(256)
  BRA .skip       ; branch past unused code
  NOP #11         ; unused code
.skip
  CMP $EE         ; is random >= steal chance
  BCS failSteal   ; branch if ^ (fail)
.success
  PHY             ; store target index
  JSR $4B5A       ; random(256)
  CMP $3B19,X     ; is random >= speed stat
  BCC .rare       ; branch if not ^ (rare steal)
  INY             ; check the 2nd [Common] stealable slot
.rare
  LDA $3308,Y     ; target's stolen item
  PLY             ; restore target index (if modified)
  CMP #$FF        ; null?
  BEQ failSteal   ; branch if ^ (fail)
  STA $2F35       ; save stolen item ID for message template
  STA $32F4,X     ; store in "Acquired Item"
  JSR SetCantrip  ; hook to set "ATB Autofill" flag
  TSB $3A8C       ; flag ^ to process reserve item at end of turn
  LDA #$FF        ; "null"
  STA $3308,Y     ; remove stealable item
  STA $3309,Y     ; in both slots
  INC $3401       ; set message ID "Stole #whatever"
  RTS

org $C23A01 : failSteal:
org $C23A09 : enemySteal:

; #########################################################################
; Metamorph Special Effect (now freespace)

org $C23A3C
RandomCast:
  JSR $4B5A       ; random(256)
  PHA             ; store ^
  LDA $3C58,X     ; relic effects byte 2
  BIT #$80        ; "High Proc Rate"
  BEQ .nope       ; branch if no ^
  PLA             ; restore random(256)
  CMP #$80        ; 1/2 chance of activating random weapon cast
  RTS
.nope
  PLA             ; restore random(256)
  CMP #$40        ; 1/4 chance of activating random weapon cast
  RTS

; -------------------------------------------------------------------------
; Helper for Magic Damage modification for Spellprocs (Windslash/Aero)
; No possibility for regular dmg; only Two-Handed or Dual-Wield

Wpn_Chk:
  SEP #$20        ; [displaced] 8-bit A
  LDA $11A7       ; attack flags
  BIT #$08        ; "Respect Weapon Flags" (new BNW flag)
  BEQ .exit       ; branch if not ^
  REP #$20        ; 16-bit A
  LDA $B2         ; attack flags ($B3)
  BIT #$4000      ; "Two-Handed"
  BNE .dual       ; branch if not ^
  LDA $11B0       ; damage
  LSR             ; damage / 2
  ADC $11B0       ; damage * 150%
  BRA .set_dmg    ; branch to finish
.dual
  LDA $11B0       ; damage
  LSR #2          ; damage / 4
  EOR #$FFFF      ; * -1 (minus 1)
  SEC             ; set carry (for true * -1)
  ADC $11B0       ; damage * 75%
.set_dmg
  STA $11B0       ; set new damage
  SEP #$20        ; [displaced] 8-bit A
.exit
  RTS

; #########################################################################
; Debilitator Special Effect (now freespace)

; -------------------------------------------------------------------------
;  Helper for Moogle Charm "fall like a stone" effect

org $C23A9E
Charm_Chk:
  XBA              ; command ID
  CMP #$16         ; "Jump"
  BNE .no_jump     ; branch if not ^
  LDA $3C59,X      ; relic flags
  BIT #$20         ; "Moogle Charm"
  BEQ .no_charm    ; branch if not ^
  LDA #$0E         ; shorter wait time
  BRA .no_jump     ; and finish
.no_charm
  LDA #$16         ; longer wait time
.no_jump
  CMP #$1E         ; [displaced] is command > 1E
  RTS

; -------------------------------------------------------------------------
;  Helper for Dance chance based on Stamina

DanceChance:
  PHA              ; store A
  JSR $4B5A        ; random(256)
  PHA              ; store ^
  LDA $3B40,Y      ; dancer's stamina
  ASL              ; x2
  ADC #$60         ; (Stam * 2) + 96
  BCS .exit        ; auto-success if overflow
  CMP $01,S        ; C: success rate >= random(256)
.exit
  PLA              ; clean up stack
  PLA              ; restore A
  RTS

; #########################################################################
; Control Effect (largely unused)

; -------------------------------------------------------------------------
; Control failure fork, reused by multiple special effects
; Add hook to clear any status-to-set from missed special effect

org $C23B1D : JSR Clear_Status

; #########################################################################
; Leap Effect (rewritten)

org $C23B71
  LDA $3A76      ; present and living character count
  CMP #$02       ; at least 2
  BCC .miss      ; branch if not ^ (solo party member cannot leap)
  LDA $05,S      ; attacker index
  TAX            ; index it
  LDA $3DE9,X    ; status-to-set (byte 4)
  ORA #$20       ; "Hide"
  STA $3DE9,X    ; add ^ to-set (byte 4)
  LDA $3018,X    ; attacker bit
  TSB $2F4C      ; set to be removed from battlefield
  JSR $4A07      ; learn rages
  RTS
.miss
  LDA #$05       ; "Cannot Leap" message ID
  JMP $3B18      ; miss with messasge ^

checkLeap:
  LDA $2F4B      ; formation flags
  EOR #$02       ; invert bit to mean "Leapable Formation"
  RTS

; #########################################################################
; Rippler Effect (now freespace)

org $C23C04
StopBlock:
  PHA             ; save A
  LDA $3330,X     ; vulnerable status-3
  AND #$EF        ; remove "Stop"
  STA $3330,X     ; update vulnerable status-3
  PLA             ; restore A
  ORA #$80        ; [displaced]
  XBA             ; [displaced]
  RTS 

org $C23C22
ShadowChk:
  LDA $1E94       ; one event byte
  AND #$08        ; "Shadow Died"
  BNE .relm       ; branch if ^
  LDA #$FC        ; else load spell ID 252
  RTS
.relm
  LDA #$FD        ; load spell ID 253
  RTS

org $C23C2F
Tool_Data_1:
  db $A4,$A5,$A7,$A9,$AB,$AC,$AD ; Data - filched from $C22778 to add two tools.
Tool_Data_2:
  db $27,$27,$0D,$0E,$5A,$5A,$5A ; Data - filched from $C2277D to add two tools.

org $C23C3D
CoinHelp:
  JSR $298A       ; [moved] load command data
  STZ $11A4       ; clear "Cannot Miss" (no others set)
  LDA #$FF        ; max
  STA $11A8       ; set max hitrate (now affected by blind)
  RTS

; #########################################################################
; Scan Special Effect (per-target)
;
; Modified by dn's "Scan Status" patch to skip the "Cannot Scan" check and
; message preparation. This is done so the new "Status" and "Weakness" scan
; results are available during boss fights. "Cannot Scan" flag means "Boss".

org $C23C5B
ScanEffect:
  TYX
  LDA #$27
  STZ $341A        ; prevent enemies from countering scan
  JMP $4E91        ; queue command in special action queue
padbyte $FF
pad $C23C6E
warnpc $C23C6E+1

; #########################################################################
; Air Anchor Routine (now freespace)

org $C23C78
ChangeShld:
  LDA #$01         ; "shield uncursed"
  TSB $F0          ; set ^ flag
  LDA #$67         ; "Paladin Shield" ID
  STA $161F,X      ; replace equipped shield
  RTS

PreDanceCmd:
  LDA $3C59,Y      ; relic flags
  BIT #$20         ; "Moogle Charm"
  BNE .exit        ; branch if ^
  JMP DanceCmd     ; else, do full Dance cmd
.exit
  JMP DanceCmd2    ; do Dance cmd w/o setting Dance status
warnpc $C23C90+1

; #########################################################################
; Pep Up Routine (now freespace)
; Helper for "ATB Autofill" flag, for Steal

org $C23CB8
SetCantrip:
  LDA $3AA1,X      ; special state flags
  ORA #$08         ; "ATB Autofill" (new flag)
  STA $3AA1,X      ; update special state flags
  LDA $3018,X      ; [displaced] attacker bit
  RTS

; #########################################################################
; X Kill Effect (now shifted down, freespace at top)

; -------------------------------------------------------------------------
; Kusarigama Effect ($03)
; Deal double damage to humans and randomly cast Net

org $C23D43
  JSR $38F2        ; double damage for human targets (maneater)
  JMP NetEffect    ; Jump to function to randomly cast Net

; #########################################################################
; Metamorph Chance (unused in BNW, so now freespace)

org $C23DC5
SetIgnDef:
  LDA #$20         ; "Ignore Defense"
  TSB $11A2        ; set flag ^
  RTS

; #########################################################################
; Special Effect (per-target) Jump Table [C23DCD]

org $C23DE7 : dw Zantetsuken ; Effect [?] - Zantetsuken [?]
org $C23DEB : dw Cleave      ; Effect [?] - Cleave [?]
org $C23E11 : dw NewLife     ; Effect $22 - Life (was Stone)
org $C23E13 : dw NoCounter   ; Effect [?] - Instant Death
org $C23E79 : dw Chainsaw2   ; Effect $56 (was Debilitator, now Chainsaw)

; #########################################################################
; Step Mine (unchanged)
; End of routine labeled for reuse

org $C23EC6
StoreDamage:
  STA $11B0        ; Store Damage
  RTS

; #########################################################################
; Ogre Nix Effect (now Aero/Mutsunokami + freespace)

; -------------------------------------------------------------------------
; Mutsunokami - Aero

org $C23ECA
Aero:
  JSR $4B5A     ; random(0..256)
  CMP #$80      ; C: 50% chance [TODO: Use random(0..2) function]
  BCS .exit     ; exit if ^
  STZ $11A6     ; zero battle power (attack itself does no damage)
  LDA #$99      ; "Aero v.2" spell ID
.proc
  STA $3400     ; set spellcast proc
  INC $3A70     ; increment remaining hits for spellcast
.exit
  RTS

; -------------------------------------------------------------------------
; Shock Command Effect (moved here)
; ((3 * ((Level * stamina) + current HP)) / 4) & [Attacker takes 1/8th MHP damage.]

org $C23EDD
Shock:
  LDA $3B18,Y    ; attacker Level
  XBA            ; set multiplier ^
  LDA $3B40,Y    ; attacker Stamina
  JSR $4781      ; Level * Stamina
  REP #$20       ; 16-bit A
  ADC $3BF4,Y    ; Level * Stamina + CurrentHP
  STA $11B0      ; set damage ^
  ASL            ; x2
  ADC $11B0      ; x3
  LSR            ; x3/2
  LSR            ; x3/4
  STA $11B0      ; 3/4 * (Level * Stamina + CurrentHP)
  LDA $3C1C,Y    ; attacker MaxHP
  LSR
  LSR
  LSR            ; MaxHP / 8
  PHA            ; store on stack
  LDA $3BF4,Y    ; attacker CurrentHP
  SEC            ; set carry
  SBC $01,S      ; Current HP - (Max HP / 8)
  STA $3BF4,Y    ; update CurrentHP ^
  BCS .exit      ; branch if not dead
  JSR $1390      ; attacker takes lethal damage
.exit
  PLA            ; clear stack
  RTS

; -------------------------------------------------------------------------
; Helper for Net spellproc targeting exception

org $C23F18
Net_Target:
  LDA $B6              ; spell ID (animation)
  CMP #$AD             ; is it "Net"
  BNE .randomize       ; branch if not ^
  JMP SpellProc_normal ; else, treat as normal spellcast
.randomize
  STZ $3415            ; set "Randomize Target"
  RTS

; -------------------------------------------------------------------------
; Shifted location for MP Crit Effect

MPCrit:
  LDA $B2          ; special attack flags
  BIT #$02         ; "No Critical"
  BNE .exit        ; exit if ^
  LDA $3EC9        ; how many targets
  BEQ .exit        ; exit if none ^
  TDC              ; zero A
  LDA $3B18,Y      ; attacker level
  LSR              ; lvl / 2
  REP #$20         ; 16-bit A
  STA $EE          ; save lvl / 2 in scratch RAM
  JSR MPCritCost   ; respect MP cost reduction via Gem Box
  LDA $3C08,Y      ; attacker current MP
  CMP $EE          ; current MP >= required MP
  BCC .exit        ; exit if not ^
  SBC $EE          ; subtract required MP
  STA $3C08,Y      ; update current MP
  LDA #$0200       ; "Always Critical" ($B3)
  TRB $B2          ; set ^
.exit
  RTS

; #########################################################################
; Holy Wind Effect

org $C23F54 : HolyWind:
org $C23F5C : REP #$21 ; modify to also clear carry (for reuse elsewhere)

; #########################################################################
; Golem Wall Effect
;
; Alters the Golem Wall effect to use the caster's max HP instead of current

org $C23F67 : LDA $3C1C,Y

; #########################################################################
; Soul Sabre Effect (now Net/freespace)

org $C23F6E
NetEffect:
  JSR $4B5A       ; random(0..256)
  CMP #$80        ; C: 50% chance [TODO: Use random(0..2) function]
  BCS .exit       ; exit if ^
  LDA #$AD        ; "Net" spell ID
  JMP Aero_proc   ; set proc ^ (via Aero effect fork)
.exit
  RTS

; #########################################################################
; ValiantKnife Effect

org $C23F9E : ValiantExit: ; [label]

; #########################################################################
; Tempest Wind Slash Effect

org $C23FA4 : BCS ValiantExit ; use earlier RTS for random exit branch
org $C23FA9
  LDA #$98        ; use new "Windslash" spell ID
  JMP Aero_proc   ; set proc ^ (via Aero effect fork)

; #########################################################################
; Magicite Effect (now Cleave effect)

org $C23FAE
Cleave:
  LDA $3C95,Y     ; special byte 3
  BPL .exit       ; branch if not "Undead"
  LDA #$7E        ; "Cleave" animation ID
  JMP KillZombie ; branch to Zantetsuken code for cleave-kill/boss-crit
.exit
  RTS

; #########################################################################
; Old GP Toss Routine (now freespace)

org $C23FB7
warnpc $C23FFC+1

; #########################################################################
; Exploder Effect
; Add a multiplier for Exploder when used by a player character
; 1 Spell Power = +50% damage

org $C23FFC : JSR ExploderHelp ; hook for exploder multiplier

; #########################################################################
; Blowfish Effect
; Damage = Spell Power * 50

org $C240FE
BlowFish:
  LDA $11A6       ; Spell Power
  PHA             ; Push to stack
  LDA #$32        ; 50
  PHA             ; Push to stack
  JSR HolyWind    ; Pearl Wind (sets 16-bit A, clears Carry, sets no split loss and ITD)
  PLA             ; Pull 16-bit A
  JSR $4781       ; Spell Power * 50
  JMP StoreDamage ; use end of Step Mine effect to store damage and RTS

; #########################################################################
; North Cross Effect ($29)
; One or two targets will be picked randomly

org $C2414D
  REP #$20        ; Set 16-bit A
  LDA $A4         ; targets
  PHA             ; store ^
  JSR $522A       ; randomly pick an entity from among the targets
  JMP NCross2     ; jump to second half of routine


; #########################################################################
; Dice Effect

org $C2418F : JSR DiceHelp ; corrects dice issue (by Seibaby)

; #########################################################################
; Old Revenge Routine (now freespace)

org $C241E6
Imp_Nerf:
  LDA $B5        ; command ID
  CMP #$01       ; "Item"
  BEQ .exit      ; exit if ^
  LDA $3EE4,X    ; Status byte 1
  BIT #$20       ; "Imp"
  BEQ .exit      ; branch if not ^
  LSR $11B1      ; damage / 2 (hibyte)
  ROR $11B0      ; damage / 2 (lobyte)
.exit
  JMP $14AD      ; [displaced]

; #########################################################################
; Spiraler (per-strike special effect)

; -------------------------------------------------------------------------
; Rewritten by Synchysi's "Blitz" patch to convert to "Chakra", which
; restores MP based on caster's level and stamina:
;   HealMP = (Level + Stamina) / 2 * RandomVariance

org $C24234
Chakra:
  LDA #$60       ; "No Split Dmg", "Ignore Defense"
  TSB $11A2      ; set ^
  REP #$20       ; 16-bit A
  LDA $3018,Y    ; attacker bitmask
  TRB $A4        ; always miss the caster
  SEP #$20       ; 8-bit A
  LDA $3B40,Y    ; attacker stamina
  JMP ChakraHelp ; jump to helper
  NOP #2         ; [unused space]
  RTS            ; preserved in case it's branched to from elsewhere
warnpc $C2424B+1

; -------------------------------------------------------------------------
; Helper for special effect misses

org $C2428B
Clear_Status:
  TYX            ; target index
  STZ $3DD4,X    ; clear status-to-set bytes 1/2
  STZ $3DE8,X    ; clear status-to-set bytes 3/4
  LDA $3018,Y    ; [displaced]
  RTS

; #########################################################################
; Mantra (per-strike special effect)
;
; Rewritten by Synchysi's "Blitz" patch to take stamina into account:
;   HealHP = (CurrHP / 64 + Level) * Stamina / 4

org $C24263
Mantra:
  LDA #$60       ; "No Split Dmg", "Ignore Defense"
  TSB $11A2      ; set ^
  STZ $3414      ; "No Damage Modification"
  JSR MantraHelp ; do most of formula
  LDA $E8        ; (CurrHP / 64 + Level) * Stamina
  LSR #2         ; / 4
  STA $11B0      ; set heal amount (per target)
  LDA $3018,Y    ; attacker bitmask
  TRB $A4        ; miss caster
  RTS

; #########################################################################
; End of Suplex + Reflect ??? (special effects) -- used as freespace

org $C242A4
MantraHelp:
  LDA $3B40,Y    ; attacker stamina
  STA $E8        ; save multiplier
  REP #$20       ; 16-bit A
  LDA $3BF4,Y    ; attacker current HP
  LDX #$40       ; 64
  JSR $4792      ; CurrHP / 64 [TODO: LSR #6]
  SEP #$20       ; 8-bit A
  ADC $3B18,Y    ; CurrHP / 64 + Level [NOTE: No chance of carry]
  REP #$20       ; 16-bit A [TODO: Could do A*B routine -- both 8-bits]
  JMP $47B7      ; (CurrHP / 64 + Level) * Stamina
ChakraHelp:
  CLC            ; prep addition
  ADC $3B18,Y    ; add attacker level
  LSR            ; / 2
  STA $11B0      ; set MP heal amount
  RTS
warnpc $C242C6+1

; #########################################################################
; Special Effect (per-strike) Jump Table [C242E1]

org $C242EB : dw SetIgnDef ; Defense Ignoring weapon
org $C242EF : dw MPCrit    ; MP Criticals additional hook
org $C24315 : dw BlowFish  ; Effect $1A - Blow Fish
org $C2432B : dw GroundDmg ; Effect $25 - Quake
org $C24341 : dw $3E8A     ; Remove random targeting from Suplex effect
org $C24367 : dw Shock     ; Shock formula
org $C24383 : dw CoinToss  ; Effect $51 ($C33FB7 now unused)

; #########################################################################
; Status Setting/Clearing Routine
;
; Largely rewritten by Assassin's "Overcast Fix" patch, which ensures
; "Zombie" and "Near Fatal" immunities are not ignored by "Overcast"
; effect.

org $C24517
OvercastFix:
  LDA $3EF8,Y        ; status-3/4 [moved earlier]
  STA $FA            ; backup
  LDA $331C,Y        ; blocked-1/2
  PHA                ; store ^
  AND $3DD4,Y        ; non-blocked statuses-to-set-1/2
  STA $FC            ; save ^
  XBA : ROL          ; C: "Death" about to set
  TDC                ; zero A/B
  ROL #2             ; bit1: "Death"
  AND $3E4D,Y        ; combine "Overcast" status
  AND $01,S          ; "Zombie" not blocked
  TSB $FC            ; "Zombie" to-set if not blocked
  XBA                ; 0x0200 if ^
  LSR #2             ; 0x0080 if ^
  TRB $FC            ; remove "Death" to-set
  ASL                ; 0x0100 if ^
  TSB $F4            ; set "Doom" to-clear
  LDA $3EE4,Y        ; status-1/2
  STA $F8            ; save ^
  AND #$0040         ; isolate "Petrify"
  TSB $FC            ; reset "Petrify" if possessed
  LDA $3C1C,Y        ; MaxHP
  LSR #3             ; MaxHP / 8
  CMP $3BF4,Y        ; compare to CurrHP
  LDA #$0200         ; "Near Fatal"
  BIT $F8            ; check in current status ^
  BNE .may_remove    ; branch if ^
  BCC .done          ; branch if CurrHP > MaxHP/8
  TSB $FC            ; else to-set "Near Fatal"
.may_remove
  BCS .done          ; branch if CurrHP < MaxHP/8
  TSB $F4            ; else to-clear "Near Fatal"
.done
  PLA                ; restore blocked statuses-1/2
  AND $FC            ; remove from to-set-statuses-1/2
  STA $FC            ; update status-to-set-1/2
  PHA                ; store ^
  LDA $3DE8,Y        ; status-to-set-3/4
  AND $3330,Y        ; exclude blocked-3/4
  STA $FE            ; save ^
  PHA                ; store ^
  LDA $32DF,Y        ; hit by attack
  BPL .finish        ; branch if not ^
  JSR $447F          ; get new status
  LDA $FC            ; new status-1/2
  STA $3E60,Y        ; save quasi-status-1/2
  LDA $FE            ; new status-3/4
  STA $3E74,Y        ; save quasi-status-3/4
.finish
  PLA                ; restore status-to-set-3/4
  STA $FE            ; save ^
  PLA                ; restore status-to-set-1/2
  STA $FC            ; save ^
  RTS
  NOP
  RTS

; -------------------------------------------------------------------------
; Imp no longer reruns equipment check

org $C245E2 : JMP $464C ; changed from JSR

; -------------------------------------------------------------------------
; Sleep on-set

org $C24637 : LDA #$09      ; Sleep (adjust timer for nATB)

; -------------------------------------------------------------------------
; Stop on-set

org $C24680 : LDA #$09      ; Stop (adjust timer for nATB)

; -------------------------------------------------------------------------
; Reflect on-clear (no longer used for status clear, now freespace helper)

org $C24687
ReflectClear:
  SEP #$20             ; 8-bit A
  JSR $4B5A            ; RNG: 0..255
  CMP #$55             ; 1 in 3 chance to clear Rflect status
  JMP ReflectClear2    ; (continued...)

; -------------------------------------------------------------------------
; Freeze on-set

org $C24694 : LDA #$0A      ; Freeze (adjust timer for nATB)

; -------------------------------------------------------------------------
; Empty on-set / on-clear

org $C2469B : NoStatusHook: ; [label] RTS for empty status clear/set hooks

; -------------------------------------------------------------------------
; Status on-clear and on-set jump tables

org $C246DE : dw NoStatusHook ; "Reflect" on-set - removed
org $C246F4 : dw Poison       ; "Poison" on-clear - reset increment

; #########################################################################
; Field Item Usage

org $C2474F : JMP FieldLifeHelp ; handle new "life" spell effect in field
FieldItemReturn:

; #########################################################################
; Special Checks for End-of-Battle
;
; Allows partial party engulfs to still transport the party to Gogo's Cave
org $C24816 : NOP #5

; #########################################################################
; End-of-Battle (or tier switch) Handling

org $C24903 : NOP #3 ; skip morph gauge reset/update

; #########################################################################
; RNG

org $C24B5F : JSL Random
org $C24B6F : JSL Random

; #########################################################################
; Prepare Counterattacks (C24C5B)

org $C24C5B
PrepCounter:     ; set parent label for full routine
org $C24CC2 : .no_counter
org $C24CDD : BNE .counter ; skip blackbelt check for "damaged this turn"
org $C24CE3 : BCC .counter ; skip blackbelt check for "damaged this turn"
org $C24CE5 : JSR ShadowChk : NOP ; change Interceptor spell for Relm

org $C24CFC : .counter
org $C24D03
  JSR StamCounter    ; blackbelt counter algorithm
  CMP $10            ; compare random() to Stamina + 32 (in scratch)
  BCS .no_counter    ; exit if (0..128) was larger than (Stam + 32)

; #########################################################################
; Various setup for player-confirmed commands

; Detaches Joker Doom (now Jackpot) from Dispatch's spell slot
org $C24DBF
PlayerCmdSetup:
  BRA .check_bar         ; skip check for Joker Doom (now freespace)
org $C24DD2 : .check_bar
org $C24E4A : db $97,$97 ; change both Joken Doom spell IDs

; #########################################################################
; Determine MP Cost of Spell

; -------------------------------------------------------------------------
; Account for condensed magic list when looking up MP cost

org $C24F24
  XBA                ; store command ID
  REP #$10           ; 16-bit X/Y
  LDA $3A7B          ; spell/attack ID
  CPX #$0008         ; monster slot range
  BCS .fka_4F47      ; branch if attacker in ^
  XBA                ; high is spell, low is command
  CMP #$19           ; "Summon" command ID
  BEQ .summon        ; branch if ^
  JMP calcMPCost     ; helper to find spell in condensed menu
  NOP
.summon
  CLC                ; clear carry
  TDC                ; zero A/B
  REP #$20           ; 16-bit A
org $C24F47
.fka_4F47

; #########################################################################
; Periodic Damage & Healing Calculation

org $C25041 : NOP ; cumulative poison incrementor set to +1, not +2
org $C2505B : JSR Tick_Calc : NOP #2 ; Re-written formulas for periodic effects

; #########################################################################
; Scan Command

; -------------------------------------------------------------------------
; Branches past HP/MP display for scan (now freespace)

org $C250F2 : BRA Scan

; -------------------------------------------------------------------------
; Some portion of previous routine is now overwritten as freespace

org $C250F4
Row_Dmg:
  PHP             ; store flags
  REP #$20        ; 16-bit A
  LDA $F0         ; dmg
  LSR             ; dmg / 2
  LSR             ; dmg / 4
  EOR #$FFFF      ; -(dmg / 4) - 1
  SEC             ; set carry (to add 1)
  ADC $F0         ; dmg - dmg/4
  STA $F0         ; update dmg
  PLP             ; restore flags
  RTS

org $C25105       ; freespace [?]
Get_Tgt_Byte:
  JSR $2B63       ; multiply weapon ID by 30
  REP #$10        ; 16-bit X/Y
  TAX             ; index weapon data offset
  LDA $D8500E,X   ; weapon targeting byte
  CMP #$01        ; "target one ally"
  BNE .exit       ; exit if not ^
  REP #$21        ; 16-bit A
  LDA $06,S       ; attacker index
  TAX             ; index it
  SEP #$20        ; 8-bit Accumulator
  LDA #$01        ; "target one ally"
  STA $0002,X     ; set ^ aiming byte
.exit
  RTS

; -------------------------------------------------------------------------
; Modified by dn's "Scan Status" patch to add support for Status messages.
; The "Scan Weakness" code is now displaced into C4 along with the new
; "Scan Status" code.

org $C25138
Scan:
  JSL ScanWeakness
  JSL ScanStatus
  RTS
padbyte $FF
pad $C25161
warnpc $C25161+1

; #########################################################################
; Probabilities for Umaro and Side/Pincer/Back/Normal attacks

org $C25269
  ; Row 1: No relics Column 1: Fight
  ; Row 2: Rage Belt only Column 2: Tackle
  ; Row 3: Blizzard Orb only Column 3: Snowstorm
  ; Row 4: Both relics Column 4: Rage
  db $B2,$4B,$FF,$FF ; 70% Fight, 30% Tackle
  db $66,$4B,$FF,$4B ; 40% Fight, 30% Tackle, 30% Rage
  db $66,$4B,$4B,$FF ; 40% Fight, 30% Tackle, 30% Snowstorm
  db $1A,$4B,$4B,$4B ; 10% Fight, 30% Tackle, 30% Rage, 30% Snowstorm

org $C25279
  db $20    ; Side attack (32/255)
  db $20    ; Pincer (32/255)
  db $20    ; Back attack (32/255)
  db $9B    ; Normal (155/255)

; #########################################################################
; Determine which menu commands are disabled
;
; Largely rewritten as part of Assassin's "Brushless Sketch" patch to
; disable the "Sketch" command when no brush is equipped.
; Also modified to bypass or omit Imp effects on command availability.

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
  JSR SketchBrshChk  ; set bit 0 if "Sketch" invalid

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
  BRA .skip_imp      ; branch if not ^ TODO: Remove unused code below this BRA
  LDA $CFFE00,X      ; command data
  BIT #$04           ; "Allowed while Imp"
  BEQ .disable       ; branch if not ^
.skip_imp
  TXA                ; command ID *2
  ROR                ; restore command ID (LSR would be fine)
  LDX #$0008         ; initialize command loop
.loop
  CMP ModifyCmds,X   ; current command matches special case
  BNE .next          ; branch if not ^
  TXA                ; matched command index
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
  db $1B    ; Shock (used to be Morph)
  db $0D    ; Sketch
  db $0B    ; Runic
  db $07    ; SwdTech
  db $0C    ; Lore
  db $17    ; X-Magic
  db $02    ; Magic
  db $06    ; Capture
  db $00    ; Fight

CmdModify:
  dw $5322  ; Shock (used to be Morph)
  dw $52FD  ; Sketch
  dw $5322  ; Runic
  dw $531D  ; SwdTech
  dw $5314  ; Lore
  dw $5314  ; X-Magic
  dw $5314  ; Magic
  dw $5301  ; Capture
  dw $5301  ; Fight

SketchHelp:
  LDA $EF        ; disabled commands
  LSR            ; C: Sketch Invalid
  RTS
warnpc $C25301+1

; #########################################################################
; Fight and Mug Command Targeting Setup
;
; Now adjusts targeting for Heal Rod, and no longer changes targeting
; for the Offering (X-Fight)

org $C25301
  PHP               ; store flags
  LDA $3CA8,Y       ; righthand weapon ID
  JSR Get_Tgt_Byte  ; update targeting byte if heal rod
  LDA $3CA9,Y       ; lefthand weapon ID
  JSR Get_Tgt_Byte  ; update targeting byte if heal rod
  PLP               ; restore flags
  RTS

; #########################################################################

org $C25310
NoCounter:
  STZ $341A         ; disable counterattack (animation removes target)
  RTS

; #########################################################################
; Morph Command Disabling
; No longer needed at all, since Shock replaced Morph above

org $C25326 : CLC : RTS ; never disable

; #########################################################################
; Convert or hide commands based on relics or event bits
;
; Largely rewritten as part of Assasin's "Brushless Sketch" patch
; Modified by "Gogo MP" patch, which ensures MP is never zeroed,
; even when no MP-using commands are possessed. This change allows
; Gogo to wield MP Crit weapons successfully.

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
  JSR (BlankCmd,X)  ; run special function
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
  BRA .exit         ; never zero MP (so MP crit weapons work)
  LDA $02,S         ; retrieve character slot index
  TAX               ; index it
  REP #$20          ; 16-bit A
  STZ $3C08,X       ; zero current MP
  STZ $3C30,X       ; zero max MP
.exit
  PLP               ; restore flags
  PLX               ; restore X (character slot)
  RTS 

SketchBrshChk:
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
  CMP #$E2          ; brush icon
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
  JSR checkLeap     ; run helper function
  BIT #$02          ; "Leapable Formation"
  BRA .try_mp       ; TODO: This branch seems wrong (should be may_null)
.Lore
.needs_mp
  LDA #$01          ; "Needs MP" flag
  TSB $F8           ; set ^ in scratch RAM
.exit
  RTS
warnpc $C2544A+1

; #########################################################################
; Menu Offsets - unchanged from vanilla

org $C2544A
MenuOffsets:
  dw $202E
  dw $203A
  dw $2046
  dw $2052

; #########################################################################
; Convert or hide commands based on relics or event bits (part 2)
;
; Modified in Assassin's "Brushless Sketch" patch, one lookup table here
; has been removed, as it duplicated handling in C3. With the freespace,
; a couple helper functions have been added.

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
warnpc $C2546E+1

; ########################################################################
; Construct Magic and Lore Menus

org $C255BD : CMP #$19       ; extend "Black Magic" range by 1 (incl. Stone)

org $C2574B ; Spell placement for battle menu
  db $09,$1D,$00,$00,$1D,$14 ; Black magic (adj for more new Black spell)
  db $09,$F0,$00,$09,$E7,$E7 ; Grey magic (adj for more new Black spell)
  db $D3,$D3,$00,$EC,$E7,$00 ; White magic (adj for more new Black spell)

org $C257B0 : BRA NoImpDis   ; skip Imp check for disabling spells in list
org $C257BB : NoImpDis:      ; label for above ^

; ########################################################################
; Construct Dance and Rage Menus
;
; Modified by Assassin's "Alphabetical Rage" hack. Included with that hack
; are the following notes:
;   Generates alphabetical in-battle Rage menu. Much like the original,
;   enemies with undiscovered rages and enemy #255 are skipped entirely.
;   While it may seem harmless enough to just go and output the null entry
;   for Pugs, this would lead to two bad things:
;   - If you've found all 256 rages, the $3A9A counter overflows, which
;     prevents the game from being able to correctly choose a random Rage
;     when a character's muddled.
;   - The code that chooses a random Rage dislikes null entries in the
;     middle of the list for some reason, and will deliberately seek them
;     out. If you had a blank spot corresponding to Pugs in an alphabetical
;     Guard [enemy #0] taking their place.

org $C2580C
  TDC              ; [unchanged]
  LDA $1CF7        ; [unchanged]
  JSR $520E        ; [unchanged]
  DEX              ; [unchanged]
  STX $2020        ; [unchanged]
  TDC              ; [unchanged]
  LDA $1D28        ; [unchanged]
  JSR $520E        ; [unchanged]
  STX $3A80        ; [unchanged]
  LDA $1D4C        ; [unchanged]
  STA $EE          ; [unchanged]
  LDX #$07         ; [unchanged]
.dance_loop
  ASL $EE          ; [unchanged]
  LDA #$FF         ; [unchanged]
  BCC .next_dance  ; [unchanged]
  TXA              ; [unchanged]
.next_dance
  STA $267E,X      ; [unchanged]
  DEX              ; [unchanged]
  BPL .dance_loop  ; [unchanged]
  REP #$20         ; [unchanged]
  LDA #$257E       ; [unchanged]
  STA $002181      ; [unchanged]
  SEP #$20         ; [unchanged]
  TDC              ; [unchanged]
  TAX              ; [unchanged] zero loop iterator
  STA $002183      ; set WRAM bank to 7E
.rage_loop
  LDA RageList,X   ; get next sorted rage ID
  TAY              ; index it
  PHX              ; store iterator
  CLC              ; $5217 below uses carry as 9th bit of A
  JSR $5217        ; X: byte index, A: bitmask for bit in byte
  BIT $1D2C,X      ; compare to current rage byte
  BEQ .next_rage   ; branch if rage not learned
  TYA              ; rage ID
  INC $3A9A        ; increment known rages
  STA $002180      ; store rage ID in menu
.next_rage
  PLX              ; restore iterator
  INX              ; next rage index
  CPX #$40         ; 64 rages total (BNW)
  BNE .rage_loop   ; check all 64 rages
  RTS 

; #########################################################################
; Big Ass Targeting Function (and friends)
;
; Interrupt routine near "Abort on Characters" check to implement
; new "Abort on Enemies" helper routine. (Synchysi)

org $C25902 : JSR EnemyAbort ; Add "abort-on-enemies" support

; #########################################################################
; Time Based Events for Entities

org $C25AE9 : TimerRTS: ; [label] existing RTS for reuse

; Double frequency of Regen and Poison ticks
org $C25AEA
  dw $5B45 ; Regen
  dw $5B3B ; Poison
  dw $5B45 ; Regen
  dw $5AE8 ; RTS
  dw $5B45 ; Regen
  dw $5B3B ; Poison
  dw $5B45 ; Regen
  dw $5AE8 ; RTS

; Increment battle timers 2 more times per tick
org $C25AFE
  dw $5BFC
  dw $5BFC

; -------------------------------------------------------------------------
; Decrement Status Timers, Handle Expiration
; Code rewritten to remove "Reflect" timer and create freespace for helper

org $C25B06
  STA $B8              ; set status removals so far (maybe $01 - Stop)
  LDA $3F0D,X          ; time until Freeze wears off
  BEQ .sleep           ; branch if no ^
  DEC $3F0D,X          ; else, decrement Freeze timer
  BNE .sleep           ; branch if not expired
  LDA #$04             ; "Remove Freeze" flag
  TSB $B8              ; set ^
.sleep
  LDA $3CF9,X          ; time until Sleep wears off
  BEQ .end             ; branch if no ^
  DEC $3CF9,X          ; else, decrement Sleep timer
  BNE .end             ; branch if not expired
  LDA #$08             ; "Remove Sleep" flag
  TSB $B8              ; set ^
.end
  LDA $B8              ; statuses to be auto-removed
  BEQ TimerRTS         ; exit if none ^
  LDA #$29             ; "Status Expiration" special action command
  JMP $4E91            ; queue ^

; -------------------------------------------------------------------------
; Helper for new Reflect %-chance to remove

ReflectClear2:
  BCS .end             ; exit 2/3 times
  LDA $3330,Y          ; vulnerable-status-3
  BPL .end             ; branch if not vulnerable to "Reflect"
  JSR ReflectClear3    ; else, handle removal
.end
  JMP $22E5            ; make attack miss
  NOP                  ; (padding)

; -------------------------------------------------------------------------
; Running timer/counter

org $C25BDE : AND #$30 ; increased chances of running

; #########################################################################
; Victorious Combat (C25D91)

; Make EP gains display after combat
org $C25E0B : JSR Show_EP

; The following branch bypasses the function that adjusts Terra's Morph supply.
org $C25E2F : BRA AfterMorph

; Use freespace from BRA above ($C25E31 - $C25E48)
SetTarget:
  STY $C0        ; save target index in scratch RAM
  JSR $220D      ; [displaced] miss determination
  RTS
CounterMiss:
  LDY $C0        ; get target index
  LDA $3018,Y    ; target bitmask
  BIT $3A5A      ; "Miss" tile flag set
  BEQ .done      ; branch if not ^
  JSR $35E3      ; else, initialize counter variables
.done
  REP #$20       ; [displaced] 16-bit A
  LDY #$12       ; [displaced] prep entity loop
  RTS

org $C25E49 : AfterMorph:

org $C25E4C
  LDA $1D4D      ; config option byte
  BIT #$08       ; "Exp Gain"
  BEQ .no_exp    ; branch if not ^
  JSR $6235      ; else, add experience
  NOP #3         ; excess instructions.
.no_exp

; Remove learning spells from post-combat routine
org $C25E6A : BRA No_Spells
org $C25E72 : No_Spells:

; Synchysi's note:
; The instruction here would seem to prevent the game from ever displaying
; magic point gains after battle, but that's clearly not the case in
; vanilla. For now, they're NOP'd until I can determine their function.
; Bropedio's note:
; TODO: Note, this is the source of the SP/EL/EP showing up early bug. Confirm
; that this NOP code is removed in follow-up hacks
org $C25E79 : NOP #2

; Make EL gains display after combat
org $C25EAC : JSR Show_EL

; #########################################################################
; Cursed Shield

org $C25FFE
CursedShield:
  XBA             ; get cursed shield ID
  INC $3EC0       ; increment uncurse count
  LDA $3EC0       ; uncurse count
  CMP #$40        ; = 64
  BNE .nope       ; branch if not ^
  JSR ChangeShld  ; else, replace with Paladin Shield
org $C2600D
.nope

; #########################################################################
; Level-up Routine

; Check for learning abilities in new displaced routine location
org $C260BC : JSR LevelChk

; Re-arranging level up function to separate levels from esper bonuses
org $C260DD
  REP #$21      ; Set 16-bit A, clear carry
  LDA $160B,X   ; Max HP
  PHA
  AND #$C000    ; Isolate bits for HP boosts from gear
  STA $EE
  PLA           ; Max HP again
  AND #$3FFF    ; Isolate max HP without equipment boosts
  ADC $FC       ; Add to HP gain for leveling
  CMP #$2710
  BCC $03       ; Branch if new HP value is less than 10000
  LDA #$270F    ; Otherwise, set it to 9999
  ORA $EE       ; Combine with HP boosts from gear
  STA $160B,X   ; New max HP
  CLC
  LDA $160F,X   ; Max MP
  PHA
  AND #$C000    ; Isolate bits for MP boosts from gear
  STA $EE
  PLA           ; Max MP again
  AND #$3FFF    ; Isolate max MP without equipment boosts
  ADC $FE       ; Add to MP gain for leveling
  CMP #$03E8
  BCC $03       ; Branch if new MP value is less than 1000
  LDA #$03E7    ; Otherwise, set it to 999
  ORA $EE       ; Combine with MP boosts from gear
  STA $160F,X   ; New max MP
  PLP
  RTS
  
; Esper bonuses
Do_Esper_Lvl:
  LDA #$25
  XBA
  TXA
  LDX $4216       ; Get start of esper info block
  JSR $4781       ; Character ID * 37
  TAY
  TDC
  LDA $D86E0A,X   ; Get esper bonus index
  ASL
  TAX             ; X = bonus index * 2
  JSR (ELBoost,X) ; Calculate bonus
  RTL

; Esper bonus handling, completely rewritten

org $C2614E     ; TODO: Remove this org [?]
ELBoost:
  dw HP_60      ; HP +60
  dw MP_40      ; MP +40
  dw HP_MP_Dual ; HP +30/MP +15
  dw Vig_Dual   ; Vigor +1/HP +20
  dw Mag_Dual   ; Magic +1/MP +20
  dw Vig_Dual   ; Vigor +1/Speed +1
  dw Mag_Dual   ; Magic +1/Speed +1
  dw Vig_Dual   ; Vigor +1/Stamina +1
  dw Mag_Dual   ; Magic +1/Stamina +1
  dw Spd_Stam   ; Speed +1/Stamina +1
  dw HP_Stam    ; HP +30/Stamina +1
  dw MP_Stam    ; MP +25/Stamina +1
  dw Vig_Boost  ; Vigor +2
  dw Spd_Boost  ; Speed +2
  dw Sta_Boost  ; Stamina +2
  dw Mag_Boost  ; Magic +2
  dw End        ; Free space

; HP/MP boosts

MP_15:
  LDA #$0F
  BRA MP_Prep
MP_20:
  LDA #$14
  BRA MP_Prep
MP_25:
  LDA #$19
  BRA MP_Prep
MP_40:
  LDA #$28
MP_Prep:
  INY
  INY
  INY
  INY
  BRA HPMP_Boost
HP_20:
  LDA #$14
  BRA HPMP_Boost
HP_30:
  LDA #$1E
  BRA HPMP_Boost
HP_60:
  LDA #$3C
HPMP_Boost:
  CLC
  ADC $160B,Y
  STA $160B,Y
  TDC
  ADC $160C,Y
  STA $160C,Y
End:
  RTS

; Dual bonuses

HP_MP_Dual:
  PHY
  JSR HP_30
  PLY
  JMP MP_15
Mag_Dual:
  PHY           ; Preserve Y, since it will get molested when boosting magic
  JSR Mag_Boost
  PLY           ; Restore Y for potential future stat boosts
  BRA Skip_Vig
Spd_Stam:
  PHY           ; Preserve Y, since it will get molested when boosting speed
  JSR Spd_Boost
  PLY           ; Restore Y for potential future stat boosts
  BRA Sta_Boost
Vig_Dual:
  JSR Vig_Boost ; No need to preserve Y, as a vigor boost won't modify it
Skip_Vig:
  CPX #$0008
  BCC HP_20     ; If X < 8, we're boosting HP +20 along with vigor
  BEQ MP_20     ; If X = 8, we're boosting MP +20 along with magic
  CPX #$000E
  BCC Spd_Boost ; If 8 < X < 14, we're boosting speed along with vigor/magic
  BRA Sta_Boost ; Else, we're boosting stamina along with vigor/magic/HP/MP
HP_Stam:
  PHY
  JSR HP_30
  PLY
  BRA Sta_Boost
MP_Stam:
  PHY
  JSR MP_25
  PLY
  BRA Sta_Boost

; Stat bonus

Mag_Boost:
  INY            ; 3 INYs = boost magic power
Sta_Boost:
  INY            ; 2 INYs = boost stamina
Spd_Boost:
  INY            ; 1 INY = boost speed
Vig_Boost:       ; 0 INYs = boost vigor
  LDA $161A,Y    ; Stat to raise, based on Y
  INC
  CPX #$0017     ; If X > 22, we're boosting a single stat, which will be +2
  BCC Store_Stat ; Otherwise, we're doing a dual stat bonus, which is +1
  INC

Store_Stat:
  CMP #$81        ; If the stat is greater than 128, set it equal to 128
  BCC Update_Stat
  LDA #$80
Update_Stat:
  STA $161A,Y     ; Save updated stat
  RTS

; #########################################################################
; Sabin Learning Blitzes at Level-up (moved elsewhere by EL rewrite)
; Now freespace

org $C261E9
StamSpecial:      ; helper for monster special status attacks
  STA $11AA,X     ; [displaced] set attack status byte
  LDA #$10        ; "Stamina Evade"
  TSB $11A4       ; set ^ attack flag
  RTS

; #########################################################################
; Add Experience after Battle

; Interrupt leveling routine to calculate EP
org $C26236 : JSR Add_EP : NOP #2

; #########################################################################
; Changes the experience cap from 15,000,000 to 999,999.

org $C26276 : dl $0F423F ; 999,999

; #########################################################################
; Damage Number Processing and Queuing Animation(s)
;
; Part of "MP Colors" patch, Fork which battle dynamics command ID
; based on MP flag

org $C263A9 : JSR DmgCmdAlias
org $C263BB : JSR DmgCmdAliasMass

; #########################################################################
; Freespace (C26469-C26800)

; -------------------------------------------------------------------------
; New player character physical damage formula

org $C26469
PlayerPhys:
  PHA             ; store A (BatPwr)
  SEP #$20        ; 8-bit A
  LDA $B5         ; command ID
  CMP #$07        ; "Bushido"
  BNE .two_hand   ; branch if not ^
.bushido          ; else, include user's weapon(s) and skill modifier
  LDA $01,S       ; BatPwr
  STA $E8         ; save multiplier
  LDA $3B68,X     ; righthand weapon power
  CLC             ; clear carry
  ADC $3B69,X     ; add lefthand weapon power (usually 0 for Cyan)
  XBA             ; hibyte of sum
  ADC #$00        ; add carry if overflow
  XBA             ; 16-bit BatPwr sum
  REP #$20        ; 16-bit A
  LSR #3          ; BatPwr / 8
  JSR $47B7       ; (BP / 8) * $E8 (for Bushido, is multiplier)
  LDA $E8         ; modified BatPwr
  STA $01,S       ; replace BatPwr on stack
.two_hand
  REP #$20        ; 16-bit A
  LDA $B2         ; special attack flags
  BIT #$4000      ; "Two-Handed"
  BNE .formula    ; branch if not ^
  LDA $01,S       ; BatPwr
  LSR             ; / 2
  CLC : ADC $01,S ; add to BatPwr (x1.5)
  STA $01,S       ; replace BatPwr on stack
.formula
  PLA             ; BatPwr
  STA $D0         ; store in scratch RAM
  LSR #4          ; BatPwr / 16
  STA $11B0       ; save temporarily
  SEP #$20        ; 8-bit A
  LDA $11AE       ; attack stat (Vigor * 2)
  LSR             ; / 2 (Vigor is stored doubled)
  XBA             ; store Vigor in B
  PLA             ; get Level from stack (pushed long ago)
  STA $E8         ; save multiplier ^ for later
  JSR $4781       ; Level * Vigor
  REP #$20        ; 16-bit A
  LSR #4          ; Level * Vigor / 16
  JSR $47B7       ; Level * (Level * Vigor / 16)
  SEP #$20        ; 8-bit A
  LDA $EA         ; overflow from multiplication ^
  BNE .dmg_cap    ; branch if ^ (max dmg)
  LDA $11B0       ; BatPwr / 16
  PHA             ; store ^
  REP #$20        ; 16-bit A
  LDA $E8         ; Level * Level * Vigor / 16
  STA $11B0       ; save damage so far
  SEP #$20        ; 8-bit A
  PLA             ; restore BatPwr / 16
  STA $E8         ; set multiplier
  REP #$20        ; 16-bit A
  LDA $11B0       ; damage so far
  JSR $47B7       ; (BatPwr / 16) * (Level * Level * Vigor / 16)
  LDA $E8         ; product ^
  PHX             ; store X (attacker index)
  LDX #$18        ; set divisor to #24
  JSR $4792       ; divide damage by ^
  STA $11B0       ; set final damage
  TDC             ; zero A/B
  SEP #$20        ; 8-bit A
  LDA $EA         ; overflow from last multiplication
  BEQ .finish     ; branch if none ^
  CMP #$07        ; is overflow >= 7 (~19k dmg) TODO Should be CMP #$08 [?]
  BCS .dmg_cap    ; branch if ^ to use max dmg (~19k+9999=30000)
  TAY             ; set iterator
  REP #$20        ; 16-bit A
.loop
  LDA #$0AAB      ; 65536 / 24 [#$10000 / #$18]
  ADC $11B0       ; add overflow to damage
  STA $11B0       ; update damage
  DEY             ; decrement iterator
  BNE .loop       ; loop till done
  TDC             ; zero A/B
.finish
  SEP #$20        ; 8-bit A
  LDA $D0         ; BatPwr (lobyte)
  ADC $11AE       ; BatPwr + Vigor * 2
  XBA             ; store lobyte in B
  LDA $D1         ; BatPwr (hibyte)
  ADC #$00        ; add overflow if carry set
  XBA             ; swap bytes back
  REP #$20        ; 16-bit A
  ADC $11B0       ; add BatPwr + Vigor * 2 to total damage
  STA $11B0       ; update final damage
  BRA .exit       ; branch to exit
.dmg_cap
  REP #$20        ; Set 16-bit accumulator
  LDA #$7530      ; 30000 maximum damage (leave room for crits)
  STA $11B0       ; set max damage
.exit
  PLX             ; restore X (attacker index)
  JMP PhysDmgJump ; jump back to physical damage fork

Row_Chk:
  EOR #$FF        ; flip bits so bit 4 is now "respect row"
  ASL             ; move to bit 5 to match $B3
  ORA $B3         ; combine row-respecting bytes
  AND #$20        ; if attack respects row, bit 5 should be set
  RTS

; -------------------------------------------------------------------------
; Field Item Usage Helper

org $C265BE
FieldLifeHelp:
  JSR $2966       ; [displaced] load spell data
  LDA $11A9       ; special effect x2
  CMP #$44        ; is it "Life" spell
  BNE .exit       ; exit if not ^ ($22, was "Stone")
  JMP NewLife     ; do "Life" spell effect
.exit
  JMP FieldItemReturn

; -------------------------------------------------------------------------
; Condensed Spell List helper.
; Takes a character's spell list and 'shuffles' it up, so that all of the
; blank spots are at the end.
; TODO: Remove nested loops

org $C265CE
condenseSpellLists:
  PHX                 ; store character slot index
  PHP                 ; store flags
  LDY #$04            ; first spell entry in list (source index)
.noMoreSpells
  TYX                 ; copy to destination index
  REP #$10            ; 16-bit X/Y
.checkSpellLoop
  LDA ($F2),Y         ; spell ID in destination slot
  INC                 ; check for null
  BNE .check_next     ; branch if not ^
.findNextSpell
  INY #4              ; advance to next spell entry
  CPY #$00DC          ; at start of Lore list
  BEQ .noMoreSpells   ; branch if ^
  CPY #$013C          ; after Lore list range
  BEQ .noMoreLores    ; branch if no more spells ^
  LDA ($F2),Y         ; spell ID in source slot
  INC                 ; check for null
  BEQ .findNextSpell  ; branch if ^
  PHY                 ; store source spell index
  CLC                 ; clear carry
  REP #$20            ; 16-bit A (to move spell data 2 bytes at a time)
.copyNextSpell
  LDA ($F2),Y         ; spell data (two bytes) in source slot
  PHY                 ; store source spell index
  TXY                 ; destination index in Y now
  STA ($F2),Y         ; move spell data to destination slot
  PLY                 ; restore source spell index
  INY #2              ; point to MP cost (source)
  INX #2              ; point to MP cost (destination)
  BCS .doneCopy       ; branch if done copying
  SEC                 ; set carry
  BPL .copyNextSpell  ; if we haven't done four bytes, loop back and grab the next TODO: Should be BRA
.doneCopy
  SEP #$20            ; 8-bit A
  PLY                 ; this is the first byte of the slot we copied from
  TDC                 ; zero A/B
  STA ($F4),Y         ; zero out the MP cost
  DEC                 ; $FF (null)
  STA ($F2),Y         ; null the spell we copied from
  BRA .weCopiedASpell ; branch
.check_next
  INX #4              ; next destination spell
.weCopiedASpell
  TXY                 ; and then copy it over to Y for our next loop through
  CPY #$0138          ; last lore index
  BNE .checkSpellLoop ; branch if not ^
.noMoreLores
  PLP                 ; restore flags
  PLX                 ; restore X (character slot index)
  JMP $532C           ; [displaced] modify commands

; --------------------------------------------------------------------------

org $C2661B
NCross2:
  STA $A4          ; Save new target
  PLA              ; Get original targets again
  JSR $522A        ; Pick one at random
  TSB $A4          ; Save new target(s)
  SEP #$20         ; Set 8-bit A
  RTS

; --------------------------------------------------------------------------
; Sketch Helpers

org $C26631
SketchMag:
  BMI .exit        ; exit if no sketcher
  TAX              ; else, index sketcher index
  LDA $11A2        ; attack flags
  LSR              ; C: "Physical"
  LDA $3B41,X      ; sketcher's Magic Power
  BCC .mag_atk     ; branch if not "Physical"
  ASL              ; else, double to imitate Vigor (stored x2) 
.mag_atk
  STA $11AE        ; set damage stat
.exit
  RTS

SketchChk:
  BCS NoSketch2    ; branch if special attack or an attack with the left hand.
SketchChk2:
  LDA $3417        ; check "Sketcher"
  BMI NoSketch2    ; exit if no ^
  PHX              ; store sketcher index
  TAX              ; index it
  LDA $3B68,X      ; sketcher's Battle Power
  PLX              ; restore X
  BRA SketchMag_exit

NoSketch2:
  CMP #$06         ; is it a special attack?
  BEQ SketchChk2   ; branch if ^
  LDA $3B68,X      ; else load up the attacker's battle power
  RTS

; --------------------------------------------------------------------------
; Displaced due to original esper boost rewrite
; TODO: Look into moving back in-line after Bropedio change overwrites boosts
org $C26659
LevelChk:
  LDX #$0000       ; Beginning of Terra's magic learned at level up block
  CMP #$00
  BEQ .learn_magic ; If Terra leveled, branch to see if she learns any spells
  LDX #$0020       ; Beginning of Celes' magic learned at level up block
  CMP #$06
  BEQ .learn_magic ; If Celes leveled, branch to see if she learns any spells
  LDX #$0000       ; Beginning of Cyan's SwdTech learned at level up block
  CMP #$02         ; If Cyan leveled, check for any new SwdTechs
  BNE .learn_blitz ; Else, check for any new Blitzes for Sabin
.learn_bushido
  JSR $6222        ; Are any SwdTechs learned at the current level?
  BEQ .exit        ; If not, exit
  TSB $1CF7        ; If so, enable the newly learnt SwdTech
  BNE .exit        ; If it was already enabled (finished the nightmare), exit
  LDA #$40
  TSB $F0
  BNE .exit
  LDA #$42
  JMP $5FD4
.learn_blitz
  LDX #$0008       ; Beginning of Sabin's Blitzes learned at level up block
  CMP #$05         ; If Sabin leveled, check for any new Blitzes
  BNE .exit        ; If not, exit
  JSR $6222        ; Are any Blitzes learned at the current level?
  BEQ .exit        ; If not, exit
  TSB $1D28        ; If so, enable the newly learnt Blitz
  BNE .exit        ; If it was already enabled (Bum Rush), exit
  LDA #$80
  TSB $F0
  BNE .exit
  LDA #$33
  JMP $5FD4
.learn_magic
  JMP $61FC
.exit
  RTS

; -------------------------------------------------------------------------
; Zantetsuken Effect Helpers

org $C266A3
Zantetsuken:
  LDA #$EE      ; "XKill" animation ID
  XBA           ; store in B [TODO: overwritten below, remove this]
  JSR $4B5A     ; random(0..256)
  CMP #$40      ; C: 75% chance

Undead_Killer:
  BCS .exit     ; exit if no proc
  LDA $3AA1,Y   ; target special state flags
  BIT #$04      ; "Immune to Instant Death"
  BNE .crit     ; do critical damage if ^
  LDA #$7E      ; "Cleave" animation ID
  XBA           ; store in B
  JMP $38A6     ; execute cleave-kill.
.crit
  LDA $BC       ; attack incremented damage (Critical Hit?) [TODO: confirm]
  BNE .exit     ; exit if ^ (no double critical)
  INC $BC       ; dmg +50%
  INC $BC       ; dmg +100%
  LDA #$20      ; "Flash Screen" flag
  TSB $A0       ; set ^ animation
.exit
  RTS

; -------------------------------------------------------------------------

org $C266C7
; Coin Toss Formula
;   -> GP Rained = Stam * 10
;   -> Dmg = (GP Tossed * Lv) / (2 * (# of targets + 1))
CoinToss:
  LDA $3B40,Y     ; attacker stamina.
  XBA             ; store in B
  LDA #$0A        ; multiplier
  JSR $4781       ; coins tossed: stamina * 10
  REP #$20        ; 16-bit A
  CPY #$08        ; is monster attacker
  BCS .enemy_toss ; branch if ^
  JSR $37B6       ; deduct thrown GP from party
  BNE .toss_em    ; branch if have GP leftover
.broke
  STZ $A4         ; clear targets
  LDX #$08        ; failure message ID
  STX $3401       ; set ^
  RTS
.enemy_toss
  STA $EE         ; save coins tossed
  LDA $3D98,Y     ; monster GP
  BEQ .broke      ; branch if none ^
  SBC $EE         ; else, subtract thrown coins
  BCS .deduct     ; branch if enough coins
  LDA $3D98,Y     ; monster GP
  STA $EE         ; throw all remaining coins
  TDC             ; zero A/B
.deduct
  STA $3D98,Y     ; update monster GP
  LDA $EE         ; tossed coins
.toss_em
  LDX $3B18,Y     ; attacker's level.
  STX $E8         ; save multiplier
  JSR $47B7       ; (stamina * 10) * level
  SEP #$20        ; 8-bit A
  LDA $3EC9 : INC ; number of targets + 1
  XBA             ; store ^ in B
  LDA #$02        ; multiplier
  JSR $4781       ; (targets + 1) * 2 TODO: Why not ASL?
  TAX             ; set divisor
  REP #$20        ; 16-bit A
  LDA $E8         ; total damage
  JSR $4792       ; divide by ((targets + 1) * 2)
  STA $11B0       ; set damage
  RTS

BlindHelp:
  LDA $3EE4,X      ; attacker status byte 1
  LSR              ; C: "Blind"
  BCC .not_blind   ; branch if not ^
  LDA $11A7        ; attack flags
  BIT #$04         ; "Stamina-Based" (BNW flag)
  BNE .low_hit     ; branch if ^ (blind affects)
  LDA $11A2        ; attack flags
  LSR              ; C: "Physical"
  BCC .normal      ; branch if not ^ (blind does not affect)
.low_hit
  LDA #$32         ; set hitrate to 50% (for blind)
  RTS              ; skip "Hit in Back" check when blind
.not_blind
  REP #$20         ; 16-bit A
  LDA $3018,Y      ; target bitmask
  BIT $3A54        ; "Hit in Back"
  SEP #$20         ; 8-bit A
  BEQ .normal      ; branch if not ^
  LDA #$FF         ; max hitrate
  BRA .exit        ; branch to exit
.normal
  LDA $11A8        ; hit rate
.exit
  RTS

; -------------------------------------------------------------------------
; X-Magic Counter Helpers

org $C26744
XMagHelp:
  LDA $04,S         ; attacker index
  TAX               ; index it
  LDA $32CC,X       ; entrypoint to linked list queue
  INC               ; null check (always null unless X-Magic)
  BNE XMagCntr_exit ; branch if not null ^ [TODO: use local RTS]
  JMP PrepCounter   ; else, prep counterattacks
  RTS

XMagCntr:
  LDA $04,S         ; attacker index
  TAY               ; index it
  LDA $32CC,Y       ; entrypoint to linked list queue
  INC               ; null check (always null unless X-Magic)
  BNE .exit         ; branch if not null ^
  ASL $32E0,X       ; shift out "counterattack check pending"
  LSR $32E0,X       ; remove ^
.exit
  RTS

; -------------------------------------------------------------------------
; Helpers for Enemy Special status attacks

org $C26761
SpecialAttStam:
  PHA             ; store special attack status byte
  BIT #$80        ; "Death" (BUG: or "Sleep", others)
  BEQ .exit       ; branch if not ^
  LDA #$02        ; "Miss if Death Protection"
  TSB $11A2       ; set ^ attack flag
.exit
  PLA             ; restore attack status byte
  JSR StamSpecial ; set "Stamina" flag if ^
  RTS

; -------------------------------------------------------------------------
; Helpers for condensed spell list hack

org $C26770         ; 64 bytes needed, used through $C2FAEF
calcMPCost:
  CMP #$0C          ; coming in, low byte is command and high byte is spell ID
  BEQ .lore         ; branch if it's Lore
.calculateMagic
  XBA               ; get attack #
  CMP #$F0          ; is it a Desperation Attack or an Interceptor counter?
  BCS .returnZero   ; if so, exit
  STA $F0           ; save our spell ID in scratch memory
  TDC
  LDA #$04          ; four bytes per index, and we're starting at the second index in
                    ; the list (i.e. the first Magic spell)
.loreEntersHere
  REP #$20
  CLC
  ADC $302C,X       ; get the start of our character's magic list (index #0 is esper)
  STA $F2           ; this points out our first Magic slot
  INC #3
  STA $F4           ; and this points at our first MP cost slot
  SEP #$20
  PHY
  LDY $00
.findSpell
  LDA ($F2),Y       ; spell ID in slot
  CMP $F0           ; does it match our spell?
  BEQ .getMPCost    ; branch if ^
  INY #4            ; next spell to check
  BRA .findSpell    ; loop till spell is found
.getMPCost
  LDA ($F4),Y       ; spell's mp cost
  PLY
  BRA .exitWithMP   ; exit
.lore
  XBA               ; (get attack #), high byte is command and low byte is attack ID
  SEC
  SBC #$8B          ; turn our raw spell ID into a 0-23 Lore ID
  STA $F0           ; set spell ID
  TDC
  LDA #$DC          ; this is our first Lore slot in the character's spell list
  BRA .loreEntersHere
.returnZero
  TDC
.exitWithMP
  JMP $4F54         ; (clean up stack and exit)

; -------------------------------------------------------------------------
; Helper for ATB Autofill (for Quicksteal)

org $C267B0
CheckCantrip:
  PHA               ; save A (new ATB value)
  LDA $3AA1,X       ; special state flags
  BIT #$0008        ; "ATB Autofill"
  BEQ .exit         ; exit if no ^
  AND #$FFF7        ; clear "ATB Autofill" flag
  STA $3AA1,X       ; update special state flags
  SEC               ; Set ATB to fill immediately
.exit
  PLA               ; restore A (new ATB value)
  STA $3218,X       ; [displaced] save new ATB value
  RTS

; -------------------------------------------------------------------------
; Helper for Stamina Evasion

org $C267C5
StamEvd:
  JSR $4B5A       ; random(0..255)
  AND #$7F        ; random(0..127)
  STA $EE         ; save ^
  LDA $3B40,Y     ; target's stamina
  CMP $EE         ; >= random(0..127)
  BCC .exit       ; exit if not ^
  LDA $11A6       ; attack power
  BEQ .miss       ; miss if no ^ (and Stamina evade)
  LDA $11A4       ; attack flags
  AND #$84        ; "Fractional", "Redirection"
  BNE .miss       ; miss if ^ (and Stamina evade)
  LDA $11A3       ; attack flags
  AND #$80        ; "MP Damage"
  BNE .miss       ; miss if ^ (and Stamina evade)
  LDX #$03        ; else, strip statuses off the attack (BUG)
.loop
  STZ $11AA,X     ; clear status attack byte
  DEX             ; next status byte index
  BPL .loop       ; clear all 4 status bytes
  CLC             ; clear carry to direct through regular hit evasion
  RTS
.miss
  SEC             ; C: attack misses completely
.exit
  RTS

; -------------------------------------------------------------------------
; Helper for Blackbelt Counter chance

org $C267F2
StamCounter:
  LDA $3B40,X       ; Stamina
  CLC               ; clear carry
  ADC #$20          ; Stamina + 32
  STA $10           ; store in scratch RAM ^
  LDA #$81          ; 129
  JSR $4B65         ; random(0..128)
  RTS

; #########################################################################
; Freespace

; -------------------------------------------------------------------------
; Morph damage taken helper

org $C2A65A
MorphDmg:
  CMP #$60          ; target stamina > 96
  BCC .store        ; branch if not ^
  LDA #$60          ; else use max 96
.store
  STA $E8           ; store stamina as multiplier
  REP #$20          ; 16-bit A
  ASL $F0           ; dmg * 2
  LDA $F0           ; doubled damage
  JSR $47B7         ; dmg * 2 * stamina / 256
  PHA               ; store result ^
  LDA $F0           ; dmg * 2
  SBC $01,S         ; dmg * 2 - result from above.
  STA $F0           ; update damage
  PLA               ; clean up stack
  RTS

; #########################################################################
; Esper Level and Experience Messages
;
; dn's "Scan Status" patch modifies the message ID for one of
; the new battle messages.

org $C2A674
Calc_EP:
  PHP               ; store flags
  SEP #$20          ; 8-bit A
  LDA $FB           ; spell points gained
  STA $E8           ; save multiplier
  BEQ .zero         ; branch if zero ^
  REP #$20          ; 16-bit A
  LDA $2F35         ; XP gained from battle
  LSR               ; / 2
  LSR               ; / 4
  LSR               ; / 8
  JSR $47B7         ; $E8 = XP/8 * SP
.zero
  PLP               ; restore flags
  RTS

Add_EP:
  PHP               ; store flags
  SEP #$20          ; 8-bit A
  LDA $161E,X       ; equipped esper
  BMI .no_ep        ; branch if null ^
  TDC               ; zero A/B
  LDA $3ED8,Y       ; character ID (00 = Terra, 01 = Locke, etc.)
  PHY               ; store Y
  TAY               ; index to character
  LDA $FB           ; spell points gained
  CLC               ; clear carry
  ADC !spell_bank,Y ; add spell points gained to current SP bank
  CMP #$1E          ; at max (30)
  BCC .set_sp       ; branch if not ^
  LDA #$1E          ; else use max SP (30)
.set_sp
  STA !spell_bank,Y ; save new banked SP
  TYA               ; character ID
  ASL               ; x2
  TAY               ; index it
  JSR Calc_EP       ; $E8 = EP gained
  REP #$20          ; 16-bit A
  LDA $E8           ; EP gained
  CLC               ; clear carry
  ADC !EP,Y         ; add to character's EP
  CMP #$C350        ; at max (50,000)
  BCC .set_ep       ; branch if not ^
  LDA #$C350        ; else, use max EP (50,000)
.set_ep
  STA !EP,Y         ; save new EP total
  PLY               ; restore Y
.no_ep
  PLP               ; restore flags
  REP #$21          ; [displaced] 16-bit A, clear carry (preps ADC)
  LDA $2F35         ; [displaced] gained XP
  RTS

Show_EL:
  JSR $606D         ; [displaced] check for level-up
  PHP               ; store flags
  PHX               ; store X
  PHY               ; store Y
  TDC               ; zero A/B
  SEP #$20          ; 8-bit A
  LDA #$2E          ; "Gained an EL" message
  STA $F2           ; set message pending
.el_check
  LDA $3ED8,Y       ; character ID (00 = Terra, 01 = Locke, etc.)
  CMP #$0C          ; Gogo or higher
  BCS .exit         ; exit if ^
  TAY               ; index character ID
  LDA !EL,Y         ; esper level
  CMP #$19          ; at max EL (25)
  BCS .exit         ; exit if ^
  ASL               ; x2
  TAX               ; index to EP lookup
  PHY               ; store character ID
  TYA               ; character ID
  ASL               ; x2
  TAY               ; index it
  REP #$20          ; 16-bit A
  LDA !EP,Y         ; character's total EP
  CMP EP_Chart,X    ; enough EP to level-up?
  PLX               ; get character ID (00 = Terra, 01 = Locke, etc.)
  BCC .exit         ; exit if not enough EP to level-up
  INC !EL,X         ; EL + 1
  INC !EL_bank,X    ; Available EL + 1
  LDA $01,S         ; get original Y from stack
  TAY               ; index it [TODO: Not needed]
  SEP #$20          ; 8-bit A
  LDA $F2           ; "EL gained" message still pending
  BEQ .skip         ; branch if not ^
  STZ $F2           ; else, zero pending flag
  LDA #$46          ; load message ID [TODO: Replace 2E above?]
  JSR $5FD4         ; buffer and display message ^
.skip
  BRA .el_check     ; loop until all ELs are gained (if multiple)
.exit
  PLY               ; restore Y
  PLX               ; restore X
  PLP               ; restore flags
  RTS

Show_EP:
  JSR $5FD4         ; [displaced]
  LDA $F1           ; espers have been acquired
  BEQ .exit         ; exit if not ^
  JSR Calc_EP       ; $E8 = gained EP
  LDA $E8           ; ^
  BEQ .exit         ; exit if none ^
  LDA $2F35         ; XP gained
  PHA               ; store on stack
  LDA $2F37         ; XP gained hibyte
  PHA               ; store on stack
  STZ $2F37         ; zero hibyte
  STZ $2F36         ; zero midbyte
  LDA $E8           ; gained EP
  STA $2F35         ; store EP gained for display
  LDA #$0045        ; "EP Gained" message ID
  JSR $5FD4         ; buffer and display message ^
  PLA               ; restore XP gained hibyte
  STA $2F37         ; save ^
  PLA               ; restore XP gained midbyte
  STA $2F35         ; save ^
.exit
  RTS

; #########################################################################
; Helpers in Freespace

org $C2A742
GauRageStatuses:
  STA $3C6C,Y
  LDA $CF0014,X   ; blocked status bytes 1-2
  AND $331C,Y     ; and with the original status weaknesses
  EOR #$FFFF      ; invert 'em to get statuses to clear
  AND $3EE4,Y     ; and with current status
  STA $3EE4,Y     ; update current status
  RTS
  
GauRageStatuses2:
  STA $3C6C,X
  AND $3EE5,X     ; equipment status byte 2 AND current status = status to actually have
  STA $3EE5,X
  LDA $D4
  AND $3EF8,X     ; equip status byte 3 and current status 3
  STA $3EF8,X
  LDA $3EF9,X     ; load float byte
  AND #$7F        ; no float
  STA $3EF9,X
  RTS

; -------------------------------------------------------------------------
; Alters the random variance formula to consider the target's vigor or
; stamina in calculating the variance range
;
; Damage = (Damage * [(225 - 3/4 VigStam) .. (255 - VigStam)] / 225) + 1

org $C2A770
NewVariance:
  LDA $11A4      ; attack flags-3
  LSR            ; C: "Healing"
  BCS .old_var   ; branch if ^
  CPY #$08       ; target is monster
  BCS .old_var   ; branch if ^
  PHP            ; store flags
  TDC            ; zero A/B
  LDA $11A2      ; attack flags-1
  LSR            ; C: "Physical"
  LDA $3B40,Y    ; target's Stamina
  BCC .variance  ; use Stamina if not "Physical"
  LDA $3B2C,Y    ; else, load target's Vigor (x2)
  LSR            ; / 2 to get real Vigor value
.variance
  PHA            ; store defense stat
  ASL            ; x2
  ADC $01,S      ; x3
  LSR #2         ; stat * 3/4
  STA $E8        ; save in scratch ^
  LDA #$E1       ; 225
  SEC            ; set carry
  SBC $E8        ; 225 - (stat * 3/4)
  STA $E8        ; save ^
  PLA            ; restore defense stat
  EOR #$FF       ; 255 - stat
  SEC            ; set carry
  SBC $E8        ; variance cap - floor
  BCC .multiply  ; branch if floor is larger than the cap
  INC            ; +1
  JSR $4B65      ; random(cap - floor + 1)
  CLC            ; clear carry
  ADC $E8        ; get variance value
  STA $E8        ; save multiplier
.multiply 
  REP #$20       ; 16-bit A
  LDA $F0        ; maximum damage
  JSR $47B7      ; max damage * random variance
  LDA $E8        ; lower 16-bits of product
  PHX            ; store X
  LDX #$E1       ; divisor (225)
  JSR $4792      ; divide lower 16-bits by ^
  STA $F0        ; save tentative final dmg
  CLC            ; clear carry
  LDX $EA        ; check for overflow from multiplication
  BEQ .exit      ; exit if none ^
.loop
  LDA #$0123     ; overflow increment value: 291 (65536 / 225)
  ADC $F0        ; add to damage
  STA $F0        ; update damage
  DEX            ; decrement overflow iterator
  BNE .loop      ; loop till all overflow handled
.exit
  INC $F0        ; damage + 1
  PLX            ; restore X
  PLP            ; restore flags
  JMP AfterVar   ; jump back to damage mod routine
.old_var
  JSR $4B5A      ; random(256)
  JMP OldVariance; jump back to damage mod routine




; -------------------------------------------------------------------------
org $C2A7DD
DmgCmdAlias:
  PHA                ; store target data
  SEP #$20           ; 8-bit A
  LDA $11A3          ; N: "MP Dmg"
  REP #$20           ; 16-bit A
  BPL .hp_dmg        ; branch if not ^
  PLA                ; restore target data
  ORA #$0005         ; set "MP Dmg" alias cmd
  RTS
.hp_dmg
  PLA                ; restore target data
  ORA #$000B         ; set "HP Dmg" dynamics command
  RTS

DmgCmdAliasMass:
  PHA                ; store battle dynamics command ($03)
  LDA $11A3          ; N: "MP Dmg"
  BPL .done          ; branch if not ^
  PLA                ; clean up stack
  LDA #$08           ; battle dynamics command for MP
  BRA .exit          ; branch to exit
.done
  PLA                ; restore battle dynamics command
.exit
  JMP $629B          ; finish up
warnpc $C2A800+1

; #########################################################################
; Slot Reel Layout
; Modified to be consistent for de-rigged slots

!slot_seven = $0000
!slot_bahamut = $0001
!slot_bar = $0002
!slot_blackjack = $0003
!slot_chocobo = $0004
!slot_diamond = $0005

; Reel 1
dw !slot_seven
dw !slot_bar
dw !slot_chocobo
dw !slot_chocobo
dw !slot_chocobo
dw !slot_bar
dw !slot_bar
dw !slot_diamond
dw !slot_diamond
dw !slot_diamond
dw !slot_bar
dw !slot_bar
dw !slot_blackjack
dw !slot_blackjack
dw !slot_blackjack
dw !slot_bar

; Reel 2
dw !slot_seven
dw !slot_bar
dw !slot_blackjack
dw !slot_blackjack
dw !slot_blackjack
dw !slot_bar
dw !slot_bar
dw !slot_chocobo
dw !slot_chocobo
dw !slot_chocobo
dw !slot_bar
dw !slot_bar
dw !slot_diamond
dw !slot_diamond
dw !slot_diamond
dw !slot_bar

; Reel 3
dw !slot_seven
dw !slot_bar
dw !slot_diamond
dw !slot_diamond
dw !slot_diamond
dw !slot_bar
dw !slot_bar
dw !slot_blackjack
dw !slot_blackjack
dw !slot_blackjack
dw !slot_bar
dw !slot_bar
dw !slot_chocobo
dw !slot_chocobo
dw !slot_chocobo
dw !slot_bar

; #########################################################################
; TODO: This is not freespace -- it is data. This helper should be
; moved to actual freespace ASAP

org $C2A8D2
ExploderHelp:
  TDC                ; zero A/B
  CPY #$08           ; Check if monster
  BCS .exit          ; branch if ^
  LDA $11A6          ; else, use Spell Power as multiplier
.exit
  STA $BC            ; store multiplier (incrementer)
  TYX                ; attacker index
  RTS

; #########################################################################
; Status Text Tile Data
; $20-$23 = Regen
; $24-$25 = Sap
; $20, $26-$28 = Rerise

org $C2ADE1
  db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF    ; nothing
  db $20,$21,$22,$23,$FF,$FF,$FF,$FF,$FF,$FF    ; Regen
  db $20,$26,$27,$28,$FF,$FF,$FF,$FF,$FF,$FF    ; Rerise
  db $20,$21,$22,$23,$20,$26,$27,$28,$FF,$FF    ; Regen, Rerise
  db $24,$25,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF    ; Sap
  db $82,$87,$84,$80,$93,$84,$91,$FF,$FF,$FF    ; Sap, Regen
  db $24,$25,$FF,$20,$26,$27,$28,$FF,$FF,$FF    ; Sap, Rerise
  db $82,$87,$84,$80,$93,$84,$91,$FF,$FF,$FF    ; Sap, Rerise, Regen

; #########################################################################
; Slot Attack Selection based on Reels

; Disables 7-7-Bar results
; 12 bytes freed up at $C2B4B2
org $C2B4AF : LDA #$07 : RTL

; #########################################################################
; RNG

org $C2BBEC : JSL Random
org $C2BC9B : JSL Random

; #########################################################################
; Palette Data for Various Animations
;
; Modify palette for MP damage, part of "MP Colors" patch

org $C2C6A1 : db $63,$14,$41,$7F,$E0,$03,$00,$7F

; #########################################################################
; The code, pointers, and text for summon descriptions (C4) is in a
; region of the ROM usually utilized for graphics data, and it just so
; happens that the Esper summon drawer in combat has some sort of label
; in it that points to this region of the ROM for its glyphs.
;
; It is normally invisible, since this region is empty, but since
; I added a bunch of stuff here, it ends up displaying a couple of
; tiles of gibberish instead. This change just prevents these tiles
; from displaying at all.

org $C2E092 : db $03,$8C,$03,$8F,$FF,$16,$00,$00         
                ; 03  2C  03  2F  FF  16  00  00

; #########################################################################
; Sketch Animation Helper
;
; Modified by Assassin's "Sketch Fix" patch, which is actually only half
; complete. However, the change here is enough to avoid the dangerous
; aspects of the Sketch Bug. For complete fix, requires C1 changes, too

org $C2F592 : BraToHere:
org $C2F5C6
SketchFix:
  BRA BraToHere    ; branch to duplicate code to make room
  NOP #7
.done
  JMP $F809
.starthere
  LDY #$2800       ; [?]
  JSL $C1B109      ; [?]
  LDA #$01         ; [?]
  TRB $898D        ; [?]
  LDY #$0003       ; target arg
  LDA ($76),Y      ; get sketch target (could be null)
  ASL              ; x2, C: null target
  TAX              ; index it
  REP #$20         ; 16-bit A
  LDA $2001,X      ; enemy ID
  BCC .safe        ; branch if not null
  TDC              ; zero A/B
  DEC              ; $FFFF (null)
.safe
  TAX              ; index enemy ID
  TDC              ; zero A/B
  SEP #$20         ; 8-bit A
  JSL $C124D1
  BRA .done

; #########################################################################
; Freespace used for various helper functions

org $C2FAA4
ATBInitHelp:
  ADC $3B19,Y     ; A = random: Speed to (2 * Speed + 29)
  BCS .cap        ; branch if exceeded 255
  ADC $3B19,Y     ; A = random: (2 * Speed) to (3 * Speed + 29)
  BCS .cap        ; branch if exceeded 255
  JMP InitializeATBTimers_after_help
.cap
  JMP InitializeATBTimers_max_atb

; -------------------------------------------------------------------------
; Runic helper to ignore elemental effects and +25% magic dmg flag

RunicHelper:
  STZ $3414       ; Skip damage modification
  STZ $11A1       ; Zero out elemental properties
  LDA #$80
  STA $11A7       ; Zero out special byte 3
  RTS

; -------------------------------------------------------------------------

RunicCheck:
  LDA $3BA4,Y    ; right-hand special properties
  ORA $3BA5,Y    ; left-hand special properties
  BMI .exit      ; exit if either allow Runic
  JMP $054F      ; else, disable command
.exit
  TDC            ; zero A/B (subcommand, to be safe)
  RTS 
warnpc $C2FACD+1

; -------------------------------------------------------------------------
; Smart Cover and Tank 'n Spank Helpers

org $C2FAD0
SmartCover:
  BEQ .exit           ; exit if no intended targets (from $B8)
  LDY #$FF            ; null
  STY $F4             ; default to no bodyguards.
  JSR $51F9           ; Y = index of our highest intended target
  STY $F8             ; save target index
  STZ $F2             ; highest bodyguard HP = 0
  PHX                 ; store attacker index
  LDX $336C,Y         ; Love Token - which target takes damage for you
  BMI .noLove         ; branch if none ^
  JSR EvalKnight_skip ; always consider Love Token target as a bodyguard
  JSR Intercept       ; if it was valid, make it intercept the attack  
.noLove
  PLX                 ; restore attacker index
  LDA $3A36           ; Golem HP
  BNE .exit           ; exit if Golem is active
  CPX #$08            ; attacker is a monster
  BCS .status         ; branch if ^
  CPX $F8             ; is attacker the target
  BEQ .exit           ; exit if ^
  LDA $3EE4,X         ; attacker status byte 1-2
  BIT #$2002          ; "Muddle", "Zombie"
  BNE .heals          ; branch if ^
  LDA $3394,X         ; Charm - which entity charmed the attacker
  BMI .exit           ; exit if not ^ (attack was initiated by player)
.heals
  LDA $11A9           ; special effect byte
  AND #$00FF          ; isolate ^
  CMP #$0018          ; "Curative Attributes" (eg. healing shiv)
  BEQ .exit           ; exit if ^
  SEP #$20            ; 8-bit A
  LDA $11A1           ; attack element(s)
  PHA                 ; store ^ on stack
  XBA                 ; store ^ in B
  PLA                 ; restore copy of elements
  REP #$20            ; 16-bit A
  AND $3BCC,Y         ; target absorbed/immune elements
  BNE .exit           ; exit if any absorbed or nullified
.status
  LDA $3EE4,Y         ; target status byte 1-2
  BIT #$04DA          ; "Death", "Petrify", "Clear", "Zombie", "Magitek", "Image"
  BNE .exit           ; exit if ^
.seize
  LDA $3358,Y         ; $3359 = who is Seizing you
  BPL .exit           ; exit if target is seized
  LDA #$000F          ; load all characters as potential bodyguards        
.cover
  CPY #$08            ; target is monster
  BCC .saveBg         ; branch if not ^
  TDC                 ; zero A/B
.saveBg
  STA $F0             ; save potential bodyguards
  LDA $3018,Y         ; target bit
  ORA $3018,X         ; attacker bit
  TRB $F0             ; remove attacker and target from bodyguard pool
  JMP TrueKnight_jmp  ; jump back to resume in-place cover routine
.exit
  PLX                 ; restore attack index
  RTS

; -------------------------------------------------------------------------
; Helper to halve evasion for bodyguards

HalveEvasion:
  CPY $F4             ; is target a bodyguard
  BNE .exit           ; exit if not ^
  LDA #$FF            ; 255
  SEC                 ; set carry
  SBC $3B54,Y         ; 255 - (255 - Evade * 2 + 1) [= Evade * 2 - 1]
  INC                 ; Evade * 2
  LSR                 ; Evade
  LSR                 ; Evade / 2
  JMP $2861           ; recompute blockvalue from halved Evade
.exit
  LDA $3B54,Y         ; use full evasion (255 - Evade * 2 + 1)
  RTS

; -------------------------------------------------------------------------
; Helper to prevent Dog Block for bodyguards

SkipDogBlock:
  CPY $F4             ; is target a bodyguard
  BNE .exit           ; exit if not ^
  CLC                 ; else, clear carry (no dog block)
  RTS
.exit
  JMP $4B53           ; carry: 50% chance of dog block

; -------------------------------------------------------------------------
; Poison status on-clear helper to reset damage incrementor

org $C2FBC6
Poison:
  PHP
  SEP #$20
  LDA #$00
  STA $3E24,Y    ; zero poison damage incrementer
  PLP
  RTS

; -------------------------------------------------------------------------
; Helper for Throw weapon properties loading

org $C2FBD0
ThrowProps:
  PHP            ; store flags
  STA $11A1      ; [displaced] store element
  LDA $D8501B,X  ; special action (weapon)
  AND #$F0       ; isolate ^
  LSR #3         ; shift down to x2 index
  STA $11A9      ; save ^
  STZ $11A4      ; clear "Can't be Dodged"
  LDA #$FF       ; 255
  STA $11A8      ; set max hit rate (100% hitrate unless Blind)
  PLP            ; restore flags
  RTS

; -------------------------------------------------------------------------
; Long access to random in range routine

org $C2FBEA
RandomRange:
  JSR $4B65
  RTL

; -------------------------------------------------------------------------

org $C2FBEE
AtmaStat:
  STA $11A9      ; [moved] Set special effect
  CMP #$04       ; "Atma Weapon"
  BNE .exit      ; exit if not ^
  LDA $3B40,X    ; attacker's stamina
  ASL            ; x2
  STA $11AE      ; set damage stat (Vigor is also x2 normally)
.exit
  RTS

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
warnpc $C2FC10+1

org $C2FC17
EnemyAbort:
  LDA $11A4      ; attack flags
  ASL #2         ; C: "Abort on Enemies" (new BNW flag)
  BCC .exit      ; exit if not ^
  STZ $B9        ; else, clear enemy targets
.exit
  JMP $5917      ; [moved]

ItemAbortEnemy:
  TRB $11A2      ; [moved]
  LDA $03,S      ; item ID
  CMP #$E7       ; start of consumable items range
  BCC .abort     ; branch if before ^ (all equipment, esp. breakable rods)
  CMP #$F0       ; "Phoenix Down"
  BEQ .abort     ; branch if ^
  CMP #$F1       ; "Holy Water"
  BEQ .abort     ; branch if ^
  CMP #$F9       ; "Phoenix Tear"
  BEQ .abort     ; branch if ^
  RTS
.abort
  LDA #$40       ; "Abort on Enemies" (replaces L? Spell flag)
  TSB $11A4      ; set ^
  RTS
warnpc $C2FC3F+1

; -------------------------------------------------------------------------
; Quake Special Effect (per-strike)
; Untarget Floating targets, except if all targets are Floating

GroundDmg:
  REP #$20        ; 16-bit A
  LDA $A2         ; targets
  STA $EE         ; backup ^ in scratch
  LDX #$12        ; iterator for all entities
.loop
  LDA $3EF8,X     ; entity status bytes 3-4
  BPL .next       ; branch if no "Float"
  LDA $3018,X     ; entity bit
  TRB $EE         ; remove ^ from targets
.next
  DEX #2          ; next entity
  BPL .loop       ; loop through all 10 entities
  LDA $EE         ; remaining targets
  BNE .save       ; branch if any ^ (and use as targets)
  LDA #$0080      ; "Respect Clear"
  TRB $B3         ; else, remove ^
  LDA $A2         ; and use all original targets
.save
  STA $B8         ; set filtered targets
  TYX             ; attacker index
  JMP $57C2       ; update targets [?]

; -------------------------------------------------------------------------

org $C2FCCD
LongByteMod:
  JSR $5217      ; X: byte index, A: bitmask for bit in byte
  RTL
warnpc $C2FCD1+1


