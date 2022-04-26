hirom

; C2 Bank

; #########################################################################
; Part of Attack Prep (Imp command disabling used as Freespace)
;
; Note, assumes no more than 1 overflow in $EA from multiplication

org $C202AD
AtmaOver:
  TDC : DEC         ; $FFFF
  JSR $4792         ; 65535 / (maxHP / 256 + 1)
  CLC : ADC $F0     ; add to final damage
  STA $F0           ; update final damage
  RTS
warnpc $C202B8+1

; #########################################################################
; Adding Command to Wait Queue + Swap Roulette to Enemy Roulette
;
; End of adding command routine is overwritten by "Dies like a Boss" hack,
; which appears to be using it as freespace. This space is made available
; by the "roulette" patch, which has not been incorporated here yet. TODO
;
; Note that the "Swap Roulette" routine portion is definitely freespace
; in BNW, as roulette is unused.

org $C203B6
BossDeath:
  LDA $3C95,Y      ; special monster flags
  AND #$0040       ; "Boss" (formerly "Auto crit if Imp")
  BEQ .death       ; branch if not ^
  RTS              ; else, exit now to prevent bosses from dying from HP loss
.death
  LDA #$0080       ; "Death" status
  JMP $0E32        ; add ^ to status-to-set byte 1

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
  dw $0557        ; Morph
  dw $0584        ; MagiTek
  dw $058D        ; Tools
  dw RunicCheck   ; Runic
  dw MuddleSketch ; Sketch
  dw $FFFF        ; Currently unused
  dw $FFFF        ; Currently unused
warnpc $C204F6+1

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
; Process HP and MP Damage
;
; Never set "Death" from HP depletion on bosses. Instead, all boss deaths
; are handled via their AI script. This prevents a bug whereby some non-
; counterable sources of HP loss could bypass special boss death handling,
; messages, and animation.

org $C213A1 : JMP BossDeath

; #########################################################################
; Jump (command)
;
; Modified by dn's "Blind Jump Fix" patch to make "Blind" affect Jump
; command. Further modified by Synchysi so ensure row is ignored still.

org $C2180B : JSL C3_BlindJump : NOP ; helper routine in C3

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
; GP Rain (command)
;
; Modified by Synchysi's Blind patch

org $C21908 : JSR CoinHelp

; #########################################################################
; Hit Determination
;
; Modified by Synchysi's "Blind" patch
;   Have Blind status apply on skills with 255 hit rate and sets the
;   accuracy of a blinded attacker to 50%

org $C222D1 : Miss:   ; Code for missed attack

org $C22306
BlindPatch:
  JSR BlindHelp
  BRA .skip_ahead
org $C22315
.skip_ahead

; Terii Senshi evasion bugfix, with modification to Image removal
org $C2232C
  BEQ .no_img  ; Branch if the target does not have Image status
  JSR $4B5A    ; random(255)
  CMP #$56     ; 33% chance to clear Image status
  BCS Miss     ; branch if not ^
  LDA $3DFD,Y  ; status-to-clear-2
  ORA #$04     ; add "Image"
  STA $3DFD,Y  ; update status-to-clear-2
  BRA Miss     ; branch to miss
warnpc $C2233F+1
org $C2233F
.magic_evd_fork
  LDA $3B55,Y  ; 255 - (MBlock *2) + 1
  PHA          ; store hitrate
  BRA HitCalc  ; branch to calculate
.no_img
  LDA $3B54,Y  ; Handled in sei_tank_n_spank.asm (TODO Integrate)
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
;
; Modified as part of "Abort on Enemies" patch to prevent most items and
; rods from being targeted at enemies. (Synchysi)

org $C22A78 : JSR ItemAbortEnemy ; Set "abort-on-enemies" flag for many items

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
; Combat Routine

org $C233BA : JSR SetTarget ; Enable target's counterattack, even if we miss
org $C2343C : JSR CounterMiss : NOP ; Set counter variables early TODO [overwritten]

; #########################################################################
; Weapon Addition Magic

org $C2381D :  JSL AutoCritProcs ; power-up crit doom to x-zone, multitarget quartr

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
  JMP $4E91
padbyte $FF
pad $C23C6E
warnpc $C23C6E+1

; #########################################################################
; Old Air Anchor Routine (now freespace)

org $C23C78
ChangeShld:
  LDA #$01         ; "shield uncursed"
  TSB $F0          ; set ^ flag
  LDA #$67         ; "Paladin Shield" ID
  STA $161F,X      ; replace equipped shield
  RTS
warnpc $C23C90+1

; #########################################################################
; Old GP Toss Routine (now freespace)

org $C23FB7
warnpc $C23FFC+1

; #########################################################################
; Spiraler (per-strike special effect)
;
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

org $C24383 : dw CoinToss ; Effect $51 ($C33FB7 now unused)

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

; #########################################################################
; Special Checks for End-of-Battle
;
; Allows partial party engulfs to still transport the party to Gogo's Cave
org $C24816 : NOP #5

; #########################################################################
; Prepare Counterattacks (C24C5B)

org $C24C5B
PrepareCounterattacks:     ; set parent label for full routine
org $C24CC2 : .no_counter
org $C24CDD : BNE .counter ; skip blackbelt check for "damaged this turn"
org $C24CE3 : BCC .counter ; skip blackbelt check for "damaged this turn"
org $C24CFC : .counter
org $C24D03
  JSR $4B53         ; C: 50% chance to counter (75% in vanilla)
  BCS .no_counter   ; branch ^
  NOP #2            ; [unused]

; #########################################################################
; Scan Command (partial)
;
; Modified by dn's "Scan Status" patch to add support for Status messages.
; The "Scan Weakness" code is now displaced into C4 along with the new
; "Scan Status" code.

org $C25138
  JSL ScanWeakness
  JSL ScanStatus
  RTS
padbyte $FF
pad $C25161
warnpc $C25161+1

; #########################################################################
; Determine which menu commands are disabled
;
; Largely rewritten as part of Assassin's "Brushless Sketch" patch to
; disable the "Sketch" command when no brush is equipped.

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
  BEQ .skip_imp      ; branch if not ^
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

SketchHelp:
  LDA $EF        ; disabled commands
  LSR            ; C: Sketch Invalid
  RTS
warnpc $C25301+1

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
  LDA $11E4         ; battle flags
  BIT #$02          ; "Leap Available"
  BRA .may_null     ; null if not ^
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
; Victorious Combat (C25D91)

; Make EP gains display after combat
org $C25E0B : JSR Show_EP

org $C25E31      ; freespace in middle of end-of-battle routine [TODO]
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
; Add Experience after Battle

; Interrupt leveling routine to calculate EP
org $C26236 : JSR Add_EP : NOP #2

; #########################################################################
; Damage Number Processing and Queuing Animation(s)
;
; Part of "MP Colors" patch, Fork which battle dynamics command ID
; based on MP flag

org $C263A9 : JSR DmgCmdAlias
org $C263BB : JSR DmgCmdAliasMass

; #########################################################################
; Freespace (C26469-C26800)

org $C26642
SketchChk:         ; function defined in sketch_fix.asm [?]

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
warnpc $C266A3+1 ; TODO: Confirm this end offset

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
; Palette Data for Various Animations
;
; Modify palette for MP damage, part of "MP Colors" patch

org $C2C6A1 : db $63,$14,$41,$7F,$E0,$03,$00,$7F

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
warnpc $C2FAB4+1

org $C2FAC0
RunicCheck:
  LDA $3BA4,Y    ; right-hand special properties
  ORA $3BA5,Y    ; left-hand special properties
  BMI .exit      ; exit if either allow Runic
  JMP $054F      ; else, disable command
.exit
  TDC            ; zero A/B (subcommand, to be safe)
  RTS 
warnpc $C2FACD+1

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

org $C2FCCD
LongByteMod:
  JSR $5217      ; X: byte index, A: bitmask for bit in byte
  RTL
warnpc $C2FCD1+1


