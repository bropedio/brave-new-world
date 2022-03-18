hirom

; C1 Bank

incsrc ram.asm

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
; Bushido Menu

org $C17D8A : JSR SwdTechMeter ; add handling for bushido meter scroll

; ########################################################################
; Rage Battle Menu
;
; Modify max scroll value for shortened rage battle menu (dn)

org $C184F9 : CMP #$1C ; (64 rages / 2) - 4(onscreen)

; ########################################################################
; Damage number color palette routine
;
; Intercept to check for new MP dmg flag at bit6, part of Imzogelmo's 
; "MP Colors" patch

org $C12D2B : NOP : NOP : JSL PaletteMP
org $C12B9B : NOP : NOP : JSL PaletteMP_mass

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

org $C1FFEC
SwdTechMeter:
  INC $7B82      ; increment meter position
  LDA $7B82      ; get new meter postion
  ADC $36        ; adds known Bushid count (to speed up)
  STA $7B82      ; update meter position
  RTS
  NOP            ; [unused space] TODO: Why?

