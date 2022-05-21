;|----------------------------------------------|
;| Coreography                                  |
;| by: Sir Newton Fig                           |
;| Released on: September 28th, 2021            |            
;|----------------------------------------------|

arch 65816
hirom

table "menu.tbl",ltr

!free = $C23AC5     ; Former home of the Control effect handler, ripe for the picking

org $C21780
  AND #$FE          ; Always clear Dance status

org $C2179D
  JSR StumbleCheck  ; Let Moogle Charm bypass stumble chance

org $C219ED
  dw $177D          ; Revert Dance code pointer (decouple Moogle Charm from controlled dance)

org $C23C82         ; Reclaim space for Moogle Charm Dance wrapper
  padbyte $FF
  pad $C23C8F

org $C205B6         ; Modify how Dance step is determined
  JSL PickType      ; X = index of Dance step
  JSR $4B65         ; RNG (0..7)
  CMP.l Thresholds,X  ; Compare number with threshold
  BCS +             ; Use the common step if above
  INC $EE           ; Use the uncommon step if below
+ LDX $EE
  LDA $CFFE80,X     ; Get attack # for the Dance step used
  PLX
  RTS

; Data
Thresholds:
  db $05            ; Transition steps: choose A if RNG(0..19) >= 5 (75%), else B
  db $08            ; Sustain steps: choose A if RNG(0..19) >= 8 (60%), else B

padbyte $FF
pad $C205D1         ; 2 bytes reclaimed, wowee

org !free
PickType:
  LDA $3A6F
  LDX $11E2
  CMP $ED8E5B,X     ; Check if background is same as dance
  BNE +             ; Branch if not
  rep 2 : INC $EE   ; Use lower half of step list for sustain steps
  LDX #$01          ; Use sustain probabilities
  BRA ++
+ LDX #$00          ; Use transition probabilities
++ LDA #$14
+ RTL

StumbleCheck:
  PHA
  LDA $3C59,Y       ; Relic Effects 4
  BIT #$20          ; Moogle Charm flag (unused in Vanilla)
  BNE +
  JSR $3AB3         ; Check for stumble rate if no Charm equipped
  BRA ++
+ SEC               ; Proceed without stumble check if Charm equipped
++ PLA
  RTS

padbyte $FF         ; Reclaim (most of) the rest of the routine
pad $C23B1B         ; After this, some of the Control code miss condition is still required

;Dance tables

org $CFFE80 ; Reorganize Dance Step -> Attack Number table
  ; Wind Song
  ; -- Transition --
  db $66 ; Sun Bath   ; 75%
  db $75 ; Cockatrice ; 25%
  ; --- Sustain -----
  db $67 ; Razor Leaf ; 60%
  db $65 ; Wind Slash ; 40%

  ; Forest Suite
  ; -- Transition --
  db $67 ; Razor Leaf ; 75%
  db $7A ; Raccoon    ; 25%
  ; --- Sustain -----
  db $68 ; Harvester  ; 60%
  db $6B ; Elf Fire   ; 40%
  
  ; Desert Aria
  ; -- Transition --
  db $6E ; Mirage     ; 75%
  db $77 ; Meerkat    ; 25%
  ; --- Sustain -----
  db $66 ; Sun Bath   ; 60%
  db $69 ; Sand Storm ; 40%
  
  ; Love Sonata
  ; -- Transition --
  db $6B ; Elf Fire   ; 75%
  db $78 ; Tapir      ; 25%
  ; --- Sustain -----
  db $6C ; Bedevil    ; 60%
  db $6A ; Moonlight  ; 40%
  
  ; Earth Blues
  ; -- Transition --
  db $6D ; Avalanche  ; 75%
  db $79 ; Wild Boars ; 25%
  ; --- Sustain -----
  db $ED ; Landslide  ; 60%
  db $66 ; Sun Bath   ; 40%
  
  ; Water Rondo
  ; -- Transition --
  db $6F ; El Nino    ; 75%
  db $7B ; Toxic Frog ; 25%
  ; --- Sustain -----
  db $70 ; Plasma     ; 60%
  db $74 ; Surge      ; 40%
  
  ; Dusk Requiem
  ; -- Transition --
  db $6A ; Moonlight  ; 75%
  db $76 ; Wombat     ; 25%
  ; --- Sustain -----
  db $71 ; Snare      ; 60%
  db $72 ; Cave In    ; 40%

  ; Snowman Jazz
  ; -- Transition --
  db $73 ; Blizzard   ; 75%
  db $7C ; Ice Rabbit ; 25%
  ; --- Sustain -----
  db $74 ; Surge      ; 60%
  db $6E ; Mirage     ; 40%

;Dances description

org $C4AFC3

dw Wind   : dw Forest
dw Desert : dw Love
dw Earth  : dw Water
dw Dusk   : dw Snow

; Current format: odds suffixed
Wind: db "T: Sun Bath, Cockatrice",$01,"S: Razor Leaf, Wind Slash",$00
Forest: db "T: Razor Leaf, Raccoon",$01,"S: Harvester, Elf Fire",$00
Desert: db "T: Mirage, Meerkat",$01,"S: Sun Bath, Sand Storm",$00
Love: db "T: Elf Fire, Tapir",$01,"S: Bedevil, Moonlight",$00

Earth: db "T: Avalanche, Wild Boars",$01,"S: Landslide, Sun Bath",$00
Water: db "T: El Nino, Toxic Frog",$01,"S: Plasma, Surge",$00
Dusk: db "T: Moonlight, Wombat",$01,"S: Snare, Cave In",$00
Snow: db "T: Blizzard, Ice Rabbit",$01,"S: Surge, Mirage",$00
