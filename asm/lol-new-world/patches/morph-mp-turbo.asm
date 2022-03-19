org $C14E42           ; populate Esper MP cost in menu
  JSL EsperSlice
  NOP : NOP

org $C157AD           ; build spell menu
  JSL SpellMenuSlice
  NOP : NOP

org $C181F9           ; sustain spell menu
  JSL SpellMenuSlice
  NOP : NOP

; probably unnecessary, but rando support, I guess?
org $C158FA           ; build lore menu
  JSL LoreMenuSlice
  NOP : NOP

org $C18389           ; sustain lore menu
  JSL LoreMenuSlice
  NOP : NOP


org $C24EF5           ; queueing MP cost for spell
  JSL MPSlice
  NOP

org $C257BB           ; called during spell availability refresh on MP change
  JSL ValiditySlice   ; set carry if insufficient MP
  RTS

org !MorphMPTurbo_freespace

TurboCalc:            ; MP *= 1.5 if Morphed
  PHA                 ; store MP cost
  LDA $3EF9,X
  BIT #$08
  BEQ +               ; skip if not Morphed
  LDA $01,S
  LSR
  ADC $01,S           ; MP = MP * 1.5
  STA $01,S
+ PLA                 ; retrieve MP cost
  RTS
  
MPSlice:
  JSR TurboCalc       ; MP = x1.5 if Morphed
  STA $3620,Y         ; save MP cost
  REP #$20            ; Set 16-bit Accumulator
  RTL

TurboWrapper:         ; Get correct X offset, then call TurboCalc
  PHX
  PHA
  TYA
  ASL                 ; Double Y
  TAX                 ; transfer to X
  PLA
  JSR TurboCalc
  PLX                 ; restore original X
  RTS

ValiditySlice:
  LDA $0003,X         ; get spell's MP cost from menu data
  JSR TurboCalc       ; x1.5 if Morphed
  CMP $3A4C           ; compare to Caster MP + 1, capped at 255
  RTL

EsperSlice:           ; display 1.5x MP cost in Esper menu, if needed
  LDA $2091,X
  JSR TurboWrapper
  STA $576A
  RTL

SpellMenuSlice:       ; display 1.5x MP cost in Spell menu, if needed
  LDA $2095,X
  JSR TurboWrapper
  STA $6178
  RTL

LoreMenuSlice:        ; display 1.5x MP cost in Lore menu, if needed
  LDA $216D,X
  JSR TurboWrapper
  STA $6178
  RTL

MorphMPTurbo_EOF:
