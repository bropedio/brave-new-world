hirom

; Y Screen Swap
; author: dn
; editor: Bropedio

org $C39648 : JMP EquipSwap : NOP #4
org $C398C8 : JMP EquipSubSwap : NOP #4
org $C39908 : JMP EquipSubSwap : NOP #4

org $C39EDC : JSR RelicSwap
org $C3A047 : JSR RelicSwap
org $C3A146 : JSR RelicSwap

org $C3F530
EquipSwap:
  BIT #$40          ; pressing Y
  BNE ToRelics      ; branch if ^
  LDA #$35          ; [moved] "Initialize Equip Menu"

HandleLR:
  STA $E0           ; [moved] set ^
  JMP $2022         ; handle L/R

ToRelics:
  JSR $0EB2         ; play click sound
  LDA #$58          ; "Initialize Relic Menu"
  STA $26           ; set next menu action
  INC $25           ; selected menu: "Relics"
  RTS

RelicSwap:
  LDA $09           ; buttons pressed
  BIT #$40          ; pressing Y
  BEQ .skip         ; branch if not ^
  JSR $0EB2         ; play click sound
  JSR $1E5F         ; check for equip permissions
  BCS .skip         ; branch if cannot equip
  JSR $9EEB         ; try auto-switch to equip menu
  LDA $99           ; was it triggered
  BNE .skip         ; branch if ^
  LDA #$35          ; "Initialize Equip Menu"
  STA $26           ; set ^
  STZ $27           ; zero queued command
  DEC $25           ; selected menu: "Equip"
.skip
  JMP $9EE6         ; memorize menu mode

EquipSubSwap:
  BIT #$40          ; pressing Y
  BNE ToRelics      ; branch if ^
  LDA $26           ; menu mode
  CLC : ADC #$29    ; "Swap Actor in Equip Menu" (retain Equip or Remove mode)
  BRA HandleLR      ; branch

; Duplicate Unused ==========================================
; This code appears to be leftover from earlier changes that
; were missing two ops, the INC $25 and DEC $25. Somehow they
; got left in the patch. Can be removed.

namespace "dup"

org $C3F4B1
EquipSwap:
  BIT #$40
  BNE ToRelics
  LDA #$35
HandleLR:
  STA $E0
  JMP $2022
ToRelics:
  JSR $0EB2
  LDA #$58
  STA $26
  ;INC $25
  RTS
RelicSwap:
  LDA $09
  BIT #$40
  BEQ .skip
  JSR $0EB2
  JSR $1E5F
  BCS .skip
  JSR $9EEB
  LDA $99
  BNE .skip
  LDA #$35
  STA $26
  STZ $27
  ;DEC $25
.skip
  JMP $9EE6
EquipSubSwap:
  BIT #$40
  BNE ToRelics
  LDA $26
  CLC : ADC #$29
  BRA HandleLR

namespace off
