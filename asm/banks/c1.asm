hirom

; C1 Bank

; ########################################################################
; NMI

; ------------------------------------------------------------------------
; Add hook to listen for "Select" button press

org $C10CFA : JSR CheckSel

; ########################################################################
; Status Graphics (cont.)
;
; Large portion after $2E69 rewritten by dn to support cycling auras.

org $C12E2D
StatusGraphics:
org $C12E4F
  BRA ResetAura      ; reset aura cycling if Poison
org $C12E5C
  BRA ResetAura      ; reset aura cycling if Zombie
org $C12E69
  BRA ResetAura      ; reset aura cycling if Berserk
  LDA #$1E           ; "Stop/Haste/Slow/Regen"
  TRB $38            ; ignore ^ status-3, which no longer use aura graphics
  LDA !aura_cycle,Y  ; current outline rotation for character
.loop
  BIT $38            ; check for current status-3
  BNE SetColor       ; branch if status set
  LSR                ; else, check next
  ADC #$00           ; maintain "wait" bit
  STA !aura_cycle,Y  ; update current aura color
  CMP #$20           ; loop over 3 statuses (80,40,20)
  BCS .loop          ; loop till done
ResetAura:
  LDA #$80           ; no aura, so reset to Rflect
UpdateAura:
  STA !aura_cycle,Y  ; update current aura color
  RTS
SetColor:
  AND #$E0           ; clear "wait" bit
  JSR $1A0F          ; convert bitmask to bit index in X
  LDA .color_table,X ; get outline colour
.color_table
  BRA AuraControl  ; implement
  db $04 ; Slow [unused]
  db $03 ; Haste [unused]
  db $07 ; Stop [unused]
  db $02 ; Shell
  db $01 ; Safe
  db $00 ; Rflect

CycleAura:
  LDA !aura_cycle,Y  ; current outline colour rotation
.loop
  LSR                ; get next aura, C: "wait" bit
  BCS ResetAura      ; branch to reset aura if ^
  AND #$FC           ; keep 6 bits TODO only need 3 bits now
  BEQ ResetAura      ; branch to reset if no more auras in sequence
  BIT $38            ; check current status for this aura
  BEQ .loop          ; loop until match found
  BRA UpdateAura     ; set new aura color
  RTS                ; [unneeded] TODO
warnpc $C12EB5+1
padbyte $EA          ; fill remaining space with NOP
pad $C12EB4          ; ensure earlier $C12EB4 branches still work
  RTS

org $C12EC3
AuraControl:
  PHA                ; [unchanged] store aura index         
  LDA $0E            ; [unchanged] frame counter
  STA $2C            ; [unchanged] save ^ in scratch
  PLA                ; [unchanged] restore aura index
AuraControl2:
  PHA                ; [unchanged] store aura index
  LDA $2C            ; [unchanged] frame counter
  AND #$03           ; [unchanged] isolate which character slot
  TAX                ; [unchanged] index ^
  LDA $C2E3AA,X      ; [unchanged] 0/8/16/24, based on character
  CLC                ; [unchanged] clear carry
  ADC $2C            ; [unchanged] add to frame counter to stagger graphics
  STA $36            ; [unchanged] save ^ in scratch
  AND #$3C           ; remove character slot frame data
  LSR A              ; / 2
  STA $2C            ; save aura brightness
  STZ $2D            ; zero hibyte
  LDA $36            ; full frame counter
  ASL #2             ; x4
  BCC .transition    ; branch if < $40 ($2C < $20)
  LDA #$1F           ; else, pivot counter around #$1F
  SBC $2C            ; subtract counter from pivot
  STA $2C            ; update counter (-32 through -1)
.transition
  LDA $2C            ; aura brightness
  CMP #$1F           ; at minimum brightness (31)
  BNE .get_color     ; branch if not ^
  JSR CycleAura      ; set (pending) next aura color
  BRA .get_color     ; get current aura color palette
  NOP                ; [unused]
warnpc $C12EF7+1
org $C12EF7
.get_color

; ########################################################################
; Fix Vanilla Bug that blocks running animation for Morph instead of
; the Frozen status. From assassin

org $C1353F : AND #$02

; ########################################################################
; Bushido Menu

org $C17D8A : JSR SwdTechMeter ; add handling for bushido meter scroll

; ########################################################################
; Lore Battle Menu

org $C18336 : CMP #$0C    ; lore menu length - 4 (x2)
org $C1838F : LDA #$0C    ; lore menu scrollbar rows + 4 (see above)

; ########################################################################
; Rage Battle Menu

org $C184F9 : CMP #$1C    ; (64 rages / 2) - 4(onscreen)
org $C1854A : LDA #$1C    ; rage menu scrollbar rows (see above)
org $C1854E : LDX #$0140  ; pixels per rage menu scrollbar row [?]

; ########################################################################
; Damage number color palette routine
;
; Intercept to check for new MP dmg flag at bit6, part of Imzogelmo's 
; "MP Colors" patch

org $C12D2B : NOP : NOP : JSL PaletteMP
org $C12B9B : NOP : NOP : JSL PaletteMP_mass

; #######################################################################
; Status Text Display for targeting window

org $C14587
StatusTextDisp: ; @returns: bit 0 = Regen, Bit 1 = Rerise, Bit 2 = Sap
  XBA           ; get B
  PHA           ; store ^
  XBA           ; get A again
  LDA $2EBE,X   ; Status byte 2 (for Sap)
  ROL #2        ; Rotate Sap into carry
  TDC           ; Clear A
  ROL           ; Rotate Sap into bit 0
  XBA           ; Save Sap
  LDA $2EC0,X   ; Status byte 4 (Rerise byte)
  LSR #3        ; Shift Rerise into carry
  XBA           ; Get Sap again
  ROL           ; Rotate Rerise into bit 0, Sap into bit 1
  XBA           ; Save Sap and Rerise
  LDA $2EBF,X   ; Status byte (for Regen)
  LSR #2        ; Shift Regen into carry
  XBA           ; Get Sap and Rerise
  ROL           ; Rotate Regen into bit 0, Rerise into bit 1, Sap into bit 2
  XBA           ; store A
  PLA           ; restore original B
  XBA           ; store in B ^
  RTS
padbyte $FF : pad $C145B3

; #######################################################################
; Spell Name Message Display
;
; dn's "Spell Dot" hack shifts loop to include prefix dot

org $C1602E : NOP #3 ; skip decrementing spell name length
org $C16031 : LDA $E6F567,X ; decrement starting offset by 1

; #######################################################################
; Battle Dynamics Commands Jump Table

; Add aliases for existing damage number commands
; Part of "MP Colors" patch

org $C191A0 : dw $A4B3  ; battle dynamics $05, alias to $0B (cascade)
org $C191A6 : dw $9609  ; battle dynamics $08, alias to $03 (mass)

; ######################################################################
; Damage Numbers Animation Handler(s)

; Add MP dmg flags based on battle dynamics command ID, for MP Colors
; patch

org $C1A5A9 : NOP : JSL SetMPDmgFlag
org $C1A6E6 : NOP : JSL SetMPDmgFlagMass

; ######################################################################
; Freespace (stats at $C1FFE5)

org $C1FFE5

; ----------------------------------------------------------------------
; During NMI, if Select button pressed, swap gauge display

CheckSel:
  JSL SwapGauge  ; (in $C3)
  JMP $0B73      ; [displaced]

; ----------------------------------------------------------------------
SwdTechMeter:
  INC $7B82      ; increment meter position
  LDA $7B82      ; get new meter postion
  ADC $36        ; adds known Bushid count (to speed up)
  STA $7B82      ; update meter position
  RTS
  NOP            ; [unused space] TODO: Why?

