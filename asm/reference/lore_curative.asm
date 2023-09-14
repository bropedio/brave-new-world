hirom
; header

; BNW - Lore Curative
;
; Allow Lore and Esper menus to open "Curative Ally Targeting" submenu

; #########################################################################
; Sustain Item Menu

; Fork where targeting menu type is selected
org $C18931 : ItemJump:

; #########################################################################
; Sustain Magic Menu

; -------------------------------------------------------------------------
; Rearrange targeting menu code to re-use item menu targeting and
; create additional room for handling Lore targeting

org $C181D6
SpellJump:
  LDA $2094,X     ; targeting byte
  XBA             ; store in B
  LDA #$03        ; "Magic" parent menu
LoreHelp:
  STA $ECBA       ; set parent menu
  LDA #$00        ; ensure B stays zero
  XBA             ; get targeting byte
  STA $7A84       ; save ^
  JMP ItemJump    ; leverage item code for targeting fork
warnpc $C181EC

; #########################################################################
; Sustain Lore Menu

; -------------------------------------------------------------------------
; Support curative targeting window for Lores that target allies

org $C18374
LoreJump:
  XBA            ; store targeting byte 
  LDA #$09       ; set parent menu to "Lore"
  JMP LoreHelp   ; handle opening targeting window

; #########################################################################
; Close "Target Allies" Menu (Cursor handling)
;
; -------------------------------------------------------------------------
; Modify conversion of $ECBA "parent menu" variable to support Lore menu
;
; Previously, was { x + 26 }
; Now, does { x | 26 }
;
; Magic was 1, but now is 3 (computes to 27)
; Item was 0, still is 0 (computes to 2)
; Lore now is 9 (computes to 27)

org $C14573
  LDA #$1A         ; 26
  NOP : ORA $ECBA  ; x | 26

; #########################################################################
; Close "Target Allies" Menu (Window handling)

; -------------------------------------------------------------------------
; Modify conversion of $ECBA "parent menu" variable to support Lore menu
;
; Previously, was { x * 2 + 2 }
; Now, does { (x + 5) / 2 }
;
; Magic was 1, but now is 3 (computes to 4)
; Item was 0, and still is 0 (computes to 2)
; Lore now is 9 (computes to 7)

org $C155C2
  CLC : ADC #$05   ; (x + 5)
  LSR              ; (x + 5) / 2
