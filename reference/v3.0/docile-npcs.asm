hirom

; Docile NPCs
; Author: SilentEnigma
;
; This patch makes NPCs less likely to get in the player's way.
; When the player is pressing a direction to move into a specific
; tile, NPCs with random movement will not walk into that tile.

!freespace = $C0DAB0

org $C07BB9 : JMP DocileNPCs ; jump to new helper

org !freespace
DocileNPCs:
  JSR $7D03      ; get coords of tile NPC is trying to move to (in $1E/$1F)
  LDX $0803      ; offset of visible character data block
  LDA #$29       ; divisor (size of object data block)
  STX $4204      ; set dividend
  STA $4206      ; set divisor
  NOP #7         ; do we need this many cycles?
  LDA $4214      ; visible character object ID
  ASL            ; x2
  LDX $1E        ; X coordinate of tile NPC wants to move to
.right
  CMP $7E2001,x  ; would the party be to their right?
  BNE .left      ; branch if not ^
  LDA #$02       ; "pressing left"
  BRA .abort     ; check collision
.left
  CMP $7E1FFF,x  ; would the party be to their left?
  BNE .down      ; branch if not ^
  LDA #$01       ; "pressing right"
  BRA .abort     ; check collision
.down
  CMP $7E2100,x  ; would the party be below them?
  BNE $04        ; branch if not ^
  LDA #$08       ; "pressing up"
  BRA .abort     ; check collision
.up
  CMP $7E1F00,x  ; would the party be above them?
  BNE .return    ; branch if not ^
  LDA #$04       ; "pressing down"
.abort
  BIT $07        ; is player trying to move there?
  BEQ .return    ; exit if not ^
  RTS            ; else, NPC doesn't move
.return
  JMP $7BBE
