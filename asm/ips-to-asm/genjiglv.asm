hirom

; Gengi Glove Fix
; author: Assassin
; editor: Bropedio

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


