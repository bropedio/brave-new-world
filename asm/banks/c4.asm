hirom

; C4 Bank

; #########################################################################
; Tile Graphics for new Status Text tiles (Sap/Regen/Rerise)

org $C481C0
  db $F0,$E0,$F8,$90,$DB,$93,$FF,$E4,$F7,$A7,$FF,$94,$DF,$93,$DB,$00
  db $00,$00,$00,$00,$9C,$18,$FF,$A5,$F7,$25,$BF,$1D,$DF,$84,$DE,$18
  db $00,$00,$00,$00,$EF,$CA,$FF,$2D,$FF,$C9,$ED,$09,$FD,$E9,$FD,$00
  db $00,$00,$00,$00,$00,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00
  db $70,$70,$F0,$80,$C3,$83,$F7,$64,$7E,$14,$1E,$14,$FF,$E3,$F3,$00
  db $00,$00,$00,$00,$9E,$1C,$DF,$92,$DB,$92,$DF,$9C,$FE,$50,$78,$10
  db $00,$00,$03,$02,$BF,$28,$FF,$B2,$FB,$22,$33,$22,$F3,$A2,$F3,$00
  db $00,$00,$00,$00,$7B,$73,$FF,$84,$77,$67,$7F,$14,$FF,$E3,$F3,$00
  db $00,$00,$00,$00,$80,$00,$C0,$80,$C0,$00,$00,$00,$C0,$80,$C0,$00
  db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; #########################################################################
; Summon Descriptions LUT and Text (in freespace)

org $C48270           ; big ol' chunk of freespace :D

InitEsperDataSlice:
  LDA #$10            ; Reset/Stop desc
  TSB $45             ; Set menu flag
  LDA $49             ; Top BG1 write row
  STA $5F             ; Save for return
  RTL

EsperDescPointers:
  dw Ramuh
  dw Ifrit
  dw Shiva
  dw Siren
  dw Terrato
  dw Shoat
  dw Maduin
  dw Bismark
  dw Stray
  dw Palidor
  dw Tritoch
  dw Odin
  dw Loki
  dw Bahamut
  dw Crusader
  dw Ragnarok
  dw Alexandr
  dw Kirin
  dw Zoneseek
  dw Carbunkl
  dw Phantom
  dw Seraph
  dw Golem
  dw Unicorn
  dw Fenrir
  dw Starlet
  dw Phoenix

Ramuh: db "Bolt damage - all foes",$00
Ifrit: db "Fire damage - all foes",$00
Shiva: db "Ice damage - all foes",$00
Siren: db "Sets `Bserk^ - all foes",$00
Terrato: db "Earth damage - all foes",$00
Shoat: db "Sets `Petrify^ - all foes",$00
Maduin: db "Wind damage - all foes|Ignores def.",$00
Bismark: db "Water damage - all foes",$00
Stray: db "Stamina-based cure - party|Sets `Regen^",$00
Palidor: db "Party attacks with `Jump^",$00
Tritoch: db "Fire",$C0,"Ice",$C0,"Bolt damage - all foes",$00
Odin: db "Non-elemental dmg - all foes|Stamina-based; ignores def.",$00
Loki: db $00
Bahamut: db "Non-elemental dmg - all foes|Ignores def.",$00
Crusader: db "Dark damage - all foes",$00
Ragnarok: db "9999 damage - one foe",$00
Alexandr: db "Holy damage - all foes",$00
Kirin: db "Cures HP - party|Revives fallen allies",$00
Zoneseek: db "Sets `Shell^ - party",$00
Carbunkl: db "Sets `Rflect^ - party",$00
Phantom: db "Sets `Vanish^ - party",$00
Seraph: db "Sets `Rerise^ - party",$00
Golem: db "Blocks physical attacks|(Durability = caster*s max HP)",$00
Unicorn: db "Stamina-based cure - party|Lifts most bad statuses",$00
Fenrir: db "Sets `Image^ - party",$00
Starlet: db "Cures HP to max - party|Lifts all bad statuses",$00
Phoenix: db "Revives fallen allies - party|(HP = max)",$00

; #########################################################################
; Alphabetical Rage List (also in freespace)

org $C4A7E0
RageList:
db $1D,$22,$E9,$5D,$20,$91,$4F,$4A,$58,$96,$3D,$1F,$08,$62,$7B,$39
db $63,$47,$0C,$89,$D4,$2E,$FE,$48,$EE,$17,$0F,$D0,$55,$D2,$61,$21
db $CE,$03,$41,$70,$6B,$28,$DF,$F1,$75,$72,$5C,$8E,$0B,$13,$05,$01
db $0E,$18,$42,$66,$F2,$5B,$34,$27,$DD,$46,$88,$93,$F8,$87,$F7,$82
warnpc $C4A820+1

; #########################################################################
; Rage and Dance Descriptions

org $C4A820
RageDescs:
  dw .empty
  dw .soldier
  dw .empty
  dw .ninja
  dw .empty
  dw .shokan
  dw .empty
  dw .empty
  dw .conjuror
  dw .empty
  dw .empty
  dw .scrapper
  dw .gargoyle
  dw .empty
  dw .spirit
  dw .lich
  dw .empty
  dw .empty
  dw .empty
  dw .sewer_rat
  dw .empty
  dw .empty
  dw .empty
  dw .leafer
  dw .stray_cat
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .adamantite
  dw .empty
  dw .chimera
  dw .behemoth
  dw .mesosaur
  dw .albatross
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .tyrano
  dw .raven
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .hornet
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .tumbleweed
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .exocite
  dw .empty
  dw .empty
  dw .empty
  dw .chickenlip
  dw .empty
  dw .empty
  dw .empty
  dw .onion_kid
  dw .tek_armor
  dw .empty
  dw .empty
  dw .empty
  dw .vaporite
  dw .flan
  dw .jinn
  dw .empty
  dw .brainpan
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .bomb
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .magic_pot
  dw .empty
  dw .empty
  dw .buffalax
  dw .empty
  dw .empty
  dw .troll
  dw .sand_ray
  dw .antlion
  dw .empty
  dw .empty
  dw .empty
  dw .marlboro
  dw .crawler
  dw .eye_goo
  dw .empty
  dw .empty
  dw .templar
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .rain_man
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .osteosaur
  dw .empty
  dw .rocky
  dw .empty
  dw .empty
  dw .rhydon
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .doggo
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .zombone
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .windrunner
  dw .vulture
  dw .griffin
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .scarab
  dw .empty
  dw .empty
  dw .belladonna
  dw .empty
  dw .weedula
  dw .empty
  dw .empty
  dw .cephalid
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .nastidon
  dw .empty
  dw .locust
  dw .empty
  dw .mantodea
  dw .empty
  dw .grizzly
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .vagrant
  dw .empty
  dw .repo_man
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .anemone
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .kudzu
  dw .empty
  dw .empty
  dw .revenant
  dw .titan
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .witch
  dw .werewolf
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .empty
  dw .io

; #####################################
; Rage description text

.empty
  db $00
.soldier
  db !w,"Cure 2",$01
  db "Attack (2x damage)",$00
.ninja
  db "Wave Scroll",$01
  db "Vanish",$00
.shokan
  db !b,"Dark",$01
  db "Raze",$00
.conjuror
  db !w,"Rerise",$01
  db "Attack (Sap)",$00
.scrapper
  db "Attack (2x damage)",$01
  db "Chakra",$00
.gargoyle
  db "Sun Bath",$01
  db !b,"Quake",$00
.spirit
  db !b,"Demi",$01
  db !b,"Quartr",$00
.lich
  db !g,"Rasp",$01
  db "Elf Fire",$00
.sewer_rat
  db !b,"Poison",$01
  db "Attack (Poison)",$00
.leafer
  db "Wind Slash",$01
  db "Air Blast",$00
.stray_cat
  db "Snowball",$01
  db "Attack (3x damage)",$00
.adamantite
  db "Attack (2x damage)",$01
  db "Holy Wind",$00
.chimera
  db "Aqualung",$01
  db "Fireball",$00
.behemoth
  db "Attack (2x damage)",$01
  db "Meteo",$00
.mesosaur
  db "Holy Wind",$01
  db "Magnitude",$00
.albatross
  db "Fireball",$01
  db "Attack (2x damage)",$00
.tyrano
  db "Attack (3x damage)",$01
  db "Firestorm",$00
.raven
  db !b,"Break",$01
  db "Attack (Sleep)",$00
.hornet
  db "Attack (3x damage)",$01
  db "Blink",$00
.tumbleweed
  db !w,"Cure 3",$01
  db "Attack (Steal HP)",$00
.exocite
  db "Rock",$01
  db "Attack (2x damage)",$00
.chickenlip
  db "Attack (Muddle)",$01
  db "Net",$00
.onion_kid
  db "Brown Note",$01
  db "Attack (Bserk)",$00
.tek_armor
  db "Barrier",$01
  db "Attack (2x damage)",$00
.vaporite
  db "Plasma",$01
  db "Attack (Blind - no dmg)",$00
.flan
  db !w,"Life",$01
  db !g,"SlowX",$00
.jinn
  db "Discord",$01
  db "Attack (Mute)",$00
.brainpan
  db "Blow Fish",$01
  db !w,"Rerise",$00
.bomb
  db "Exploder",$01
  db "Exploder",$00
.magic_pot
  db !w,"Cure",$01
  db "Attack (4x damage)",$00
.buffalax
  db "Landslide",$01
  db "Attack (3x damage)",$00
.troll
  db "Attack (3x damage)",$01
  db "Refract",$00
.sand_ray
  db "Sand Storm",$01
  db "Attack (2x damage)",$00
.antlion
  db "Attack (Stop - no dmg)",$01
  db "Snare",$00
.marlboro
  db "Bio Blast",$01
  db "Bad Breath",$00
.crawler
  db "Magnitude",$01
  db "Attack (Steal HP)",$00
.eye_goo
  db "Lode Stone",$01
  db "Glare",$00
.templar
  db "Attack (3x damage)",$01
  db !w,"Remedy",$00
.rain_man
  db "Acid Rain",$01
  db !b,"Bolt 2",$00
.osteosaur
  db !b,"Doom",$01
  db "Attack (Petrify - no dmg)",$00
.rocky
  db "Harvester",$01
  db "Rock",$00
.rhydon
  db "Attack (2x damage)",$01
  db "Sun Bath",$00
.doggo
  db "Attack (3x damage)",$01
  db "Step Mine",$00
.zombone
  db "Cave In",$01
  db "Attack (Zombie - no dmg)",$00
.windrunner
  db "Aero",$01
  db "Blight",$00
.vulture
  db "Razor Leaf",$01
  db "Harvester",$00
.griffin
  db "Giga Volt",$01
  db "Air Blast",$00
.scarab
  db "Starlight",$01
  db "Mega Volt",$00
.belladonna
  db "Moonlight",$01
  db "Raid",$00
.weedula
  db !b,"Quake",$01
  db "Razor Leaf",$00
.cephalid
  db "Tentacle",$01
  db "Attack (Slow)",$00
.nastidon
  db "Snowball",$01
  db "Absolute 0",$00
.locust
  db "Gale Cut",$01
  db "Mirage",$00
.mantodea
  db "Shrapnel",$01
  db "Attack (Sap)",$00
.grizzly
  db "Cave In",$01
  db "Attack (3x damage)",$00
.vagrant
  db "Flash Rain",$01
  db "Attack (2x damage)",$00
.repo_man
  db "Step Mine",$01
  db "Vanish",$00
.anemone
  db "Discharge",$01
  db "Attack (Poison)",$00
.kudzu
  db "Raid",$01
  db !w,"RegenX",$00
.revenant
  db !b,"Holy",$01
  db "Blaze",$00
.titan
  db "Avalanche",$01
  db "Attack (3x damage)",$00
.witch
  db "Refract",$01
  db !b,"Fire 3",$00
.werewolf
  db "Attack (3x damage)",$01
  db !w,"Regen",$00
.io
  db "Atomic Ray",$01
  db "Diffuser",$00

PrefixA:
  db "66% ",$00
PrefixB:
  db "33% ",$00

; #####################################
; Dance description pointers

DanceDescs:
  dw .wind_song
  dw .forest_suite
  dw .desert_aria
  dw .love_sonata
  dw .earth_blues
  dw .water_rondo
  dw .dusk_requiem
  dw .snowman_jazz

; #####################################
; Dance description text

.wind_song
  db "Sun Bath: 7/16, Wind Slash: 5/16",$01
  db "Razor Leaf: 3/16, Cockatrice: 1/16",$00
.forest_suite
  db "Harvester: 7/16, Razor Leaf: 5/16",$01
  db "Elf Fire: 3/16, Raccoon: 1/16",$00
.desert_aria
  db "Sand Storm: 7/16, Mirage: 5/16",$01
  db "Sun Bath: 3/16, Meercat: 1/16",$00
.love_sonata
  db "Bedevil: 7/16, Moonlight: 5/16",$01
  db "Elf Fire: 3/16, Tapir: 1/16",$00
.earth_blues
  db "Avalanche: 7/16, Sun Bath: 5/16",$01
  db "Wind Slash: 3/16, Wild Boars: 1/16",$00
.water_rondo
  db "El Nino: 7/16, Plasma: 5/16",$01
  db "Surge: 3/16, Toxic Frog: 1/16",$00
.dusk_requiem
  db "Cave In: 7/16, Snare: 5/16",$01
  db "Moonlight: 3/16, Wombat: 1/16",$00
.snowman_jazz
  db "Blizzard: 7/16, Surge: 5/16",$01
  db "Mirage: 3/16, Ice Rabbit: 1/16",$00

warnpc $C4B9D1



; #########################################################################
; Freespace

org $C4B9D0
AutoCritProcs:
  LDA #$02          ; "Auto Critical"
  BIT $B3           ; check attack flags for ^
  BNE .exit         ; branch if not ^
  LDA $B6           ; spell #
  CMP #$17          ; is it quartr?
  BEQ .quartr       ; branch if so
  CMP #$0D          ; is it doom?
  BEQ .doom         ; branch if so
.exit
  LDA #$40          ; [moved] single enemy targeting
  STA $BB           ; [moved] update targeting type ^
  RTL
.doom
  LDA #$12          ; "X-Zone"
  STA $B6           ; set ^ spell
.quartr
  LDA #$6E          ; all foes targeting
  STA $BB           ; update targeting type ^
  LDA #$40          ; "Randomize Targets" [TODO why?]
  TSB $BA           ; set ^ flag
  STZ $11A9         ; clear special effect
  STZ $341A         ; set "Cannot be Countered"
  RTL

; #########################################################################
; Freespace Helpers
;
; Includes helpers for dn's "Scan Status" hack. Note that the battle
; messages added for status effects are applied separately, via the ips
; patch `[d]bnw_scan_status.ips`

org $C4F1D0
ScanWeakness:
  LDA #$15         ; "Weak to Fire"
  STA $2D6F        ; set ^ message ID
  LDA $3BE0,X      ; weaknesses byte
  BEQ .no_weakness ; branch if empty
  STA $EE          ; else, save in scratch
  LDA $3BE1,X      ; resisted elements
  ORA $3BCC,X      ; absorbed elements
  ORA $3BCD,X      ; immune elements
  TRB $EE          ; remove all from weaknesses
  LDA #$01         ; "Fire"
.elem_loop
  BIT $EE          ; check weaknesses
  BEQ .next_elem   ; branch if not weak
  PHA              ; store element bit
  LDA #$04         ; "message" animation type
  PHK              ; push $C4 onto stack
  PER .per_a-1     ; ensure JML below returns
  PEA $00CA        ; use RTL at $C200CB
  JML $C26411      ; queue message animation
.per_a
  PLA              ; restore element bit
.next_elem
  INC $2D6F        ; point to next message
  ASL              ; advance bit to next element
  BCC .elem_loop   ; loop till done
  RTL
.no_weakness
  LDA #$2C         ; "No Weakness"
  STA $2D6F        ; set ^ message ID
  LDA #$04         ; "message" animation type
  PHK              ; push $C4 onto stack
  PER .per_b-1     ; ensure JML below returns
  PEA $00CA        ; use RTL at $C200CB
  JML $C26411      ; queue message animation
.per_b
  RTL

ScanStatus:
  REP #$20         ; 16-bit A
  LDA $3EE4,x      ; status-1/2
  BIT #$F825       ; statuses to scan
  BNE .scan_away   ; branch if at least one
  LDA $3EF8,x      ; status-3/4
  BIT #$84FE       ; statuses to scan
  BNE .scan_away   ; branch if at least one
  SEP #$20         ; 8-bit A
  LDA #$58         ; "No Status"
  STA $2D6F        ; set message ID ^
  LDA #$04         ; "message" animation type
  PHK              ; push $C4 onto stack
  PER .per_c-1     ; ensure JML below returns
  PEA $00CA        ; use RTL at $C200CB
  JML $C26411      ; queue message animation
.per_c
  RTL
.scan_away
  SEP #$20         ; 8-bit A
  LDA #$47         ; first status message ID
  STA $2D6F        ; set message ID ^

  LDA $3EE4,x      ; status-1
  BIT #$01         ; "Dark"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$04         ; "Poison"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$20         ; "Imp"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte

  LDA $3EE5,x      ; status-2
  BIT #$08         ; "Mute"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$10         ; "Bserk"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$20         ; "Muddle"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$40         ; "Sap"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$80         ; "Sleep"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte

  LDA $3EF8,x      ; status-3
  BIT #$02         ; "Regen"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$04         ; "Slow"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$08         ; "Haste"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$10         ; "Stop"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$20         ; "Shell"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$40         ; "Safe"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$80         ; "Reflect"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  LDA $3EF9,x      ; status-4
  BIT #$04         ; "Death Protection"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  BIT #$80         ; "Float"
  PHA              ; store status byte
  JSR TryScan      ; display status message if ^
  PLA              ; restore status byte
  RTL

TryScan:
  BEQ .next
  LDA #$04         ; "message" animation type
  PHK              ; push $C4 onto stack
  PER .next-1      ; ensure JML below returns
  PEA $00CA        ; use RTL at $C200CB
  JML $C26411      ; queue message animation
.next
  INC $2D6F        ; point to next message ID
  RTS
warnpc $C4F2DB+1
