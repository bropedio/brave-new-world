hirom
header

; A collection of the smaller of Seibaby's hacks posted in the repo thread for 2.0

; Probabilities for Side/Pincer/Back/Normal attacks
org $C25279
db $20    ; Side attack (32/255)
db $20    ; Pincer (32/255)
db $20    ; Back attack (32/255)
db $9B    ; Normal (155/255)

; Vindictive Targeting Fix
org $C22002
CMP #$04

; Set Runicked attacks to Ignore Clear
org $C2357E
LDA #$2182
STA $11A3      ;Set just concern MP, not reflectable, Unblockable, Heal
LDA #$8040
TRB $B2        ;Flag little Runic sword animation, set Ignore Clear
SEP #$20       ;Set 8-bit Accumulator
LDA #$60
STA $11A2      ;Set just ignore defense, no split damage
TDC            ;need top half of A clear
LDA $11A5      ;MP cost of spell
JSR $4792      ;divide by X
STA $11A6      ;save as Battle Power
JSR $385E      ;Sets level, magic power to 0
JSR Runic      ;(some runic patch hook?)
LDA #$04       ; A = 4
STA $BA        ;Don't retarget if target invalid
DEC A          ; A = 3

org $C2FAB4
Runic:

; N. Cross (Special effect $29)
; One or two targets will be picked randomly
org $C2414D
C2414D: REP #$20       ; Set 16-bit A
C2414F: LDA $A4        ; Targets
C24151: PHA            ; Save targets
C24152: JSR $522A      ; Randomly pick an entity from among the targets
C24155: JMP morecode
	org $C2661B
morecode:
        STA $A4        ; Save new target
        PLA            ; Get original targets again
        JSR $522A      ; Pick one at random
        TSB $A4        ; Save new target(s)
        SEP #$20       ; Set 8-bit A
        RTS

;BNW Mind Blast tweak
	; Loop 5 times for Mind Blast
;org $C2413E
;LDY #$08
;	org $C23BB8
;LDX #$08
;	org $C23BC1
;JSR checkStam        ; Check Stamina before attempting to set status
	
;org $C23CA2
;checkStam:
;SEP #$20
;JSR $23B2            ; Check if Stamina blocks
;REP #$20            
;BCS .exit            ; Exit if so
;JMP $3BD0            ; Randomly mark a status from attack data to be set
;.exit
;RTS

; Quake removes Clear status even when missing Floating targets fix
; Version 1.0
; by Seibaby

; Spell Effect Pointer $25: Quake (Once-per-strike)
org $C2432B
dw groundBased

; Untarget Floating targets, except if all targets are Floating
org $C2FC3F
reset bytes
groundBased:
        REP #$20          ; Set 16-bit Accumulator
        LDA $A2
        STA $EE           ; Copy targets to temporary variable
        LDX #$12
.loop   LDA $3EF8,X       ; Current status byte 3-4
        BPL .next         ; Check next target if this one is not floating
        LDA $3018,X
        TRB $EE           ; Clear this monster from potential targets
.next   DEX
        DEX
        BPL .loop         ; Loop for all 10 targets
        LDA $EE
        BNE .save         ; Branch if any target(s) left
        LDA #$0080
        TRB $B3           ; No targets valid, so set Ignore Clear
        LDA $A2           ; Else, use original Targets
.save   STA $B8           ; save target(s)
        TYX
        JMP $57C2
print bytes

; Back attack damage thingy
org $C23447
NOP #7

; Add a multiplier for Exploder when used by a player character
; 1 Spell Power = +50% damage
	; Exploder effect
org $C23FFC
JSR newfunc
	org $C2A8D2
newfunc:
      TDC         ; Clear 16-bit A
      CPY #$08    ; Check if monster
      BCS .exit   ; If monster, multiplier = 0
      LDA $11A6   ; Else, use Spell Power as multiplier
.exit STA $BC     ; Store multiplier
      TYX
      RTS