hirom
header

; The following contains minor tweaks or optimizations to
; code Synchysi wrote in restrict-espers.asm and esper-
; changes.asm. 
;
; As it stands currently, the "Can't Equip!" message only
; works by fluke because X usually contains a specific text
; pointer (Esper description) – once I started messing around
; with that, it started claiming Terra had every esper due to
; an incompatible offset. The following changes shelter the Uneq
; routine from this issue. They also remove some redundant
; executions of the esper equippability routine by flagging a
; scratch variable with the equippability determination.
;
; Most of the code that follows is reproduced verbatim from
; their original sources, and I have done my best to note the
; portions that differ.

; -------------------------------------------------------------------------------

org $C3F097

; Manually disassembled and modified, commentary is my own.
; I eliminated one of the loops, and optimized the other slightly.
; The latter now also rolls the equippability bit onto a scratch
; variable instead of doing an AND on the LSB of A. This scratch
; variable is used in other places to determine equippability.
; This change is the foundation of everything else in this file.

ChkEsp:
  STZ $FB           ; reserve for equippability flag
  STA $E0           ; store Esper ID in $E0
  LSR #3            ; /8 (determine which byte the esper is in)
  STA $FC           ; store offest to scratch
  LDA $A3           ; load character ID
  ASL #2            ; x4 (4 equippability bytes per character?)
  ADC $FC           ; add stored offset
  TAX               ; index it in X
  LDA $E0           ; load esper ID
  AND #$07          ; which bit of the equippability byte corresponds to this esper?
  TAY
  LDA $C3F0F5,X     ; get equippability byte for esper/character pair
- LSR               ; Do: shift right
  DEY               ; | Y--
  BPL -             ; + loop until Y negative
                    ;
  ROR $FB           ; ############## // New Swag Alert! \\ ###############
                    ; | At this point, the C flag will be 1 if the esper |
                    ; | is equippable. I roll it onto the MSB of $FB     |
                    ; | so that we can use the shorthand `BIT $FB` later |
                    ; | to evaluate the equippability of the currently   |
                    ; | loaded esper without having to destroy A         |
                    ; ####################################################
                    ;
  BPL +             ; if positive, esper cannot be equipped; branch
  JSR $5576         ; can equip; check for equip conflict with another character
  STX $FD           ; keep track of who has the current esper equipped, if anyone
  PHA
  LDA $29
  STA $FC           ; keep track of the esper palette
  PLA
  RTS
+ LDA #$28          ; cannot equip; gray text
  STA $FC           ; keep track of the esper palette
  JMP $5595         ; return

; This routine is the same length as the original, and gives us three
; persistent outputs we can utilize elsewhere so that we don't have to
; run it as many times on the esper info screen.

; -------------------------------------------------------------------------------

org $C3F77B

; The main change here is that I now check $FB for equippability
; instead of calling `Chk_Esper_Eq`. The rest is just making sure
; the palette values are loaded in the correct execution forks.

Learn_Chk:
  STZ $AA
  LDA $E0           ; SP cost of the spell
  PHA               ; Preserve it, because C3/50A2 mutilates $E0
  BIT $FB           ; Is esper equippable? (new)
  BPL .cantEquip
  LDA $E1           ; If so, get spell ID
  JSR $50A2         ; See if it's known yet
  BEQ .notLearned
  INC $AA           ; If so, flag $AA
.notLearned
  LDA #$20          ; White text if esper is equippable
  BRA .done
.cantEquip
  LDA #$28          ; Gray text if not (moved from above)
.done
  STA $29           ; Set palette
  PLA               ; Retrieve SP cost
  RTS

; -------------------------------------------------------------------------------

org $C3F7A5

; This removes a `ChkEsp` call from `Chk_Spell`, since we
; now have a stored shorthand for looking that up. A snippet
; of original code (commented out) is included for context

; Chk_Spell:
;   LDA $99           ; Load esper ID
;   STA $4202
;   JSR ChkEsp        ; <- $C3F7A5, this is where I cut in
;   TDC
;   LDA $29
;   CMP #$28          ; <- from where I start to the end of this line, that's 8 bytes
;   BEQ Bzzt_Player   ; <- $C3F7AF, this is where my slice should end up

  BIT $FB             ; Is esper equippable?
  BRA $04             ; Skip the next 4 bytes
  NOP #4              ; Dummy them out to be sure
                      ; = 8 bytes
; BPL Bzzt_Player     ; This is what I need it to do, so...
  db #$10             ; ...just replace BEQ -> BPL

; -------------------------------------------------------------------------------

; There are two notable changes in the following section.
;
; First, it flips the logic: check for unequippability, then
; assume a conflict if it's equippable (rather than checking for
; the conflicting name and then assuming it's unequippable if the
; letter is blank, which will only work for a pre-assumed X offset)
;
; This makes the "Can't Equip!" message much less prone to breaking
; due to unexpected X register values that are leftover from other
; operations.
;
; Second, it gets rid of the yucky JSR/PLX juju by JMPing in and out.
; If one execution branch ends in a JMP, might as well let them both.
; We have the space to spare, and it's only called in one place.

org $C355B2
  JMP Uneq            ; Was JSR, but see below

org $C3F0CB
Uneq:
  BIT $FB             ; Is esper equippable?
  BPL +               
  LDA $1602,X         ; Character's name; displaced from calling function
  JMP $55B5           ; If esper is equippable, go back and display who has it equipped
+ LDX $00             ; Else, print "Can't Equip!" error message
                      
; Note the gross PLX is gone now that we JMP back
; to the calling location instead of RTS :)

- LDA.l NoEqTxt,X
  STA $2180           ; Print the current letter.
  BEQ Null            ; If the letter written was null ($00), exit.
  INX                 ; Go to the next letter.
  BRA -
Null:
  JMP $7FD9           ; 27 bytes total, 2 bytes to spare

; "Can't equip!" text.
;
; NOTE: the extra 2 nulls at the end are to make up for the difference
;   in this routine's length. The "p!" at the end of the string in the
;   old version was still there, so I've just nulled it out to be tidy.
;   Esper equippability tables still follow from here in their original
;   locations.

NoEqTxt:
  DB $82,$9A,$A7,$C3,$AD,$FF,$9E,$AA,$AE,$A2,$A9,$BE,$00,$00,$00

org $C358E1           ; previously `JSR ChkEsp`
  STA $E0             ; memorize esper
  LDX $FD             ; retrieve stored offset for who has esper equipped
  NOP                 ; filler byte to get us back in the right spot
  LDA $FC             ; retrieve stored esper palette
