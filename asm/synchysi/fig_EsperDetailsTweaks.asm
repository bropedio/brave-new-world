hirom
header

table c3.tbl,rtl

!free = $C3FD08

org $C3599D
  db $10,$B8        ; Reposition EL bonus cursor

org $C3F431
  dw #$470F         ; Position EL bonus label 2 chars left

org $C35A4C
  db #$0B           ; Remove 2 spaces between label and bonus

org $C3F3F3
  dw #$4791         ; Position EL bank label 2 chars left

org $C3F41B
  dw #$47A9         ; Position EL bank 2 chars left

org $C35CE2
  SPLabel:    dw #$47B1 : db "SP ",$00
  LearnLabel: dw #$4437 : db "Learn",$00
  SPMax:      dw #$47BB : db "/30",$00

org $C35B0A         ; Slight adjustments to Synchysi's code here
  JMP MPCost        ; was JSR Learn_Chk
  SPCost:

org $C359CF         ; End of drawing Esper name
  JSR DrawEsperMP

org $C35B21
  JMP FinishSP      ; changed destination

org $C3F752         ; End of Blue_Bank_Txt
  dw #$47B7         ; Locate SP bank down the bottom now
  JMP NewLabels     ; Output banked SP and other new static labels

org !free

FinishSP:
  LDA #$8F          ; P
  STA $2180
  STZ $2180         ; EOS
  JMP $7FD9         ; String done, now print it

MPCost:
  PHA               ; Store SP cost for retrieval
  PHX               ; Preserve X for isolation purposes
  LDA #$FF
  STA $2180
  LDA $E1           ; ID of the spell
  JSR $50F5         ; Compute index
  LDX $2134         ; Load it
  LDA $C46AC5,X     ; Base MP cost
  PLX               ; Restore X
  JSR $04E0         ; Turns A into displayable digits
  LDA $F8           ; tens digit
  STA $2180
  LDA $F9           ; ones digit
  STA $2180
  LDA #$FF          ; space
  STA $2180
  LDA #$8C          ; M
  STA $2180
  LDA #$8F          ; P
  STA $2180
  LDA #$FF          ; 3 spaces
  STA $2180
  STA $2180
  STA $2180
  LDA $AA
  LSR
  BCC .unknown
.known
  PLA
  JMP Known         ; print a checkmark
.unknown
  PLA
  JSR $04E0         ; Turns A into displayable digits
  JMP SPCost        ; go back to where we sliced in and output SP cost

Known:  
  LDA #$FF          ; 2 spaces to center checkmark
  STA $2180
  STA $2180
  
  LDA #$CF          ; checkmark
  STA $2180
  
  LDA #$FF          ; 2 more spaces to overwrite stale text in this slot
  STA $2180
  STA $2180

  STZ $2180         ; EOS
  JMP $7FD9

NewLabels:
; The flip-flopping from white to blue for all of the static positioned
; text could be streamlined, but this is just so much simpler to grap
; than having to slice the blue in with the blue and the white in with
; the white, etc.

  JSR $04B6         ; Write banked SP to screen (relocated)
  LDY #SPMax
  JSR $02F9         ; Print "/30" with SP bank
  LDA #$24
  STA $29           ; Set text color to blue
  LDY #LearnLabel
  JSR $02F9         ; Print "Learn"
  LDA #$20
  STA $29           ; Set text color back to white
  LDA #$00
  XBA               ; Wipe HB of A
  LDA $99
  RTS

DrawEsperMP:
  LDA #$FF
  STA $2180         ; 3 spaces
  STA $2180
  STA $2180
  LDA $99           ; Current Esper
  ADC #$36          ; Get attack ID
  PHX
  JSR $50F5         ; Compute index
  LDX $2134         ; Load it
  LDA $C46AC5,X     ; Base MP cost
  PLX
  JSR $04E0         ; Turns A into displayable digits
  LDA $F8           ; tens digit
  STA $2180
  LDA $F9           ; ones digit
  STA $2180
  LDA #$FF          ; space
  STA $2180
  LDA #$8C          ; M
  STA $2180
  LDA #$8F          ; P
  STA $2180
  STZ $2180         ; EOS
  RTS
