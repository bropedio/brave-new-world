; -----------------------------------------------------------------------------
; Synopsis: Highlights enemy counterattacks using a custom text color.
;     Base: BNW 2.2b15
;   Author: Fëanor
;  Created: 2023-05-27
;  Updated: 2023-06-01
; -----------------------------------------------------------------------------
hirom

!free_a = $C13E03      ; 18 bytes of free space required
!warn_a = !free_a+28   ; 28 bytes available

!free_b = $C2FBB9      ; 12 bytes of free space required
!warn_b = !free_b+13   ; 13 bytes available

!free_c = $C2FC11      ; 6 bytes of free space required
!warn_c = !free_c+6    ; 6 bytes available

!isCounter = $CF       ; custom counterattack flag
!textcolor = #$037F    ; custom text color = yellow

; -----------------------------------------------------------------------------
; Routine: Draw Dialogue Text
; -----------------------------------------------------------------------------
; C1/5DD5:
;   ...
;   STX $48
;   LDA $88D9
org $C15DE2
    JSR SpliceDrawText
    NOP
;   LDA [$48]
;   BEQ $5DFE
;   ...
; -----------------------------------------------------------------------------
; Routine: Setting Default Window Colors
; -----------------------------------------------------------------------------
; C1/99AC:
;   LDX #$0000
;   STX $7E22
org $C199B2
    LDX !textcolor    ; set custom text color
;   STX $7E24
;   LDX $1D55
;   ...
; -----------------------------------------------------------------------------
; Routine: Main Battle Loop
; -----------------------------------------------------------------------------
; C2/0019:
;   ...
;   JSR $5C73
;   LDA #$06
org $C2007A
    JSR SpliceBattleLoop
;   LDA #$04
;   TRB $b0
;   ...
; -----------------------------------------------------------------------------
; Routine: Init Battle RAM
; -----------------------------------------------------------------------------
; C2/23ED:
;   ...
;   DEX
;   BPL $2437
org $C22440
    JSR SpliceBattleInit
;   ASL
;   ASL
;   ...
; -----------------------------------------------------------------------------
; Routine: AI Counterattack
; -----------------------------------------------------------------------------
; C2/4BF4:
;   ...
;   STA $F4
;   CLC
org $C24C43
    JSR SpliceAICounter
;   LDA $F2
;   STA $3D20,X
; -----------------------------------------------------------------------------

; enable custom text color usage for counterattacks only (requires excluding
; anything that doesn't have an attack name type)
org !free_a
SpliceDrawText:
    STA $4A         ; [displaced]
    STZ $4B         ; [displaced]
    LDA $3412       ; check 'Attack Name Type'
    CMP #$FF
    BEQ .end        ; branch if empty
    LDA !isCounter  ; check custom counterattack flag
    BEQ .end        ; branch if not a counterattack
    STA $4B         ; enable custom text color usage (A > 0 always)
.end
    RTS
warnpc !warn_a

; clear custom counterattack flag at start of battle and as part of the main
; battle loop
org !free_b
SpliceBattleInit:
    STZ !isCounter  ; clear custom counterattack flag
    LDA $021E       ; [displaced]
    RTS
SpliceBattleLoop:
    JSR $6411       ; [displaced]
    STZ !isCounter  ; clear custom counterattack flag
    RTS
warnpc !warn_b

; set custom counterattack flag whenever an AI counterattack is executed
org !free_c
SpliceAICounter:
    INC !isCounter  ; increment custom counterattack flag so it's non-zero
    JSR $1A2F       ; [displaced]
    RTS
warnpc !warn_c
